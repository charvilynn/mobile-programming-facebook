const db = require('../models');
const { Story, User, Connection } = db;
const { Op } = require('sequelize');

exports.createStory = async (req, res) => {
  try {
    const { media_url, text_content, bg_color, type } = req.body;

    if (!media_url && !text_content) {
      return res.status(400).json({ message: 'Konten story tidak boleh kosong' });
    }

    const expires_at = new Date(Date.now() + 24 * 60 * 60 * 1000);

    const story = await Story.create({
      user_id: req.userId,
      media_url: media_url || null,
      text_content: text_content || null,
      bg_color: bg_color || '#0A192F',
      type: type || (media_url ? 'image' : 'text'),
      expires_at,
    });

    const populated = await Story.findByPk(story.id, {
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'full_name', 'username', 'avatar_url'],
        },
      ],
    });

    res.status(201).json({ data: populated });
  } catch (err) {
    console.error('createStory error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Returns active stories grouped by user/author, respecting privacy settings
exports.getStories = async (req, res) => {
  try {
    const now = new Date();
    const myId = req.userId;

    // 1. Get friend IDs for current user
    const connections = myId ? await Connection.findAll({
      where: {
        status: 'accepted',
        [Op.or]: [
          { requester_id: myId },
          { receiver_id: myId },
        ],
      },
    }) : [];

    const friendIds = new Set(
      connections.map((c) =>
        c.requester_id === myId ? c.receiver_id : c.requester_id
      )
    );

    const stories = await Story.findAll({
      where: {
        expires_at: { [Op.gt]: now },
      },
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'full_name', 'username', 'avatar_url', 'profile_visibility'],
        },
      ],
      order: [['createdAt', 'DESC']],
    });

    // Group stories by author
    const map = new Map();

    for (const s of stories) {
      const author = s.author;
      if (!author) continue;

      const isOwn = author.id === myId;
      const vis = author.profile_visibility || 'public';
      const isFriend = friendIds.has(author.id);

      if (vis === 'private' && !isOwn) continue;
      if (vis === 'friends' && !isOwn && !isFriend) continue;

      if (!map.has(author.id)) {
        map.set(author.id, {
          userId: author.id,
          username: author.username,
          authorName: author.full_name,
          avatarUrl: author.avatar_url,
          isOwn,
          hasUnseen: true,
          latestAt: s.createdAt,
          items: [],
        });
      }

      map.get(author.id).items.push({
        id: s.id,
        mediaUrl: s.media_url,
        textContent: s.text_content,
        bgColor: s.bg_color,
        type: s.type,
        createdAt: s.createdAt,
        expiresAt: s.expires_at,
      });
    }

    const groups = Array.from(map.values());

    // Sort so user's own stories come first, then latest
    groups.sort((a, b) => {
      if (a.isOwn && !b.isOwn) return -1;
      if (!a.isOwn && b.isOwn) return 1;
      return new Date(b.latestAt) - new Date(a.latestAt);
    });

    res.json({ data: groups });
  } catch (err) {
    console.error('getStories error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.deleteStory = async (req, res) => {
  try {
    const story = await Story.findByPk(req.params.id);
    if (!story) return res.status(404).json({ message: 'Story tidak ditemukan' });

    if (story.user_id !== req.userId) {
      return res.status(403).json({ message: 'Tidak diizinkan menghapus story ini' });
    }

    await story.destroy();
    res.json({ message: 'Story berhasil dihapus' });
  } catch (err) {
    console.error('deleteStory error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};