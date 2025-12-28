const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pegawai = sequelize.define(
  'Pegawai',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
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
    // Virtual fields for compatibility
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
    role: { // Keeping role here might be redundant but useful for reference? 
      // The instructions say "Kredensial (email, password, role) ada di tabel users"
      // But legacy code might check pegawai.role. 
      // Let's make it a virtual too, or keep it if it's not removed from DB (Wait, migration usually removes it?)
      // Instructions: "Kredensial (email, password, role) ada di tabel users."
      // "Tabel dokters, pegawais, dan pasiens sekarang hanya berisi profil"
      // So I should make role virtual too if possible.
      // But verify if migration removed 'role' column from 'pegawais'. 
      // Assuming migration removed it or we want to ignore it. Let's make it virtual.
      type: DataTypes.VIRTUAL,
      get() {
        return this.User ? this.User.role : 'petugas';
      },
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: 'pegawais',
    timestamps: false,
  }
);

module.exports = Pegawai;
