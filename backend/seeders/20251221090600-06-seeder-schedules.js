'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Get Dokters (join with Users to identify by email if needed, or by Name)
        // Simpler to select by name/nip as we seeded them
        const dokters = await queryInterface.sequelize.query(
            `SELECT id, nip FROM dokters`,
            { type: queryInterface.sequelize.QueryTypes.SELECT }
        );
        const dokterMap = {};
        dokters.forEach(d => { dokterMap[d.nip] = d.id; });

        const now = new Date();
        const schedules = [];

        const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

        // Dr. Andi (NIP: ...001) - Poli Umum
        const drAndiId = dokterMap['201001012023011001'];
        if (drAndiId) {
            days.forEach(day => {
                schedules.push({
                    dokter_id: drAndiId,
                    day_of_week: day,
                    start_time: '08:00:00',
                    end_time: '14:00:00',
                    quota: 20,
                    created_at: now,
                    updated_at: now
                });
            });
        }

        // Dr. Bunga (NIP: ...002) - Poli Gigi
        const drBungaId = dokterMap['201001012023011002'];
        if (drBungaId) {
            days.forEach(day => {
                schedules.push({
                    dokter_id: drBungaId,
                    day_of_week: day,
                    start_time: '09:00:00',
                    end_time: '15:00:00',
                    quota: 15,
                    created_at: now,
                    updated_at: now
                });
            });
        }

        if (schedules.length > 0) {
            await queryInterface.bulkInsert('doctor_schedules', schedules, {});
        }
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.bulkDelete('doctor_schedules', null, {});
    }
};
