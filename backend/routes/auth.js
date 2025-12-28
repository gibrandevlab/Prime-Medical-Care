const express = require('express');
const router = express.Router();
const { login } = require('../controllers/authController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');

router.post('/login', login);

module.exports = router;
