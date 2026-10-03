const db = require('../models');
const { Group, GroupMember, User } = db;
const { Op } = require('sequelize');

exports.getGroups = async (req, res) => {
  try {
    const groups = await Group.findAll({
      include: [{ model: GroupMember, as: 'members' }],
      order: [['createdAt', 'DESC']],
    });
    res.json({ data: groups });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getGroup = async (req, res) => {
  try {
    const group = await Group.findByPk(req.params.id, {
      include: [
        { model: GroupMember, as: 'members',
          include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'avatarUrl'] }] },
        { model: User, as: 'creator', attributes: ['id', 'fullName'] },
      ],
    });
    if (!group) return res.status(404).json({ message: 'Komunitas tidak ditemukan' });
    res.json({ data: group });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.createGroup = async (req, res) => {
  try {
    const { name, description, privacy = 'public' } = req.body;
    if (!name?.trim()) return res.status(400).json({ message: 'Nama komunitas diperlukan' });

    const group = await Group.create({ name, description, privacy, createdBy: req.userId });
    await GroupMember.create({ groupId: group.id, userId: req.userId, role: 'admin' });
    res.status(201).json({ data: group });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.joinGroup = async (req, res) => {
  try {
    const groupId = req.params.id;
    const exists = await GroupMember.findOne({ where: { groupId, userId: req.userId } });
    if (exists) return res.status(409).json({ message: 'Sudah bergabung' });

    const member = await GroupMember.create({ groupId, userId: req.userId, role: 'member' });
    res.status(201).json({ data: member });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.leaveGroup = async (req, res) => {
  try {
    const member = await GroupMember.findOne({ where: { groupId: req.params.id, userId: req.userId } });
    if (!member) return res.status(404).json({ message: 'Bukan anggota komunitas ini' });
    await member.destroy();
    res.json({ message: 'Berhasil keluar dari komunitas' });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};