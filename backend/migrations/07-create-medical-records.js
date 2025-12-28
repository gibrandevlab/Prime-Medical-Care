'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('medical_records', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            pasien_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'pasiens', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            dokter_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'dokters', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            poli_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'polis', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            visit_date: {
                type: Sequelize.DATE,
                allowNull: false
            },
            anamnesa: { type: Sequelize.TEXT },
            diagnosa: { type: Sequelize.TEXT },
            tindakan: { type: Sequelize.TEXT },
            resep: { type: Sequelize.TEXT },
            catatan_dokter: { type: Sequelize.TEXT },
            created_at: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.fn('NOW')
            },
            updated_at: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.fn('NOW')
            }
        });
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('medical_records');
    }
};
