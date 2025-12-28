const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Dokter = sequelize.define(
  'Dokter',
  {
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
      field: 'user_id',
    },
    nip: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    // Virtual fields to maintain compatibility
    email: {
      type: DataTypes.VIRTUAL,
      get() {
        return this.User ? this.User.email : null;
      },
    },
    password: {
      type: DataTypes.VIRTUAL,
      get() {
        return this.User ? this.User.password : null;
      },
    },
    nama: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    nomor_telepon: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    poliId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
  },
  {
    tableName: 'dokters',
    underscored: true,
  }
);

module.exports = Dokter;
