const { MedicalRecord, Antrian, Pasien, Dokter } = require('../models');
const { Op } = require('sequelize');

async function create(req, res, next) {
  try {
    const { pasienId, poliId, anamnesa, diagnosa, tindakan, resep, visitDate } = req.body || {};

    if (!pasienId) {
      const error = new Error('pasienId is required');
      error.statusCode = 400;
      throw error;
    }

    // Permission: only dokter can create medical records
    const user = req.user || {};
    if (!user || user.role !== 'dokter') {
      const error = new Error('Only dokter can create medical records');
      error.statusCode = 403;
      throw error;
    }

    const dokterId = user.id;

    // Check if patient has ANY queue with this doctor (integrity check)
    // Relaxed constraint: Allow 'Selesai' status as well to permit adding records after closing.
    const activeQueue = await Antrian.findOne({
      where: {
        pasienId,
        dokterId,
        // status check removed to allow adding records for any queue entry (e.g. post-visit notes)
      },
      order: [['created_at', 'DESC']]
    });

    if (!activeQueue) {
      const error = new Error('Forbidden: No queue entry found for this patient with you.');
      error.statusCode = 403;
      throw error;
    }

    // Create medical record
    const rec = await MedicalRecord.create({
      pasienId,
      dokterId,
      poliId: poliId || null,
      anamnesa: anamnesa || null,
      diagnosa: diagnosa || null,
      tindakan: tindakan || null,
      resep: resep || null,
      visit_date: visitDate || new Date(),
    });

    // Mark the queue as completed if not already
    if (activeQueue.status !== 'Selesai') {
      activeQueue.status = 'Selesai';
      await activeQueue.save();
    }

    return res.status(201).json(rec);
  } catch (err) {
    next(err);
  }
}

// UPDATE and DELETE functions are DISABLED for dokter
// Medical records are immutable once created for data integrity

/* DISABLED - Medical records cannot be updated
async function update(req, res, next) {
  try {
    const error = new Error('Forbidden: Medical records cannot be updated for data integrity');
    error.statusCode = 403;
    throw error;
  } catch (err) {
    next(err);
  }
}
*/

/* DISABLED - Medical records cannot be deleted
async function remove(req, res, next) {
  try {
    const error = new Error('Forbidden: Medical records cannot be deleted for data integrity');
    error.statusCode = 403;
    throw error;
  } catch (err) {
    next(err);
  }
}
*/

async function listByPasien(req, res, next) {
  try {
    const { pasienId } = req.params;

    // Authorization: Pasien can only view their own records
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && parseInt(pasienId) !== userId) {
      const error = new Error('Forbidden: You can only view your own medical records');
      error.statusCode = 403;
      throw error;
    }

    const recs = await MedicalRecord.findAll({
      where: { pasienId },
      include: [
        { model: Dokter, attributes: ['id', 'nama'] },
        { model: Pasien, attributes: ['id', 'nama', 'nomor_rm'] }
      ],
      order: [['visit_date', 'DESC']]
    });

    return res.json(recs);
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const { id } = req.params;
    const rec = await MedicalRecord.findByPk(id, {
      include: [
        { model: Dokter, attributes: ['id', 'nama'] },
        { model: Pasien, attributes: ['id', 'nama', 'nomor_rm'] }
      ]
    });

    if (!rec) {
      const error = new Error('Medical record not found');
      error.statusCode = 404;
      throw error;
    }

    // Authorization: Pasien can only view their own records
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && rec.pasienId !== userId) {
      const error = new Error('Forbidden: You can only view your own medical records');
      error.statusCode = 403;
      throw error;
    }

    return res.json(rec);
  } catch (err) {
    next(err);
  }
}

// Export only CREATE and GET functions
module.exports = {
  create,
  listByPasien,
  getById
  // update and remove are intentionally not exported
};
