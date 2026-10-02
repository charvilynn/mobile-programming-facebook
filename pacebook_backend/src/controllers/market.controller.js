const db = require('../models');
const { MarketItem, User } = db;
const { Op } = require('sequelize');

exports.getItems = async (req, res) => {
  try {
    const { category, q, page = 1, limit = 20 } = req.query;
    const where = {};
    if (category && category !== 'Semua') where.category = category;
    if (q) where.title = { [Op.like]: `%${q}%` };

    const items = await MarketItem.findAndCountAll({
      where,
      include: [{ model: User, as: 'seller', attributes: ['id', 'fullName', 'username', 'avatarUrl'] }],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit),
    });
    res.json({ data: items.rows, meta: { total: items.count, page: parseInt(page) } });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getItem = async (req, res) => {
  try {
    const item = await MarketItem.findByPk(req.params.id, {
      include: [{ model: User, as: 'seller', attributes: ['id', 'fullName', 'username', 'avatarUrl'] }],
    });
    if (!item) return res.status(404).json({ message: 'Barang tidak ditemukan' });
    res.json({ data: item });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.createItem = async (req, res) => {
  try {
    const { title, description, price, category, condition, imageUrl } = req.body;
    if (!title || !price) return res.status(400).json({ message: 'Judul dan harga diperlukan' });

    const item = await MarketItem.create({
      sellerId: req.userId, title, description, price, category, condition, imageUrl,
    });
    res.status(201).json({ data: item });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.deleteItem = async (req, res) => {
  try {
    const item = await MarketItem.findByPk(req.params.id);
    if (!item) return res.status(404).json({ message: 'Barang tidak ditemukan' });
    if (item.sellerId !== req.userId) return res.status(403).json({ message: 'Tidak diizinkan' });
    await item.destroy();
    res.json({ message: 'Barang berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};