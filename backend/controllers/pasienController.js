const { Pasien, User, sequelize } = require('../models');
const { validationResult } = require('express-validator');

async function getAll(req, res, next) {
  try {
    // Authorization: Only admin, petugas, and dokter can view all pasien
    const userRole = req.user?.role;
    if (userRole !== 'admin' && userRole !== 'petugas' && userRole !== 'dokter') {
      const error = new Error('Forbidden: Only admin, petugas, and dokter can view all pasien');
      error.statusCode = 403;
      throw error;
    }

    const list = await Pasien.findAll({
      include: [{ model: User }]
    });
    return res.json(list);
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const { id } = req.params;
    const pasien = await Pasien.findByPk(id, {
      include: [{ model: User }]
    });

    if (!pasien) {
      const error = new Error('Pasien not found');
      error.statusCode = 404;
      throw error;
    }

    // Authorization: Pasien can only view their own data
    // Note: req.user.id is Profile ID (Pasien ID) for backward compatibility
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && parseInt(id) !== userId) {
      const error = new Error('Forbidden: You can only view your own data');
      error.statusCode = 403;
      throw error;
    }

    return res.json(pasien);
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

    const { nik, nama, alamat, nomor_telepon, tanggal_lahir, email: bodyEmail, password: bodyPassword } = req.body || {};
    const email = bodyEmail ? bodyEmail.toString() : null;
    const password = bodyPassword ? bodyPassword.toString() : null;

    // Auto-generate nomor_rm
    const lastPasien = await Pasien.findOne({
      order: [['id', 'DESC']],
      transaction: t
    });

    let nomorRm = 'RM0001';
    if (lastPasien && lastPasien.nomor_rm) {
      const lastNumber = parseInt(lastPasien.nomor_rm.replace('RM', ''));
      const nextNumber = lastNumber + 1;
      nomorRm = `RM${nextNumber.toString().padStart(4, '0')}`;
    }

    // 1. Create User
    const user = await User.create({
      email,
      password,
      role: 'pasien'
    }, { transaction: t });

    // 2. Create Pasien Profile
    const pasien = await Pasien.create({
      userId: user.id,
      nomor_rm: nomorRm,
      nik,
      nama,
      alamat,
      nomor_telepon,
      tanggal_lahir,
    }, { transaction: t });

    // Commit transaction
    await t.commit();

    const createdPasien = await Pasien.findByPk(pasien.id, { include: [{ model: User }] });

    return res.status(201).json(createdPasien);
  } catch (err) {
    // Rollback
    await t.rollback();
    next(err);
  }
}

async function update(req, res, next) {
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

    const { id } = req.params;
    const { nik, nama, alamat, nomor_telepon, tanggal_lahir, email: newEmail, password: newPassword } = req.body || {};

    const pasien = await Pasien.findByPk(id, {
      include: [{ model: User }],
      transaction: t
    });

    if (!pasien) {
      await t.rollback();
      const error = new Error('Pasien not found');
      error.statusCode = 404;
      throw error;
    }

    // Authorization
    const userRole = req.user?.role;
    const userId = req.user?.id;

    if (userRole === 'pasien' && parseInt(id) !== userId) {
      await t.rollback();
      const error = new Error('Forbidden: You can only update your own data');
      error.statusCode = 403;
      throw error;
    }

    // Update User (Creds)
    if (pasien.User) {
      if (newEmail !== undefined) pasien.User.email = newEmail;
      if (newPassword) pasien.User.password = newPassword;
      await pasien.User.save({ transaction: t });
    }

    // Update Profile
    pasien.nik = nik !== undefined ? nik : pasien.nik;
    pasien.nama = nama !== undefined ? nama : pasien.nama;
    pasien.alamat = alamat !== undefined ? alamat : pasien.alamat;
    pasien.nomor_telepon = nomor_telepon !== undefined ? nomor_telepon : pasien.nomor_telepon;
    pasien.tanggal_lahir = tanggal_lahir !== undefined ? tanggal_lahir : pasien.tanggal_lahir;
    pasien.updated_at = new Date(); // Ensure updated_at is refreshed

    await pasien.save({ transaction: t });

    // Commit transaction
    await t.commit();

    return res.json(pasien);
  } catch (err) {
    await t.rollback();
    next(err);
  }
}

async function remove(req, res, next) {
  const t = await sequelize.transaction();
  try {
    // Authorization: Only admin can delete pasien
    const userRole = req.user?.role;
    if (userRole !== 'admin') {
      await t.rollback();
      const error = new Error('Forbidden: Only admin can delete pasien');
      error.statusCode = 403;
      throw error;
    }

    const { id } = req.params;
    const pasien = await Pasien.findByPk(id, { transaction: t });

    if (!pasien) {
      await t.rollback();
      const error = new Error('Pasien not found');
      error.statusCode = 404;
      throw error;
    }

    const userId = pasien.userId;

    await pasien.destroy({ transaction: t });

    if (userId) {
      await User.destroy({ where: { id: userId }, transaction: t });
    }

    await t.commit();
    return res.json({ message: 'Deleted' });
  } catch (err) {
    await t.rollback();
    next(err);
  }
}

module.exports = {
  getAll,
  getById,
  create,
  update,
  delete: remove,
};
