'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('antrians', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            ticket_number: {
                type: Sequelize.STRING,
                allowNull: false
            },
            poli_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'polis', key: 'id' },
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
            pasien_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'pasiens', key: 'id' }, // Profile ID, not UserID
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            status: {
                type: Sequelize.ENUM('Menunggu', 'Dipanggil', 'Selesai', 'Batal'),
                defaultValue: 'Menunggu'
            },
            scheduled_at: {
                type: Sequelize.DATE,
                allowNull: true
            },
            waktu_kedatangan: {
                type: Sequelize.DATE,
                defaultValue: Sequelize.fn('NOW')
            },
            waktu_dilayani: {
                type: Sequelize.DATE,
                allowNull: true
            },
            waktu_selesai: {
                type: Sequelize.DATE,
                allowNull: true
            },
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
        await queryInterface.dropTable('antrians');
    }
};
