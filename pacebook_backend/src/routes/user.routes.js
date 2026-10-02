const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/search', authenticate, ctrl.searchUsers);
router.get('/suggestions', authenticate, ctrl.getSuggestions);
router.get('/me', authenticate, (req, res) => { req.params.id = 'me'; ctrl.getProfile(req, res); });
router.patch('/me', authenticate, ctrl.updateProfile);
router.get('/:id', authenticate, ctrl.getProfile);
router.get('/:id/connections', authenticate, ctrl.getConnections);
router.post('/:id/connect', authenticate, ctrl.sendConnectionRequest);
router.post('/:id/accept-connection', authenticate, ctrl.acceptConnectionByUserId);
router.post('/:id/reject-connection', authenticate, ctrl.rejectConnectionByUserId);
router.get('/connections/requests', authenticate, ctrl.getPendingRequests);
router.patch('/connections/:id', authenticate, ctrl.respondToConnection);

module.exports = router;