const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/community.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/', authenticate, ctrl.getGroups);
router.post('/', authenticate, ctrl.createGroup);
router.get('/:id', authenticate, ctrl.getGroup);
router.post('/:id/join', authenticate, ctrl.joinGroup);
router.delete('/:id/leave', authenticate, ctrl.leaveGroup);

module.exports = router;