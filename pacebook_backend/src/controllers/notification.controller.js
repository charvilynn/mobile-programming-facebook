const db = require('../models');
const { Notification, User } = db;

// ─── GET /notifications ───────────────────────────────────────────────────────
exports.getNotifications = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = 30;
    const notifications = await Notification.findAndCountAll({
      where: { recipient_id: req.userId },
      include: [{ model: User, as: 'actor', attributes: ['id', 'full_name', 'username', 'avatar_url'] }],
      order: [['createdAt', 'DESC']],
      limit, offset: (page - 1) * limit,
    });
    res.json({ data: notifications.rows, meta: { total: notifications.count, page } });
  } catch (err) {
    console.error('getNotifications error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── GET /notifications/unread-count ─────────────────────────────────────────
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.count({ where: { recipient_id: req.userId, is_read: false } });
    res.json({ data: { count } });
  } catch (err) {
    console.error('getUnreadCount error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── PATCH /notifications/read-all ───────────────────────────────────────────
exports.markAllRead = async (req, res) => {
  try {
    await Notification.update({ is_read: true, read_at: new Date() }, { where: { recipient_id: req.userId, is_read: false } });
    res.json({ message: 'Semua notifikasi sudah ditandai dibaca' });
  } catch (err) {
    console.error('markAllRead error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── PATCH /notifications/:id/read ───────────────────────────────────────────
exports.markOneRead = async (req, res) => {
  try {
    const notif = await Notification.findOne({ where: { id: req.params.id, recipient_id: req.userId } });
    if (!notif) return res.status(404).json({ message: 'Notifikasi tidak ditemukan' });
    await notif.update({ is_read: true, read_at: new Date() });
    res.json({ data: notif });
  } catch (err) {
    console.error('markOneRead error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};