'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        const now = new Date();

        await queryInterface.bulkInsert('polis', [
            {
                nama_poli: 'Poli Umum',
                keterangan: 'Pelayanan kesehatan umum',
                created_at: now,
                updated_at: now
            },
            {
                nama_poli: 'Poli Gigi',
                keterangan: 'Pelayanan kesehatan gigi dan mulut',
                created_at: now,
                updated_at: now
            },
            {
                nama_poli: 'Poli Anak',
                keterangan: 'Pelayanan kesehatan anak',
                created_at: now,
                updated_at: now
            }
        ], {});
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('polis', null, {});
    }
};
