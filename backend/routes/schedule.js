const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
const { verifyToken, adminOnly, doctorOnly } = require('../middleware/authMiddleware');

// Specific routes MUST come before parameterized routes
router.get('/pending-requests', verifyToken, adminOnly, scheduleController.getPendingRequests);
router.get('/available-substitutes', verifyToken, doctorOnly, scheduleController.getAvailableSubstitutes);
router.get('/:dokterId', verifyToken, scheduleController.getSchedules);
router.post('/override', verifyToken, adminOnly, scheduleController.addOverride);
router.post('/request-override', verifyToken, doctorOnly, scheduleController.requestOverride);
router.put('/approve-override/:id', verifyToken, adminOnly, scheduleController.approveOverride);
router.delete('/override/:id', verifyToken, adminOnly, scheduleController.deleteOverride);

module.exports = router;
