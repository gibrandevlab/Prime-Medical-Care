'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        const users = await queryInterface.sequelize.query(
            `SELECT id, email FROM users WHERE role = 'pasien'`,
            { type: queryInterface.sequelize.QueryTypes.SELECT }
        );
        const userMap = {};
        users.forEach(u => { userMap[u.email] = u.id; });

        const now = new Date();
        const pasiens = [];

        // Pasien 1
        if (userMap['pasien1@gmail.com']) {
            pasiens.push({
                user_id: userMap['pasien1@gmail.com'],
                nomor_rm: 'RM0001',
                nik: '3201010101010001',
                nama: 'Ahmad Dani',
                tanggal_lahir: '1995-05-15',
                nomor_telepon: '085678901234',
                alamat: 'Jl. Merpati No. 1',
                created_at: now,
                updated_at: now
            });
        }

        // Pasien 2
        if (userMap['pasien2@gmail.com']) {
            pasiens.push({
                user_id: userMap['pasien2@gmail.com'],
                nomor_rm: 'RM0002',
                nik: '3201010101010002',
                nama: 'Siska Yulianti',
                tanggal_lahir: '1998-08-20',
                nomor_telepon: '085678901235',
                alamat: 'Jl. Kutilang No. 10',
                created_at: now,
                updated_at: now
            });
        }

        if (pasiens.length > 0) {
            await queryInterface.bulkInsert('pasiens', pasiens, {});
        }
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('pasiens', null, {});
    }
};
