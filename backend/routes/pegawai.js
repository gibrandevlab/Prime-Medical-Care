const express = require('express');
const router = express.Router();
const pegawaiController = require('../controllers/pegawaiController');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');
const { validatePegawai } = require('../middleware/validationMiddleware');

router.get('/', verifyToken, pegawaiController.getAll);
router.get('/:id', verifyToken, pegawaiController.getById);
router.post('/', verifyToken, adminOnly, validatePegawai, pegawaiController.create);
router.put('/:id', verifyToken, adminOnly, validatePegawai, pegawaiController.update);
router.delete('/:id', verifyToken, adminOnly, pegawaiController.delete);

module.exports = router;
