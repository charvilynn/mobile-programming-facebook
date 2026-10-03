const db = require('../models');
const { Post, Reaction, Comment, User, Connection } = db;
const { Op } = require('sequelize');

// ─── GET /posts (feed) ────────────────────────────────────────────────────────
exports.getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const targetUserId = req.query.userId || req.query.user_id;
    const whereClause = { is_deleted: false };

    if (targetUserId) {
      const targetId = parseInt(targetUserId);
      if (targetId !== req.userId) {
        // Check target user's profile privacy
        const targetUser = await User.findByPk(targetId, {
          attributes: ['id', 'profile_visibility'],
        });
        if (!targetUser) return res.status(404).json({ message: 'User tidak ditemukan' });

        const isFriend = await Connection.findOne({
          where: {
            status: 'accepted',
            [Op.or]: [
              { requester_id: req.userId, receiver_id: targetId },
              { requester_id: targetId, receiver_id: req.userId },
            ],
          },
        });

        const vis = targetUser.profile_visibility || 'public';
        if (vis === 'private' || (vis === 'friends' && !isFriend)) {
          // Account is restricted for non-friends
          return res.json({
            data: [],
            meta: { total: 0, page: 1, totalPages: 0 },
          });
        }
      }
      whereClause.user_id = targetUserId;
    } else {
      // Find my accepted friends
      const connections = req.userId ? await Connection.findAll({
        where: {
          status: 'accepted',
          [Op.or]: [
            { requester_id: req.userId },
            { receiver_id: req.userId },
          ],
        },
      }) : [];

      const friendIds = connections.map((c) =>
        c.requester_id === req.userId ? c.receiver_id : c.requester_id
      );

      whereClause[Op.or] = [
        { user_id: req.userId },
        { visibility: 'public' },
        ...(friendIds.length > 0
          ? [
              {
                user_id: { [Op.in]: friendIds },
                visibility: { [Op.in]: ['public', 'connections', 'friends'] },
              },
            ]
          : []),
      ];
    }

    const posts = await Post.findAndCountAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'full_name', 'username', 'avatar_url'],
        },
        {
          model: Comment,
          as: 'comments',
          where: { parent_id: null, is_deleted: false },
          required: false,
          limit: 2,
          include: [{ model: User, as: 'author', attributes: ['id', 'full_name', 'avatar_url'] }],
        },
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset,
      distinct: true,
    });

    res.json({
      data: posts.rows,
      meta: {
        total: posts.count,
        page,
        totalPages: Math.ceil(posts.count / limit),
      },
    });
  } catch (err) {
    console.error('getFeed error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── GET /posts/:id ───────────────────────────────────────────────────────────
exports.getPost = async (req, res) => {
  try {
    const post = await Post.findOne({
      where: { id: req.params.id, is_deleted: false },
      include: [
        { model: User, as: 'author', attributes: ['id', 'full_name', 'username', 'avatar_url'] },
      ],
    });
    if (!post) return res.status(404).json({ message: 'Post tidak ditemukan' });
    res.json({ data: post });
  } catch (err) {
    console.error('getPost error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── POST /posts ──────────────────────────────────────────────────────────────
exports.createPost = async (req, res) => {
  try {
    const content = req.body.content || req.body.contentText || '';
    const visibility = req.body.visibility || req.body.privacy || 'public';
    const mediaUrls = req.body.mediaUrls || req.body.media_urls || [];
    const taggedUsers = req.body.taggedUsers || req.body.tagged_users || [];
    const taggedUserIds = req.body.taggedUserIds || req.body.tagged_user_ids || (Array.isArray(taggedUsers) ? taggedUsers.map(u => typeof u === 'object' ? u.id : u) : []);
    const postType = mediaUrls.length > 0 ? 'image' : 'text';

    if (!content.trim() && mediaUrls.length === 0) {
      return res.status(400).json({ message: 'Post tidak boleh kosong' });
    }

    const post = await Post.create({
      user_id: req.userId,
      content: content.trim(),
      visibility,
      media_urls: mediaUrls,
      tagged_users: taggedUsers,
      post_type: postType,
    });

    const fullPost = await Post.findByPk(post.id, {
      include: [
        { model: User, as: 'author', attributes: ['id', 'full_name', 'username', 'avatar_url'] },
      ],
    });

    // Generate notifications for tagged users
    if (Array.isArray(taggedUserIds) && taggedUserIds.length > 0) {
      const author = fullPost.author;
      const authorName = author ? (author.full_name || author.username) : 'Seseorang';
      for (const taggedId of taggedUserIds) {
        const targetUserId = parseInt(taggedId);
        if (targetUserId && targetUserId !== req.userId) {
          await db.Notification.create({
            recipient_id: targetUserId,
            actor_id: req.userId,
            type: 'post_tag',
            reference_id: post.id,
            reference_type: 'post',
            body: `${authorName} menandai kamu dalam sebuah postingan.`,
            is_read: false,
          }).catch(e => console.error('Error creating tag notification:', e));
        }
      }
    }

    res.status(201).json({ data: fullPost });
  } catch (err) {
    console.error('createPost error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── PATCH /posts/:id ─────────────────────────────────────────────────────────
exports.updatePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post || post.is_deleted) return res.status(404).json({ message: 'Post tidak ditemukan' });
    if (post.user_id !== req.userId)
      return res.status(403).json({ message: 'Tidak diizinkan' });

    const content = req.body.content || req.body.contentText;
    const visibility = req.body.visibility || req.body.privacy;
    const mediaUrls = req.body.mediaUrls || req.body.media_urls;

    await post.update({
      ...(content !== undefined && { content }),
      ...(visibility !== undefined && { visibility }),
      ...(mediaUrls !== undefined && { media_urls: mediaUrls }),
      is_edited: true,
    });

    res.json({ data: post });
  } catch (err) {
    console.error('updatePost error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── DELETE /posts/:id ────────────────────────────────────────────────────────
exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post tidak ditemukan' });
    if (post.user_id !== req.userId)
      return res.status(403).json({ message: 'Tidak diizinkan' });

    await post.update({ is_deleted: true });
    res.json({ message: 'Post berhasil dihapus' });
  } catch (err) {
    console.error('deletePost error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── POST /posts/:id/react ────────────────────────────────────────────────────
exports.reactToPost = async (req, res) => {
  try {
    const reactionType = req.body.reactionType || req.body.type || 'like';
    const postId = req.params.id;

    const existing = await Reaction.findOne({
      where: { target_id: postId, target_type: 'post', user_id: req.userId },
    });

    if (existing) {
      if (existing.type === reactionType) {
        await existing.destroy();
        await Post.decrement('reaction_count', { by: 1, where: { id: postId } }).catch(() => {});
        return res.json({ message: 'Reaksi dihapus', data: null });
      }
      await existing.update({ type: reactionType });
      return res.json({ message: 'Reaksi diperbarui', data: existing });
    }

    const reaction = await Reaction.create({
      target_id: postId,
      target_type: 'post',
      user_id: req.userId,
      type: reactionType,
    });
    await Post.increment('reaction_count', { by: 1, where: { id: postId } }).catch(() => {});
    res.status(201).json({ data: reaction });
  } catch (err) {
    console.error('reactToPost error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── GET /posts/:id/comments ──────────────────────────────────────────────────
exports.getComments = async (req, res) => {
  try {
    const comments = await Comment.findAll({
      where: { post_id: req.params.id, parent_id: null, is_deleted: false },
      include: [
        { model: User, as: 'author', attributes: ['id', 'full_name', 'username', 'avatar_url'] },
        {
          model: Comment, as: 'replies',
          include: [{ model: User, as: 'author', attributes: ['id', 'full_name', 'username', 'avatar_url'] }],
        },
      ],
      order: [['createdAt', 'ASC']],
    });
    res.json({ data: comments });
  } catch (err) {
    console.error('getComments error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ─── POST /posts/:id/comments ─────────────────────────────────────────────────
exports.addComment = async (req, res) => {
  try {
    const content = req.body.contentText || req.body.content;
    const parentId = req.body.parentCommentId || req.body.parent_id || null;
    if (!content?.trim())
      return res.status(400).json({ message: 'Komentar tidak boleh kosong' });

    const comment = await Comment.create({
      post_id: req.params.id,
      user_id: req.userId,
      content: content.trim(),
      parent_id: parentId,
    });
    await Post.increment('comment_count', { by: 1, where: { id: req.params.id } }).catch(() => {});

    const full = await Comment.findByPk(comment.id, {
      include: [{ model: User, as: 'author', attributes: ['id', 'full_name', 'username', 'avatar_url'] }],
    });

    res.status(201).json({ data: full });
  } catch (err) {
    console.error('addComment error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};