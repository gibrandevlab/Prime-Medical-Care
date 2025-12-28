const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MedicalRecord = sequelize.define(
  'MedicalRecord',
  {
    visit_date: { type: DataTypes.DATE, allowNull: false },
    anamnesa: { type: DataTypes.TEXT, allowNull: true },
    diagnosa: { type: DataTypes.TEXT, allowNull: true },
    tindakan: { type: DataTypes.TEXT, allowNull: true },
    resep: { type: DataTypes.TEXT, allowNull: true },
  },
  { tableName: 'medical_records', underscored: true }
);

module.exports = MedicalRecord;
