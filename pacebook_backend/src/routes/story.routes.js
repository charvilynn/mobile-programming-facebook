const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/story.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/', authenticate, ctrl.createStory);
router.get('/', authenticate, ctrl.getStories);
router.delete('/:id', authenticate, ctrl.deleteStory);

module.exports = router;