const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  if (!JWT_SECRET) {
    return res.status(500).json({ message: 'JWT secret not configured' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    return next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

function adminOnly(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden: admin only' });
  }
  return next();
}

function doctorOnly(req, res, next) {
  if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
  if (req.user.role !== 'dokter') return res.status(403).json({ message: 'Forbidden: dokter only' });
  return next();
}

function petugasOnly(req, res, next) {
  if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
  if (req.user.role !== 'petugas' && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden: petugas or admin only' });
  }
  return next();
}

function pasienOnly(req, res, next) {
  if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
  if (req.user.role !== 'pasien') return res.status(403).json({ message: 'Forbidden: pasien only' });
  return next();
}

function adminOrPetugas(req, res, next) {
  if (!req.user) return res.status(401).json({ message: 'Unauthorized' });
  if (req.user.role !== 'admin' && req.user.role !== 'petugas') {
    return res.status(403).json({ message: 'Forbidden: admin or petugas only' });
  }
  return next();
}

module.exports = { verifyToken, adminOnly, doctorOnly, petugasOnly, pasienOnly, adminOrPetugas };
