const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DoctorScheduleOverride = sequelize.define(
    'DoctorScheduleOverride',
    {
        dokter_id: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        start_date: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        end_date: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        is_available: {
            type: DataTypes.BOOLEAN,
            defaultValue: true,
        },
        start_time: {
            type: DataTypes.TIME,
            allowNull: true,
        },
        end_time: {
            type: DataTypes.TIME,
            allowNull: true,
        },
        note: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        status: {
            type: DataTypes.ENUM('Pending', 'Approved', 'Rejected'),
            defaultValue: 'Approved',
        },
        substitute_doctor_id: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        requested_by: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        approved_by: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        approved_at: {
            type: DataTypes.DATE,
            allowNull: true,
        },
    },
    {
        tableName: 'doctor_schedule_overrides',
        underscored: true,
    }
);

module.exports = DoctorScheduleOverride;
