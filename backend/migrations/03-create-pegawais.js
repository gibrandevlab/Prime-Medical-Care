'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('pegawais', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            user_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'users', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            nip: {
                type: Sequelize.STRING,
                allowNull: false,
                unique: true
            },
            nama: {
                type: Sequelize.STRING,
                allowNull: false
            },
            tanggal_lahir: {
                type: Sequelize.DATEONLY,
                allowNull: true
            },
            nomor_telepon: {
                type: Sequelize.STRING,
                allowNull: true
            },
            role: { // Legacy role field, sync with Users role logically but keep for profile
                type: Sequelize.ENUM('admin', 'petugas'),
                allowNull: false,
                defaultValue: 'petugas'
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
        await queryInterface.dropTable('pegawais');
    }
};
