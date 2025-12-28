'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        // 1. Doctor Schedules (Base)
        await queryInterface.createTable('doctor_schedules', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            dokter_id: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: { model: 'dokters', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            day_of_week: {
                type: Sequelize.INTEGER, // 0-6 (Sun-Sat) or 1-7
                allowNull: false
            },
            start_time: { type: Sequelize.TIME, allowNull: false },
            end_time: { type: Sequelize.TIME, allowNull: false },
            is_active: { type: Sequelize.BOOLEAN, defaultValue: true },
            quota: { type: Sequelize.INTEGER, defaultValue: 20 },
            created_at: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
            updated_at: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
        });

        // 2. Doctor Schedule Overrides (Exceptions & Leave)
        await queryInterface.createTable('doctor_schedule_overrides', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            dokter_id: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: { model: 'dokters', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            start_date: { type: Sequelize.DATEONLY, allowNull: false },
            end_date: { type: Sequelize.DATEONLY, allowNull: true },
            start_time: { type: Sequelize.TIME, allowNull: true },
            end_time: { type: Sequelize.TIME, allowNull: true },
            is_available: { type: Sequelize.BOOLEAN, defaultValue: false },
            note: { type: Sequelize.STRING, allowNull: true },
            status: {
                type: Sequelize.ENUM('Pending', 'Approved', 'Rejected'),
                defaultValue: 'Pending'
            },
            requested_by: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'users', key: 'id' }, // Linked to User (Actor)
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            approved_by: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'users', key: 'id' }, // Linked to User (Actor)
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            approved_at: { type: Sequelize.DATE, allowNull: true },
            substitute_doctor_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'dokters', key: 'id' }, // Substitute is likely a Doctor Entity
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            created_at: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
            updated_at: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('doctor_schedule_overrides');
        await queryInterface.dropTable('doctor_schedules');
    }
};
