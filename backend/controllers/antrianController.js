const { Antrian, Pasien, Dokter, Poli } = require('../models');
const { Op } = require('sequelize');
const { validationResult } = require('express-validator');
const { sequelize } = require('../models');

const AvailabilityService = require('../services/availabilityService');

function pad(n, width = 3) {
  return String(n).padStart(width, '0');
}

async function checkSlot(req, res, next) {
  try {
    const { dokterId, date } = req.query;
    if (!dokterId || !date) {
      const error = new Error('dokterId and date required');
      error.statusCode = 400;
      throw error;
    }

    const availability = await AvailabilityService.checkAvailability(dokterId, date);
    return res.json(availability);
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  // Start transaction
  const t = await sequelize.transaction();

  try {
    // Check validation results from middleware
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        error: 'ValidationError',
        details: errors.array()
      });
    }

    const { pasienId, poliId, dokterId, scheduledAt } = req.body || {};

    // Authorization: Pasien can only create antrian for themselves
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && parseInt(pasienId) !== userId) {
      await t.rollback();
      const error = new Error('Forbidden: You can only create antrian for yourself');
      error.statusCode = 403;
      throw error;
    }

    if (!pasienId || !poliId) {
      await t.rollback();
      const error = new Error('pasienId and poliId are required');
      error.statusCode = 400;
      throw error;
    }

    // Validate Schedule if doctor is selected
    if (dokterId && scheduledAt) {
      // 1. Check General Availability (Is doctor working today?)
      const avail = await AvailabilityService.checkAvailability(dokterId, scheduledAt);
      if (!avail.available) {
        await t.rollback();
        const error = new Error(`Dokter tidak tersedia: ${avail.note}`);
        error.statusCode = 400;
        throw error;
      }

      // 2. Check Time Slot Conflict (Is this specific time taken?)
      const slot = await AvailabilityService.checkSlotConflict(dokterId, scheduledAt);
      if (slot.conflict) {
        await t.rollback();
        const error = new Error(slot.note);
        error.statusCode = 400;
        throw error;
      }
    }

    // Create antrian with transaction
    const entry = await Antrian.create({
      ticket_number: 'TBD',
      pasienId,
      poliId,
      dokterId: dokterId || null,
      scheduled_at: scheduledAt || null
    }, { transaction: t });

    // Generate ticket based on poliId and id
    const prefix = String.fromCharCode(65 + ((poliId || 0) % 26));
    const ticket = `${prefix}-${pad(entry.id, 3)}`;
    entry.ticket_number = ticket;
    await entry.save({ transaction: t });

    // Commit transaction
    await t.commit();

    return res.status(201).json(entry);
  } catch (err) {
    // Rollback transaction on error
    await t.rollback();
    next(err);
  }
}

async function list(req, res, next) {
  try {
    const { status } = req.query;
    const where = {};
    if (status) where.status = status;

    // Authorization: Pasien can only view their own antrian
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien') {
      where.pasienId = userId;
    } else if (userRole === 'dokter') {
      where.dokterId = userId;
    }

    // Filter for TODAY only
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    where[Op.or] = [
      { scheduled_at: { [Op.between]: [startOfDay, endOfDay] } },
      {
        [Op.and]: [
          { scheduled_at: null },
          { created_at: { [Op.between]: [startOfDay, endOfDay] } }
        ]
      }
    ];

    const items = await Antrian.findAll({
      where,
      include: [
        { model: Pasien, as: 'pasien' },
        { model: Dokter, as: 'dokter' },
        { model: Poli, as: 'poli' }
      ],
      order: [
        [sequelize.literal("FIELD(status, 'Dipanggil', 'Menunggu', 'Selesai', 'Batal')"), 'ASC'],
        ['scheduled_at', 'ASC'],
        ['created_at', 'ASC']
      ]
    });
    return res.json(items);
  } catch (err) {
    next(err);
  }
}

async function listByDokter(req, res, next) {
  try {
    const { dokterId } = req.params;

    // Authorization: Only dokter can view their own antrian list, or admin/petugas can view any
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'dokter' && parseInt(dokterId) !== userId) {
      const error = new Error('Forbidden: You can only view your own antrian list');
      error.statusCode = 403;
      throw error;
    }

    // Automatic calling logic: if no currently 'Dipanggil', pick next 'Menunggu' whose scheduled_at is null or due
    // Automatic calling logic REMOVED. Status update is now triggered by frontend action (onTap).

    // Filter for TODAY only
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const whereClause = {
      dokterId,
      [Op.or]: [
        { scheduled_at: { [Op.between]: [startOfDay, endOfDay] } },
        {
          [Op.and]: [
            { scheduled_at: null },
            { created_at: { [Op.between]: [startOfDay, endOfDay] } }
          ]
        }
      ]
    };

    const items = await Antrian.findAll({
      where: whereClause,
      include: [{ model: Pasien, as: 'pasien' }],
      order: [
        [sequelize.literal("FIELD(status, 'Dipanggil', 'Menunggu', 'Selesai', 'Batal')"), 'ASC'],
        ['scheduled_at', 'ASC'],
        ['created_at', 'ASC']
      ]
    });
    return res.json(items);
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const { id } = req.params;
    const item = await Antrian.findByPk(id, {
      include: [{ model: Pasien, as: 'pasien' }, { model: Dokter, as: 'dokter' }, { model: Poli, as: 'poli' }]
    });

    if (!item) {
      const error = new Error('Antrian not found');
      error.statusCode = 404;
      throw error;
    }

    // Authorization: Pasien can only view their own antrian
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && item.pasienId !== userId) {
      const error = new Error('Forbidden: You can only view your own antrian');
      error.statusCode = 403;
      throw error;
    }

    // Authorization: Dokter can only view antrian assigned to them
    if (userRole === 'dokter' && item.dokterId !== userId) {
      const error = new Error('Forbidden: You can only view antrian assigned to you');
      error.statusCode = 403;
      throw error;
    }

    return res.json(item);
  } catch (err) {
    next(err);
  }
}

async function updateStatus(req, res, next) {
  try {
    const { id } = req.params;
    const { status } = req.body || {};
    const item = await Antrian.findByPk(id);

    if (!item) {
      const error = new Error('Antrian not found');
      error.statusCode = 404;
      throw error;
    }

    // Authorization: dokter assigned or petugas/admin
    const user = req.user || {};
    const role = user.role;

    if (role === 'dokter') {
      if (item.dokterId && item.dokterId !== user.id) {
        const error = new Error('Forbidden: You can only update your own antrian');
        error.statusCode = 403;
        throw error;
      }
    } else if (role === 'pasien') {
      const error = new Error('Forbidden: Pasien cannot update antrian status');
      error.statusCode = 403;
      throw error;
    }

    if (status) item.status = status;
    await item.save();
    return res.json(item);
  } catch (err) {
    next(err);
  }
}

module.exports = { create, list, listByDokter, getById, updateStatus, checkSlot };
