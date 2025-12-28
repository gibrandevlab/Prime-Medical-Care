// app.js
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const authRoutes = require('./routes/auth');
const poliRoutes = require('./routes/poli');
const pegawaiRoutes = require('./routes/pegawai');
const dokterRoutes = require('./routes/dokter');
const pasienRoutes = require('./routes/pasien');
const antrianRoutes = require('./routes/antrian');
const medicalRecordRoutes = require('./routes/medical_record');
const scheduleRoutes = require('./routes/schedule');
const dashboardRoutes = require('./routes/dashboard');

// Import error handling middleware
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const db = require('./models');

const app = express();

app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.json({ message: 'Server Klinik Running on 192.168.137.1' });
});

// API Routes
app.use('/auth', authRoutes);
app.use('/poli', poliRoutes);
app.use('/pegawai', pegawaiRoutes);
app.use('/dokter', dokterRoutes);
app.use('/pasien', pasienRoutes);
app.use('/antrian', antrianRoutes);
app.use('/medical-records', medicalRecordRoutes);
app.use('/schedule', scheduleRoutes);
app.use('/dashboard', dashboardRoutes);

// 404 Handler - must be after all routes
app.use(notFoundHandler);

// Global Error Handler - must be the last middleware
app.use(errorHandler);

// Use authenticate instead of sync({ alter: true }) to avoid runtime schema changes
// when using migrations. Migrations should be applied with sequelize-cli.
db.sequelize
  .authenticate()
  .then(() => console.log('Database connection OK'))
  .catch((err) => console.error('Database connection error:', err));

const PORT = 3000;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log('Server running at http://192.168.137.1:3000');
});
