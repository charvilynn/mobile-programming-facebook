const jwt = require('jsonwebtoken');
const { AppError } = require('./error.middleware');

/**
 * JWT auth guard — attaches req.userId to authenticated requests
 */
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Token tidak ditemukan. Silakan login.', 401));
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.id;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new AppError('Token kadaluarsa', 401));
    }
    return next(new AppError('Token tidak valid', 401));
  }
};

module.exports = { authenticate };