const db = require('../models');
const { Event, EventAttendee, User } = db;
const { Op } = require('sequelize');

exports.getEvents = async (req, res) => {
  try {
    const events = await Event.findAll({
      include: [
        { model: EventAttendee, as: 'attendees' },
        { model: User, as: 'creator', attributes: ['id', 'fullName', 'avatarUrl'] },
      ],
      order: [['startTime', 'ASC']],
    });
    res.json({ data: events });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getEvent = async (req, res) => {
  try {
    const event = await Event.findByPk(req.params.id, {
      include: [
        { model: User, as: 'creator', attributes: ['id', 'fullName', 'avatarUrl'] },
        {
          model: EventAttendee, as: 'attendees',
          include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'avatarUrl'] }],
        },
      ],
    });
    if (!event) return res.status(404).json({ message: 'Agenda tidak ditemukan' });
    res.json({ data: event });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.createEvent = async (req, res) => {
  try {
    const { name, description, location, startTime, endTime } = req.body;
    if (!name || !startTime) return res.status(400).json({ message: 'Nama dan waktu mulai diperlukan' });

    const event = await Event.create({ name, description, location, startTime, endTime, createdBy: req.userId });
    await EventAttendee.create({ eventId: event.id, userId: req.userId, status: 'going' });
    res.status(201).json({ data: event });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

exports.attendEvent = async (req, res) => {
  try {
    const { status = 'going' } = req.body; 
    const existing = await EventAttendee.findOne({ where: { eventId: req.params.id, userId: req.userId } });

    if (existing) {
      await existing.update({ status });
      return res.json({ data: existing });
    }
    const attendee = await EventAttendee.create({ eventId: req.params.id, userId: req.userId, status });
    res.status(201).json({ data: attendee });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};