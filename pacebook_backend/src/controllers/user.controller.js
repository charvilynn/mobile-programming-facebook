const db = require('../models');
const { User, Connection } = db;
const { Op } = require('sequelize');

exports.getProfile = async (req, res) => {
  try {
    const userId = req.params.id === 'me' ? req.userId : parseInt(req.params.id);
    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password_hash', 'otp_code', 'otp_expires_at'] },
    });
    if (!user) return res.status(404).json({ message: 'User tidak ditemukan' });

    const isOwnProfile = userId === req.userId;

    let connectionStatus = 'none';
    let connectionId = null;
    if (!isOwnProfile) {
      const conn = await db.Connection.findOne({
        where: {
          [Op.or]: [
            { requester_id: req.userId, receiver_id: userId },
            { requester_id: userId, receiver_id: req.userId },
          ],
        },
      });
      if (conn) {
        connectionId = conn.id;
        if (conn.status === 'accepted') {
          connectionStatus = 'connected';
        } else if (conn.status === 'pending') {
          connectionStatus = conn.requester_id === req.userId ? 'pending_sent' : 'pending_received';
        }
      }
    }

    const visibility = user.profile_visibility || 'public';
    const isFriend = connectionStatus === 'connected';

    let canSeeFullProfile = true;
    let isPrivate = false;

    if (isOwnProfile) {
      canSeeFullProfile = true;
      isPrivate = false;
    } else if (visibility === 'private') {
      canSeeFullProfile = false;
      isPrivate = true;
    } else if (visibility === 'friends') {
      canSeeFullProfile = isFriend;
      isPrivate = !isFriend;
    } else {
      canSeeFullProfile = true;
      isPrivate = false;
    }

    const userData = user.toJSON();

    if (!canSeeFullProfile) {
      // Return limited public data only — hide avatar, cover, bio, details
      return res.json({
        data: {
          id: userData.id,
          username: userData.username,
          full_name: userData.full_name,
          avatar_url: null,
          bio: null,
          cover_url: null,
          location: null,
          work: null,
          education: null,
          birthday: null,
          gender: null,
          thought_note: null,
          profile_visibility: userData.profile_visibility,
          postCount: 0,
          connectionCount: 0,
          connectionStatus,
          connectionId,
          isPrivate: true,
        },
      });
    }

    const postCount = await db.Post.count({ where: { user_id: userId, is_deleted: false } }).catch(() => 0);
    const connectionCount = await db.Connection.count({
      where: {
        status: 'accepted',
        [Op.or]: [{ requester_id: userId }, { receiver_id: userId }],
      },
    }).catch(() => 0);

    res.json({
      data: {
        ...userData,
        postCount,
        connectionCount,
        connectionStatus,
        connectionId,
        isPrivate: false,
      },
    });
  } catch (err) {
    console.error('getProfile error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const {
      fullName, full_name, bio, location, work, education,
      avatar_url, cover_url, thought_note, thoughtNote,
      birthday, gender,
      profile_visibility, profileVisibility,
    } = req.body;
    const user = await User.findByPk(req.userId);
    if (!user) return res.status(404).json({ message: 'User tidak ditemukan' });

    const updatedName = full_name || fullName;
    const avatar = avatar_url !== undefined ? avatar_url : req.body.avatarUrl;
    const cover = cover_url !== undefined ? cover_url : req.body.coverUrl;
    const note = thought_note !== undefined ? thought_note : thoughtNote;
    const visibility = profile_visibility !== undefined ? profile_visibility : profileVisibility;

    await user.update({
      ...(updatedName && { full_name: updatedName }),
      ...(bio !== undefined && { bio }),
      ...(avatar !== undefined && { avatar_url: avatar }),
      ...(cover !== undefined && { cover_url: cover }),
      ...(note !== undefined && { thought_note: note }),
      ...(birthday !== undefined && { birthday }),
      ...(gender !== undefined && { gender }),
      ...(location !== undefined && { location }),
      ...(work !== undefined && { work }),
      ...(education !== undefined && { education }),
      ...(visibility !== undefined && { profile_visibility: visibility }),
    });
    const { password_hash: _, otp_code: __, otp_expires_at: ___, ...safe } = user.toJSON();
    res.json({ data: safe });
  } catch (err) {
    console.error('updateProfile error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.searchUsers = async (req, res) => {
  try {
    const q = req.query.q?.trim();
    if (!q) return res.json({ data: [] });

    const users = await User.findAll({
      where: {
        [Op.or]: [
          { full_name: { [Op.like]: `%${q}%` } },
          { username: { [Op.like]: `%${q}%` } },
        ],
        id: { [Op.ne]: req.userId },
      },
      attributes: ['id', 'full_name', 'username', 'avatar_url', 'bio', 'profile_visibility'],
      limit: 20,
    });

    const userIds = users.map((u) => u.id);
    const connections = userIds.length > 0 ? await Connection.findAll({
      where: {
        status: 'accepted',
        [Op.or]: [
          { requester_id: req.userId, receiver_id: userIds },
          { requester_id: userIds, receiver_id: req.userId },
        ],
      },
    }) : [];

    const friendIds = new Set(
      connections.map((c) =>
        c.requester_id === req.userId ? c.receiver_id : c.requester_id
      )
    );

    const data = users.map((u) => {
      const vis = u.profile_visibility || 'public';
      const isFriend = friendIds.has(u.id);
      const isRestricted = vis === 'private' || (vis === 'friends' && !isFriend);
      return {
        id: u.id,
        full_name: u.full_name,
        username: u.username,
        avatar_url: isRestricted ? null : u.avatar_url,
        bio: isRestricted ? null : u.bio,
      };
    });

    res.json({ data });
  } catch (err) {
    console.error('searchUsers error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getSuggestions = async (req, res) => {
  try {
    const existingConnections = await Connection.findAll({
      where: {
        [Op.or]: [
          { requester_id: req.userId },
          { receiver_id: req.userId },
        ],
      },
      attributes: ['id', 'requester_id', 'receiver_id', 'status'],
    });

    const connectionMap = new Map();
    for (const c of existingConnections) {
      const isRequester = c.requester_id === req.userId;
      const otherId = isRequester ? c.receiver_id : c.requester_id;
      let status = c.status;
      if (c.status === 'pending') {
        status = isRequester ? 'pending_sent' : 'pending_received';
      }
      connectionMap.set(otherId, { status, connectionId: c.id });
    }

    const users = await User.findAll({
      where: {
        id: { [Op.ne]: req.userId },
        is_active: true,
      },
      attributes: ['id', 'full_name', 'username', 'avatar_url', 'bio', 'profile_visibility', 'createdAt'],
      limit: 50,
      order: [['id', 'DESC']],
    });

    const suggestions = users.map((u) => {
      const connInfo = connectionMap.get(u.id);
      const isFriend = connInfo ? connInfo.status === 'connected' : false;
      const vis = u.profile_visibility || 'public';
      const isRestricted = vis === 'private' || (vis === 'friends' && !isFriend);
      return {
        ...u.toJSON(),
        avatar_url: isRestricted ? null : u.avatar_url,
        connection_status: connInfo ? connInfo.status : 'none',
        connection_id: connInfo ? connInfo.connectionId : null,
      };
    });

    res.json({ data: suggestions });
  } catch (err) {
    console.error('getSuggestions error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getConnections = async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const connections = await Connection.findAll({
      where: {
        [Op.or]: [{ requester_id: userId }, { receiver_id: userId }],
        status: 'accepted',
      },
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'username', 'avatar_url', 'bio'] },
        { model: User, as: 'receiver', attributes: ['id', 'full_name', 'username', 'avatar_url', 'bio'] },
      ],
    });

    const peers = connections.map((c) =>
      c.requester_id === userId ? c.receiver : c.requester
    ).filter(Boolean);

    res.json({ data: peers });
  } catch (err) {
    console.error('getConnections error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.sendConnectionRequest = async (req, res) => {
  try {
    const friendId = parseInt(req.params.id);
    if (friendId === req.userId)
      return res.status(400).json({ message: 'Tidak bisa menghubungkan dengan diri sendiri' });

    const exists = await Connection.findOne({
      where: {
        [Op.or]: [
          { requester_id: req.userId, receiver_id: friendId },
          { requester_id: friendId, receiver_id: req.userId },
        ],
      },
    });
    if (exists) return res.status(409).json({ message: 'Koneksi sudah ada atau sedang menunggu' });

    const conn = await Connection.create({
      requester_id: req.userId,
      receiver_id: friendId,
      status: 'pending',
    });

    await db.Notification.create({
      recipient_id: friendId,
      actor_id: req.userId,
      type: 'friend_request',
      body: 'mengirimkan permintaan pertemanan',
      reference_id: req.userId,
      reference_type: 'user',
    }).catch(() => {});

    res.status(201).json({ data: conn });
  } catch (err) {
    console.error('sendConnectionRequest error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.acceptConnectionByUserId = async (req, res) => {
  try {
    const friendId = parseInt(req.params.id);
    const conn = await Connection.findOne({
      where: {
        requester_id: friendId,
        receiver_id: req.userId,
        status: 'pending',
      },
    });

    if (!conn) {
      const alreadyAccepted = await Connection.findOne({
        where: {
          [Op.or]: [
            { requester_id: friendId, receiver_id: req.userId },
            { requester_id: req.userId, receiver_id: friendId },
          ],
          status: 'accepted',
        },
      });
      if (alreadyAccepted) {
        return res.json({ message: 'Sudah terhubung', data: alreadyAccepted });
      }
      return res.status(404).json({ message: 'Permintaan pertemanan tidak ditemukan' });
    }

    await conn.update({ status: 'accepted', accepted_at: new Date() });

    await db.Notification.update(
      { is_read: true, read_at: new Date() },
      {
        where: {
          recipient_id: req.userId,
          actor_id: friendId,
          type: { [Op.in]: ['friend_request', 'connection_request'] },
        },
      }
    ).catch(() => {});

    await db.Notification.create({
      recipient_id: friendId,
      actor_id: req.userId,
      type: 'connection_accepted',
      body: 'menerima permintaan pertemanan Anda',
      reference_id: req.userId,
      reference_type: 'user',
    }).catch(() => {});

    res.json({ message: 'Permintaan pertemanan diterima', data: conn });
  } catch (err) {
    console.error('acceptConnectionByUserId error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.rejectConnectionByUserId = async (req, res) => {
  try {
    const friendId = parseInt(req.params.id);
    const conn = await Connection.findOne({
      where: {
        requester_id: friendId,
        receiver_id: req.userId,
        status: 'pending',
      },
    });

    if (!conn) {
      return res.status(404).json({ message: 'Permintaan pertemanan tidak ditemukan' });
    }

    await conn.destroy();

    await db.Notification.update(
      { is_read: true, read_at: new Date() },
      {
        where: {
          recipient_id: req.userId,
          actor_id: friendId,
          type: { [Op.in]: ['friend_request', 'connection_request'] },
        },
      }
    ).catch(() => {});

    res.json({ message: 'Permintaan pertemanan ditolak' });
  } catch (err) {
    console.error('rejectConnectionByUserId error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.respondToConnection = async (req, res) => {
  try {
    const action = req.body?.action || (req.path.includes('reject') ? 'reject' : 'accept');
    const conn = await Connection.findByPk(req.params.id);
    if (!conn) return res.status(404).json({ message: 'Permintaan tidak ditemukan' });
    if (conn.receiver_id !== req.userId)
      return res.status(403).json({ message: 'Tidak diizinkan' });

    if (action === 'accept') {
      await conn.update({ status: 'accepted', accepted_at: new Date() });

      await db.Notification.update(
        { is_read: true, read_at: new Date() },
        {
          where: {
            recipient_id: req.userId,
            actor_id: conn.requester_id,
            type: { [Op.in]: ['friend_request', 'connection_request'] },
          },
        }
      ).catch(() => {});

      await db.Notification.create({
        recipient_id: conn.requester_id,
        actor_id: req.userId,
        type: 'connection_accepted',
        body: 'menerima permintaan pertemanan Anda',
        reference_id: req.userId,
        reference_type: 'user',
      }).catch(() => {});

      return res.json({ message: 'Permintaan pertemanan diterima', data: conn });
    }
    await conn.destroy();
    res.json({ message: 'Permintaan ditolak' });
  } catch (err) {
    console.error('respondToConnection error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getPendingRequests = async (req, res) => {
  try {
    const requests = await Connection.findAll({
      where: { receiver_id: req.userId, status: 'pending' },
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'username', 'avatar_url', 'bio'] },
      ],
    });
    res.json({ data: requests });
  } catch (err) {
    console.error('getPendingRequests error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};