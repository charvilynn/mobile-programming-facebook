const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { User, RefreshToken } = require('../models');
const { AppError } = require('../middleware/error.middleware');

const ACCESS_TOKEN_EXPIRE  = process.env.JWT_EXPIRE         || '15m';
const REFRESH_TOKEN_EXPIRE = process.env.REFRESH_TOKEN_EXPIRE || '30d';
const JWT_SECRET           = process.env.JWT_SECRET;
const REFRESH_SECRET       = process.env.REFRESH_SECRET;

// Helpers
const signAccess  = (id) => jwt.sign({ id }, JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRE });
const signRefresh = (id) => jwt.sign({ id }, REFRESH_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRE });

const createRefreshToken = async (userId, deviceInfo) => {
  const token = signRefresh(userId);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  await RefreshToken.create({
    user_id: userId,
    token,
    expires_at: expiresAt,
    device_info: deviceInfo || null,
  });
  return token;
};

// POST /auth/register
exports.register = async (req, res, next) => {
  try {
    const { username, email, password, full_name } = req.body;

    if (!username || !email || !password || !full_name) {
      throw new AppError('Semua field wajib diisi', 400);
    }

    const existing = await User.findOne({ where: { email } });
    if (existing) throw new AppError('Email sudah terdaftar', 409);

    const user = await User.create({
      username:      username.toLowerCase().trim(),
      email:         email.toLowerCase().trim(),
 password_hash: password, // bcrypt hook handles hashing
      full_name:     full_name.trim(),
    });

    const token        = signAccess(user.id);
    const refreshToken = await createRefreshToken(user.id, req.headers['user-agent']);

    res.status(201).json({
      message:       'Akun berhasil dibuat',
      token,
      refresh_token: refreshToken,
      user:          user.toSafeJSON(),
    });
  } catch (err) {
    next(err);
  }
};

// POST /auth/login
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) throw new AppError('Email dan password wajib diisi', 400);

    const user = await User.findOne({ where: { email: email.toLowerCase().trim() } });
    if (!user || !(await user.validatePassword(password))) {
      throw new AppError('Email atau password salah', 401);
    }

    if (!user.is_active) throw new AppError('Akun dinonaktifkan. Hubungi support.', 403);

 // Update last seen
    await user.update({ last_seen_at: new Date() });

    const token        = signAccess(user.id);
    const refreshToken = await createRefreshToken(user.id, req.headers['user-agent']);

    res.json({
      message:       'Login berhasil',
      token,
      refresh_token: refreshToken,
      user:          user.toSafeJSON(),
    });
  } catch (err) {
    next(err);
  }
};

// POST /auth/refresh
exports.refresh = async (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) throw new AppError('Refresh token diperlukan', 400);

    let payload;
    try {
      payload = jwt.verify(refresh_token, REFRESH_SECRET);
    } catch {
      throw new AppError('Refresh token tidak valid atau sudah kadaluarsa', 401);
    }

    const stored = await RefreshToken.findOne({
      where: { token: refresh_token, is_revoked: false },
    });
    if (!stored || stored.expires_at < new Date()) {
      throw new AppError('Session tidak valid, silakan login ulang', 401);
    }

 // Rotate: revoke old, issue new
    await stored.update({ is_revoked: true });
    const user  = await User.findByPk(payload.id);
    const token = signAccess(user.id);
    const newRefresh = await createRefreshToken(user.id, req.headers['user-agent']);

    res.json({ token, refresh_token: newRefresh });
  } catch (err) {
    next(err);
  }
};

// POST /auth/logout
exports.logout = async (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (refresh_token) {
      await RefreshToken.update(
        { is_revoked: true },
        { where: { token: refresh_token } },
      );
    }
    res.json({ message: 'Logout berhasil' });
  } catch (err) {
    next(err);
  }
};

// GET /auth/me
exports.me = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.userId);
    if (!user) throw new AppError('User tidak ditemukan', 404);
    res.json({ user: user.toSafeJSON() });
  } catch (err) {
    next(err);
  }
};

// POST /auth/change-password
exports.changePassword = async (req, res, next) => {
  try {
    const { current_password, new_password } = req.body;
    if (!current_password || !new_password) {
      throw new AppError('Password saat ini dan password baru wajib diisi', 400);
    }
    if (new_password.length < 6) {
      throw new AppError('Password baru minimal 6 karakter', 400);
    }

    const user = await User.findByPk(req.userId);
    if (!user) throw new AppError('User tidak ditemukan', 404);

    const isValid = await user.validatePassword(current_password);
    if (!isValid) throw new AppError('Password saat ini tidak cocok', 400);

    user.password_hash = new_password;
    await user.save();

    res.json({ message: 'Password berhasil diperbarui' });
  } catch (err) {
    next(err);
  }
};

