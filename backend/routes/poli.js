const express = require('express');
const router = express.Router();
const poliController = require('../controllers/poliController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const { validatePoli } = require('../middleware/validationMiddleware');

router.get('/', verifyToken, poliController.getAll);
router.get('/:id', verifyToken, poliController.getById);
router.post('/', verifyToken, adminOnly, validatePoli, poliController.create);
router.put('/:id', verifyToken, adminOnly, validatePoli, poliController.update);
router.delete('/:id', verifyToken, adminOnly, poliController.delete);

module.exports = router;
