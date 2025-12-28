'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Helper to find ID by email
        const users = await queryInterface.sequelize.query(
            `SELECT id, email FROM users WHERE role IN ('admin', 'petugas')`,
            { type: queryInterface.sequelize.QueryTypes.SELECT }
        );

        const userMap = {};
        users.forEach(u => { userMap[u.email] = u.id; });

        const now = new Date();

        const pegawais = [];

        // Admin
        if (userMap['admin@poli.com']) {
            pegawais.push({
                user_id: userMap['admin@poli.com'],
                nip: '198001012023011001',
                nama: 'Admin Utama',
                tanggal_lahir: '1980-01-01',
                nomor_telepon: '081234567890',
                created_at: now,
                updated_at: now
            });
        }

        // Petugas
        if (userMap['petugas1@poli.com']) {
            pegawais.push({
                user_id: userMap['petugas1@poli.com'],
                nip: '199001012023011002',
                nama: 'Budi Santoso',
                tanggal_lahir: '1990-01-01',
                nomor_telepon: '081234567891',
                created_at: now,
                updated_at: now
            });
        }

        if (pegawais.length > 0) {
            await queryInterface.bulkInsert('pegawais', pegawais, {});
        }
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('pegawais', null, {});
    }
};
