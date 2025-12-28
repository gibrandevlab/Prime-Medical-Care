const sequelize = require('../config/database');
const User = require('./user');
const Pegawai = require('./pegawai');
const Poli = require('./poli'); // Ensure filename matches (poli.js)
const Dokter = require('./dokter'); // Ensure filename matches (dokter.js)
const Pasien = require('./pasien'); // Ensure filename matches (pasien.js)
const Antrian = require('./antrian');
const MedicalRecord = require('./medicalRecord');
const DoctorSchedule = require('./doctorSchedule');
const DoctorScheduleOverride = require('./doctorScheduleOverride');

// Define Associations
Dokter.belongsTo(Poli, { foreignKey: 'poliId' });
Poli.hasMany(Dokter, { foreignKey: 'poliId' });

// User Associations
User.hasOne(Dokter, { foreignKey: 'userId' });
Dokter.belongsTo(User, { foreignKey: 'userId' });

User.hasOne(Pegawai, { foreignKey: 'userId' });
Pegawai.belongsTo(User, { foreignKey: 'userId' });

User.hasOne(Pasien, { foreignKey: 'userId' });
Pasien.belongsTo(User, { foreignKey: 'userId' });

// Associations for new models
Antrian.belongsTo(Pasien, { foreignKey: 'pasienId', as: 'pasien' });
Pasien.hasMany(Antrian, { foreignKey: 'pasienId' });
Antrian.belongsTo(Dokter, { foreignKey: 'dokterId', as: 'dokter' });
Dokter.hasMany(Antrian, { foreignKey: 'dokterId' });
Antrian.belongsTo(Poli, { foreignKey: 'poliId', as: 'poli' });
Poli.hasMany(Antrian, { foreignKey: 'poliId' });

MedicalRecord.belongsTo(Pasien, { foreignKey: 'pasienId' });
Pasien.hasMany(MedicalRecord, { foreignKey: 'pasienId' });
MedicalRecord.belongsTo(Dokter, { foreignKey: 'dokterId' });
Dokter.hasMany(MedicalRecord, { foreignKey: 'dokterId' });
MedicalRecord.belongsTo(Poli, { foreignKey: 'poliId' });
Poli.hasMany(MedicalRecord, { foreignKey: 'poliId' });

// Schedules
DoctorSchedule.belongsTo(Dokter, { foreignKey: 'dokterId' });
Dokter.hasMany(DoctorSchedule, { foreignKey: 'dokterId' });
DoctorScheduleOverride.belongsTo(Dokter, { foreignKey: 'dokterId' });
Dokter.hasMany(DoctorScheduleOverride, { foreignKey: 'dokterId' });

// Override associations with aliases
DoctorScheduleOverride.belongsTo(User, { as: 'Requester', foreignKey: 'requested_by' });
DoctorScheduleOverride.belongsTo(Dokter, { as: 'Substitute', foreignKey: 'substitute_doctor_id' });
DoctorScheduleOverride.belongsTo(User, { as: 'Approver', foreignKey: 'approved_by' });

module.exports = {
	sequelize,
	User,
	Pegawai,
	Poli,
	Dokter,
	Pasien,
	Antrian,
	MedicalRecord,
	DoctorSchedule,
	DoctorScheduleOverride,
};
