const db = require('../models');
const { Message, User } = db;
const { Op } = require('sequelize');

// ─── GET /chat/dm/:userId/messages ────────────────────────────────────────────
// Returns the conversation thread between the logged-in user and :userId
exports.getDmMessages = async (req, res) => {
  try {
    const myId = req.userId;
    const otherId = parseInt(req.params.userId);
    if (!otherId || otherId === myId) {
      return res.status(400).json({ message: 'userId tidak valid' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = 50;
    const offset = (page - 1) * limit;

    const messages = await Message.findAndCountAll({
      where: {
        [Op.or]: [
          { sender_id: myId, receiver_id: otherId },
          { sender_id: otherId, receiver_id: myId },
        ],
        is_deleted: false,
      },
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'full_name', 'avatar_url'],
        },
      ],
      order: [['createdAt', 'ASC']],
      limit,
      offset,
    });

    res.json({
      data: messages.rows,
      meta: { total: messages.count, page },
    });
  } catch (err) {
    console.error('[chat] getDmMessages error:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── POST /chat/dm/:userId/messages ───────────────────────────────────────────
// Sends a new DM from logged-in user to :userId
exports.sendDmMessage = async (req, res) => {
  try {
    const myId = req.userId;
    const otherId = parseInt(req.params.userId);
    if (!otherId || otherId === myId) {
      return res.status(400).json({ message: 'userId tidak valid' });
    }

    const { content, media_url } = req.body;
    if (!content && !media_url) {
      return res.status(400).json({ message: 'Pesan tidak boleh kosong' });
    }

    // Verify the other user exists
    const other = await User.findByPk(otherId, { attributes: ['id'] });
    if (!other) return res.status(404).json({ message: 'Pengguna tidak ditemukan' });

    const msg = await Message.create({
      sender_id: myId,
      receiver_id: otherId,
      content: content || '',
      media_url: media_url || null,
      is_read: false,
    });

    const full = await Message.findByPk(msg.id, {
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'full_name', 'avatar_url'],
        },
      ],
    });

    res.status(201).json({ data: full });
  } catch (err) {
    console.error('[chat] sendDmMessage error:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── PATCH /chat/dm/:userId/read ──────────────────────────────────────────────
// Marks all messages from :userId to the logged-in user as read
exports.markDmAsRead = async (req, res) => {
  try {
    const myId = req.userId;
    const otherId = parseInt(req.params.userId);

    await Message.update(
      { is_read: true, read_at: new Date() },
      {
        where: {
          sender_id: otherId,
          receiver_id: myId,
          is_read: false,
        },
      }
    );

    res.json({ message: 'Pesan ditandai sudah dibaca' });
  } catch (err) {
    console.error('[chat] markDmAsRead error:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── GET /chat/dm/threads ─────────────────────────────────────────────────────
// Returns unique conversation partners for the logged-in user (inbox list)
exports.getDmThreads = async (req, res) => {
  try {
    const myId = req.userId;

    // Find all unique conversation partners
    const sent = await Message.findAll({
      attributes: ['receiver_id'],
      where: { sender_id: myId, is_deleted: false },
      group: ['receiver_id'],
      raw: true,
    });
    const received = await Message.findAll({
      attributes: ['sender_id'],
      where: { receiver_id: myId, is_deleted: false },
      group: ['sender_id'],
      raw: true,
    });

    const partnerIds = [
      ...new Set([
        ...sent.map((r) => r.receiver_id),
        ...received.map((r) => r.sender_id),
      ]),
    ].filter((id) => id !== myId);

    // For each partner, get the latest message
    const threads = await Promise.all(
      partnerIds.map(async (partnerId) => {
        const lastMsg = await Message.findOne({
          where: {
            [Op.or]: [
              { sender_id: myId, receiver_id: partnerId },
              { sender_id: partnerId, receiver_id: myId },
            ],
            is_deleted: false,
          },
          include: [
            {
              model: User,
              as: 'sender',
              attributes: ['id', 'full_name', 'avatar_url'],
            },
          ],
          order: [['createdAt', 'DESC']],
        });

        const partner = await User.findByPk(partnerId, {
          attributes: ['id', 'full_name', 'username', 'avatar_url'],
        });

        const unreadCount = await Message.count({
          where: { sender_id: partnerId, receiver_id: myId, is_read: false },
        });

        return { partner, lastMessage: lastMsg, unreadCount };
      })
    );

    res.json({ data: threads.filter((t) => t.partner && t.lastMessage) });
  } catch (err) {
    console.error('[chat] getDmThreads error:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
};