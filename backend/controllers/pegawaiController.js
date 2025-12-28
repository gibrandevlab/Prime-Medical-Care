const { Pegawai, User, sequelize } = require('../models');

async function getAll(req, res, next) {
  try {
    const pegawais = await Pegawai.findAll({
      include: [{ model: User }]
    });
    return res.json(pegawais);
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const { id } = req.params;
    const pegawai = await Pegawai.findByPk(id, {
      include: [{ model: User }]
    });
    if (!pegawai) {
      const error = new Error('Pegawai not found');
      error.statusCode = 404;
      throw error;
    }
    return res.json(pegawai);
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  const t = await sequelize.transaction();
  try {
    const {
      nama,
      nip,
      tanggal_lahir,
      nomor_telepon,
      email: bodyEmail,
      password: bodyPassword,
      role: bodyRole,
    } = req.body || {};

    const email = (bodyEmail && bodyEmail.toString().trim()) || `${nip}@example.local`;
    const password = (bodyPassword && bodyPassword.toString()) || '123456'; // Default password if missing, though typically required
    const role = bodyRole || 'petugas';

    // 1. Create User
    const user = await User.create({
      email,
      password,
      role
    }, { transaction: t });

    // 2. Create Pegawai
    const pegawai = await Pegawai.create({
      userId: user.id,
      nama,
      nip,
      tanggal_lahir,
      nomor_telepon,
      // role? Pegawai model might have role column, let's check instruction. 
      // Instruction says "Kredensial ... role ... dipindah ke tabel users".
      // But 'pegawais' table might still have a role column if not removed.
      // If virtual, we don't set it. If physical, we set it.
      // Since we didn't remove it in migration (explicitly), we might want to set it if it exists.
      // However, User.role is the source of truth.
      // We will ignore it here and rely on User.role unless constraint fails.
    }, { transaction: t });

    await t.commit();

    const created = await Pegawai.findByPk(pegawai.id, { include: [{ model: User }] });
    return res.status(201).json(created);
  } catch (err) {
    await t.rollback();
    next(err);
  }
}

async function update(req, res, next) {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const { nama, nip, tanggal_lahir, nomor_telepon, password: newPassword, email: newEmail, role: newRole } = req.body || {};

    const pegawai = await Pegawai.findByPk(id, {
      include: [{ model: User }],
      transaction: t
    });

    if (!pegawai) {
      await t.rollback();
      const error = new Error('Pegawai not found');
      error.statusCode = 404;
      throw error;
    }

    // Update User
    if (pegawai.User) {
      if (newEmail !== undefined) pegawai.User.email = newEmail;
      if (newPassword) pegawai.User.password = newPassword;
      if (newRole) pegawai.User.role = newRole;
      await pegawai.User.save({ transaction: t });
    }

    // Update Profile
    pegawai.nama = nama !== undefined ? nama : pegawai.nama;
    pegawai.nip = nip !== undefined ? nip : pegawai.nip;
    pegawai.tanggal_lahir = tanggal_lahir !== undefined ? tanggal_lahir : pegawai.tanggal_lahir;
    pegawai.nomor_telepon = nomor_telepon !== undefined ? nomor_telepon : pegawai.nomor_telepon;
    pegawai.updated_at = new Date();

    await pegawai.save({ transaction: t });

    await t.commit();
    return res.json(pegawai);
  } catch (err) {
    await t.rollback();
    next(err);
  }
}

async function remove(req, res, next) {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const pegawai = await Pegawai.findByPk(id, { transaction: t });
    if (!pegawai) {
      await t.rollback();
      const error = new Error('Pegawai not found');
      error.statusCode = 404;
      throw error;
    }

    const userId = pegawai.userId;

    await pegawai.destroy({ transaction: t });

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
