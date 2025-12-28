'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('polis', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            nama_poli: {
                type: Sequelize.STRING,
                allowNull: false
            },
            gambar: {
                type: Sequelize.STRING,
                allowNull: true
            },
            keterangan: {
                type: Sequelize.TEXT,
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
        await queryInterface.dropTable('polis');
    }
};
