'use strict';

const bcrypt = require('bcryptjs');

module.exports = {
    async up(queryInterface, Sequelize) {
        const passwordHash = await bcrypt.hash('password123', 10);
        const now = new Date();

        await queryInterface.bulkInsert('users', [
            // 1. Admin
            {
                email: 'admin@poli.com',
                password: passwordHash,
                role: 'admin',
                created_at: now,
                updated_at: now
            },
            // 2. Petugas
            {
                email: 'petugas1@poli.com',
                password: passwordHash,
                role: 'petugas',
                created_at: now,
                updated_at: now
            },
            // 3. Dokter A
            {
                email: 'dr.andi@poli.com',
                password: passwordHash,
                role: 'dokter',
                created_at: now,
                updated_at: now
            },
            // 4. Dokter B
            {
                email: 'dr.bunga@poli.com',
                password: passwordHash,
                role: 'dokter',
                created_at: now,
                updated_at: now
            },
            // 5. Pasien A
            {
                email: 'pasien1@gmail.com',
                password: passwordHash,
                role: 'pasien',
                created_at: now,
                updated_at: now
            },
            // 6. Pasien B
            {
                email: 'pasien2@gmail.com',
                password: passwordHash,
                role: 'pasien',
                created_at: now,
                updated_at: now
            }
        ], {});
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('users', null, {});
    }
};
