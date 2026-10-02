const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/post.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/', authenticate, ctrl.getFeed);
router.post('/', authenticate, ctrl.createPost);
router.get('/:id', authenticate, ctrl.getPost);
router.patch('/:id', authenticate, ctrl.updatePost);
router.delete('/:id', authenticate, ctrl.deletePost);
router.post('/:id/react', authenticate, ctrl.reactToPost);
router.get('/:id/comments', authenticate, ctrl.getComments);
router.post('/:id/comments', authenticate, ctrl.addComment);

module.exports = router;