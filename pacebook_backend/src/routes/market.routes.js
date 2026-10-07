const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/market.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/', authenticate, ctrl.getItems);
router.post('/', authenticate, ctrl.createItem);
router.get('/:id', authenticate, ctrl.getItem);
router.delete('/:id', authenticate, ctrl.deleteItem);

module.exports = router;
