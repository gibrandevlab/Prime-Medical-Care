const express = require('express');
const router = express.Router();
const dokterController = require('../controllers/dokterController');
const { verifyToken, adminOnly, adminOrPetugas } = require('../middleware/authMiddleware');
const { validateDokter } = require('../middleware/validationMiddleware');

router.get('/', verifyToken, adminOrPetugas, dokterController.getAll);
router.get('/:id', verifyToken, adminOrPetugas, dokterController.getById);
router.post('/', verifyToken, adminOnly, validateDokter, dokterController.create);
router.put('/:id', verifyToken, adminOnly, validateDokter, dokterController.update);
router.delete('/:id', verifyToken, adminOnly, dokterController.delete);

module.exports = router;
