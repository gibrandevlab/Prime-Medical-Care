'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('dokters', {
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
            poli_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: { model: 'polis', key: 'id' },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            nip: {
                type: Sequelize.STRING,
                allowNull: true
            },
            nama: {
                type: Sequelize.STRING,
                allowNull: true
            },
            nomor_telepon: {
                type: Sequelize.STRING,
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
        await queryInterface.dropTable('dokters');
    }
};
