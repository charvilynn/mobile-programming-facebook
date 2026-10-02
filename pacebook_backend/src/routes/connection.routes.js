const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/',                  authenticate, (req, res) => res.json({ message: 'Use POST /api/v1/users/:id/connect' }));
router.put('/:id/accept',         authenticate, ctrl.respondToConnection);
router.patch('/:id/accept',       authenticate, ctrl.respondToConnection);
router.put('/:id/reject',         authenticate, ctrl.respondToConnection);
router.patch('/:id/reject',       authenticate, ctrl.respondToConnection);
router.patch('/:id',              authenticate, ctrl.respondToConnection);
router.delete('/:id',             authenticate, ctrl.respondToConnection);
router.get('/requests',           authenticate, ctrl.getPendingRequests);
router.get('/my-connections',     authenticate, (req, res) => { req.params.id = req.userId; ctrl.getConnections(req, res); });

module.exports = router;