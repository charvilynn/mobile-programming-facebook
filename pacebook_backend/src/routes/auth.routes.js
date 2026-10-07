const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');

// POST /api/v1/auth/register
router.post('/register', ctrl.register);

// POST /api/v1/auth/login
router.post('/login', ctrl.login);

// POST /api/v1/auth/refresh
router.post('/refresh', ctrl.refresh);

// POST /api/v1/auth/logout
router.post('/logout', ctrl.logout);

// GET  /api/v1/auth/me  (protected)
router.get('/me', authenticate, ctrl.me);

module.exports = router;
