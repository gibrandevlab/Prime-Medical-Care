const { Dokter, Poli, User, sequelize } = require('../models');
const bcrypt = require('bcryptjs');

exports.getAll = async (req, res, next) => {
  try {
    const data = await Dokter.findAll({
      include: [
        {
          model: Poli,
          attributes: ['nama_poli'],
        },
        {
          model: User, // Required for virtual fields (email, password)
        }
      ],
    });
    return res.json(data);
  } catch (error) {
    next(error);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const dokter = await Dokter.findByPk(id, {
      include: [
        { model: Poli, attributes: ['nama_poli'] },
        { model: User }
      ],
    });
    if (!dokter) {
      const error = new Error('Dokter not found');
      error.statusCode = 404;
      throw error;
    }
    return res.json(dokter);
  } catch (error) {
    next(error);
  }
};

exports.create = async (req, res, next) => {
  const t = await sequelize.transaction();
  try {
    const { nip, nama, nomor_telepon, poliId, email: bodyEmail, password: bodyPassword } = req.body || {};

    // 1. Create User
    const email = bodyEmail ? bodyEmail.toString() : null;
    const password = bodyPassword ? bodyPassword.toString() : null;

    // Note: hashing is handled by User beforeCreate hook
    const user = await User.create({
      email,
      password,
      role: 'dokter'
    }, { transaction: t });

    // 2. Create Dokter Profile
    const dokter = await Dokter.create({
      userId: user.id,
      nip,
      nama,
      nomor_telepon,
      poliId
    }, { transaction: t });

    await t.commit();

    // Reload to include User for response consistency if needed, or just return dokter
    // The frontend usually expects the object. The virtual fields might work if we manually set .User?
    // Better to fetch again or let it be. 
    // If we just return 'dokter', 'dokter.email' virtual field needs 'dokter.User'.
    // Let's reload it.
    const createdDokter = await Dokter.findByPk(dokter.id, {
      include: [{ model: User }, { model: Poli }]
    });

    return res.status(201).json(createdDokter);
  } catch (error) {
    await t.rollback();
    next(error);
  }
};

exports.update = async (req, res, next) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const { nip, nama, nomor_telepon, poliId, email: newEmail, password: newPassword } = req.body || {};

    const dokter = await Dokter.findByPk(id, {
      include: [{ model: User }],
      transaction: t
    });

    if (!dokter) {
      await t.rollback();
      const error = new Error('Dokter not found');
      error.statusCode = 404;
      throw error;
    }

    // Update User (Creds)
    if (dokter.User) {
      if (newEmail !== undefined) dokter.User.email = newEmail;
      if (newPassword) dokter.User.password = newPassword; // Hook will hash
      await dokter.User.save({ transaction: t });
    }

    // Update Profile
    dokter.nip = nip !== undefined ? nip : dokter.nip;
    dokter.nama = nama !== undefined ? nama : dokter.nama;
    dokter.nomor_telepon = nomor_telepon !== undefined ? nomor_telepon : dokter.nomor_telepon;
    dokter.poliId = poliId !== undefined ? poliId : dokter.poliId;

    await dokter.save({ transaction: t });

    await t.commit();
    return res.json(dokter);
  } catch (error) {
    await t.rollback();
    next(error);
  }
};

exports.delete = async (req, res, next) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const dokter = await Dokter.findByPk(id, { transaction: t });

    if (!dokter) {
      await t.rollback();
      const error = new Error('Dokter not found');
      error.statusCode = 404;
      throw error;
    }

    const userId = dokter.userId;

    // Delete Profile first
    await dokter.destroy({ transaction: t });

    // Delete User
    if (userId) {
      await User.destroy({ where: { id: userId }, transaction: t });
    }

    await t.commit();
    return res.json({ message: 'Deleted' });
  } catch (error) {
    await t.rollback();
    next(error);
  }
};
