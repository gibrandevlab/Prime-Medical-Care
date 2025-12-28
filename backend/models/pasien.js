const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pasien = sequelize.define(
  'Pasien',
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
    nomor_rm: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    nik: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    nama: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    tanggal_lahir: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    nomor_telepon: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    alamat: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    // Virtual Fields
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
  },
  {
    tableName: 'pasiens',
    underscored: true,
  }
);

module.exports = Pasien;
