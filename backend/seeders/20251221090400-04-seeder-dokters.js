'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Get Users
        const users = await queryInterface.sequelize.query(
            `SELECT id, email FROM users WHERE role = 'dokter'`,
            { type: queryInterface.sequelize.QueryTypes.SELECT }
        );
        const userMap = {};
        users.forEach(u => { userMap[u.email] = u.id; });

        // Get Polis
        const polis = await queryInterface.sequelize.query(
            `SELECT id, nama_poli FROM polis`,
            { type: queryInterface.sequelize.QueryTypes.SELECT }
        );
        const poliMap = {};
        polis.forEach(p => { poliMap[p.nama_poli] = p.id; });

        const now = new Date();
        const dokters = [];

        // Dokter Andi (Umum)
        if (userMap['dr.andi@poli.com'] && poliMap['Poli Umum']) {
            dokters.push({
                user_id: userMap['dr.andi@poli.com'],
                poli_id: poliMap['Poli Umum'],
                nip: '201001012023011001',
                nama: 'Dr. Andi Wijaya',
                nomor_telepon: '081234567893',
                created_at: now,
                updated_at: now
            });
        }

        // Dokter Bunga (Gigi)
        if (userMap['dr.bunga@poli.com'] && poliMap['Poli Gigi']) {
            dokters.push({
                user_id: userMap['dr.bunga@poli.com'],
                poli_id: poliMap['Poli Gigi'],
                nip: '201001012023011002',
                nama: 'Dr. Bunga Citra',
                nomor_telepon: '081234567894',
                created_at: now,
                updated_at: now
            });
        }

        if (dokters.length > 0) {
            await queryInterface.bulkInsert('dokters', dokters, {});
        }
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('dokters', null, {});
    }
};
