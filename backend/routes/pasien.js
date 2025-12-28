const express = require('express');
const router = express.Router();
const pasienController = require('../controllers/pasienController');
const { verifyToken, adminOrPetugas } = require('../middleware/authMiddleware');
const { validatePasien } = require('../middleware/validationMiddleware');

router.get('/', verifyToken, pasienController.getAll);
router.get('/:id', verifyToken, pasienController.getById);
router.post('/', verifyToken, adminOrPetugas, validatePasien, pasienController.create);
router.put('/:id', verifyToken, adminOrPetugas, validatePasien, pasienController.update);
router.delete('/:id', verifyToken, adminOrPetugas, pasienController.delete);

module.exports = router;
