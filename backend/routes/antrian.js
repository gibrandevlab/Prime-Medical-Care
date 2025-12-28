const express = require('express');
const router = express.Router();
const antrianController = require('../controllers/antrianController');
const { verifyToken, adminOnly, petugasOnly } = require('../middleware/authMiddleware');
const { validateAntrian } = require('../middleware/validationMiddleware');

router.get('/', verifyToken, antrianController.list);
router.get('/dokter/:dokterId', verifyToken, antrianController.listByDokter);
router.get('/check-slot', verifyToken, antrianController.checkSlot);
router.get('/:id', verifyToken, antrianController.getById);

// Only admin and petugas can create antrian - pasien CANNOT create their own queue
router.post('/', verifyToken, petugasOnly, validateAntrian, antrianController.create);

router.put('/:id/status', verifyToken, antrianController.updateStatus);

module.exports = router;
