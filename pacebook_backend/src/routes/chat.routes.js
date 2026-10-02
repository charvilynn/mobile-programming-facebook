const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/chat.controller');
const { authenticate } = require('../middleware/auth.middleware');

// DM (Direct Message) routes — backed by the messages table (sender_id / receiver_id)
router.get('/dm/threads', authenticate, ctrl.getDmThreads);
router.get('/dm/:userId/messages', authenticate, ctrl.getDmMessages);
router.post('/dm/:userId/messages', authenticate, ctrl.sendDmMessage);
router.patch('/dm/:userId/read', authenticate, ctrl.markDmAsRead);

module.exports = router;