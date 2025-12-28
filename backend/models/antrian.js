const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Antrian = sequelize.define(
  'Antrian',
  {
    ticket_number: { type: DataTypes.STRING, allowNull: false, unique: true },
    status: { type: DataTypes.ENUM('Menunggu', 'Dipanggil', 'Selesai', 'Batal'), defaultValue: 'Menunggu' },
    scheduled_at: { type: DataTypes.DATE, allowNull: true },
  },
  { tableName: 'antrians', underscored: true }
);

module.exports = Antrian;
