const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/event.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/', authenticate, ctrl.getEvents);
router.post('/', authenticate, ctrl.createEvent);
router.get('/:id', authenticate, ctrl.getEvent);
router.post('/:id/attend', authenticate, ctrl.attendEvent);

module.exports = router;