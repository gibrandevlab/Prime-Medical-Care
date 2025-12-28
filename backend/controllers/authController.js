const { User, Pegawai, Dokter, Pasien } = require('../models');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;

async function login(req, res) {
  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    if (!JWT_SECRET) return res.status(500).json({ message: 'JWT secret not configured on server' });

    // 1. Find User by Email
    const user = await User.findOne({
      where: { email },
      include: [
        { model: Dokter },
        { model: Pegawai },
        { model: Pasien }
      ]
    });

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // 2. Check Password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // 3. Determine Entity ID and Role
    let profileId = null;
    let response = {
      message: 'Success',
      role: user.role,
      user: {
        email: user.email,
        nama: 'User'
      }
    };

    if (user.role === 'dokter' && user.Dokter) {
      profileId = user.Dokter.id;
      response.dokterId = profileId;
      response.user.nama = user.Dokter.nama;
    } else if (user.role === 'pasien' && user.Pasien) {
      profileId = user.Pasien.id;
      response.pasienId = profileId;
      response.user.nama = user.Pasien.nama;
    } else if ((user.role === 'admin' || user.role === 'petugas') && user.Pegawai) {
      profileId = user.Pegawai.id;
      response.pegawaiId = profileId;
      response.user.nama = user.Pegawai.nama;
    }

    // 4. Create Token
    // Payload: { userId, id (entityId), role }
    const payload = {
      userId: user.id,
      id: profileId, // Legacy compatibility, middleware/controllers might use req.user.id as entity ID
      role: user.role,
      email: user.email
    };

    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '1d' });
    response.token = token;

    return res.json(response);

  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
}

module.exports = { login };
