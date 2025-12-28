const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Poli = sequelize.define(
  'Poli',
  {
    nama_poli: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    tableName: 'polis',
    underscored: true,
  }
);

module.exports = Poli;
