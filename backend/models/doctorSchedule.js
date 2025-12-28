const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorSchedule = sequelize.define(
    'DoctorSchedule',
    {
        dokter_id: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        day_of_week: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        start_time: {
            type: DataTypes.TIME,
            allowNull: false,
        },
        end_time: {
            type: DataTypes.TIME,
            allowNull: false,
        },
        quota: {
            type: DataTypes.INTEGER,
            defaultValue: 20,
        },
    },
    {
        tableName: 'doctor_schedules',
        underscored: true,
    }
);

module.exports = DoctorSchedule;
