const Poli = require('../models/poli');
const { Dokter } = require('../models');

async function getAll(req, res, next) {
  try {
    const list = await Poli.findAll();
    return res.json(list);
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const { id } = req.params;
    const poli = await Poli.findByPk(id);
    if (!poli) {
      const error = new Error('Poli not found');
      error.statusCode = 404;
      throw error;
    }
    return res.json(poli);
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const { nama_poli, keterangan, gambar } = req.body || {};
    const poli = await Poli.create({ nama_poli, keterangan, gambar });
    return res.status(201).json(poli);
  } catch (err) {
    next(err);
  }
}

async function update(req, res, next) {
  try {
    const { id } = req.params;
    const { nama_poli, keterangan, gambar } = req.body || {};
    const poli = await Poli.findByPk(id);
    if (!poli) {
      const error = new Error('Poli not found');
      error.statusCode = 404;
      throw error;
    }
    poli.nama_poli = nama_poli !== undefined ? nama_poli : poli.nama_poli;
    poli.keterangan = keterangan !== undefined ? keterangan : poli.keterangan;
    poli.gambar = gambar !== undefined ? gambar : poli.gambar;
    await poli.save();
    return res.json(poli);
  } catch (err) {
    next(err);
  }
}

async function remove(req, res, next) {
  try {
    const { id } = req.params;
    const poli = await Poli.findByPk(id);
    if (!poli) {
      const error = new Error('Poli not found');
      error.statusCode = 404;
      throw error;
    }
    // unset poli reference on related Dokter rows to avoid FK constraint errors
    try {
      await Dokter.update({ poliId: null }, { where: { poliId: id } });
    } catch (e) {
      // log but continue to attempt deletion
      console.error('Error clearing Dokter.poliId:', e);
    }
    await poli.destroy();
    return res.json({ message: 'Deleted' });
  } catch (err) {
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
