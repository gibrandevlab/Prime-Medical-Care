const express = require('express');
const router = express.Router();
const medicalRecordController = require('../controllers/medicalRecordController');
const { verifyToken, doctorOnly } = require('../middleware/authMiddleware');

// Medical records are immutable - only CREATE and GET allowed
router.post('/', verifyToken, doctorOnly, medicalRecordController.create);
router.get('/pasien/:pasienId', verifyToken, medicalRecordController.listByPasien);
router.get('/:id', verifyToken, medicalRecordController.getById);

// UPDATE and DELETE routes are DISABLED for data integrity
// router.put('/:id', verifyToken, doctorOnly, medicalRecordController.update);
// router.delete('/:id', verifyToken, doctorOnly, medicalRecordController.remove);

module.exports = router;
