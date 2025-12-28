const { Pasien, Dokter, Antrian, DoctorScheduleOverride, Poli } = require('../models');
const { Op } = require('sequelize');

async function getDashboardStats(req, res) {
    try {
        const { role, userId } = req.query;

        const today = new Date();
        const startOfDay = new Date(today.setHours(0, 0, 0, 0));
        const endOfDay = new Date(today.setHours(23, 59, 59, 999));
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

        let stats = {};

        if (role === 'admin') {
            // Admin Stats
            const totalPasienToday = await Pasien.count({
                where: {
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const totalPasienMonth = await Pasien.count({
                where: {
                    created_at: { [Op.gte]: startOfMonth }
                }
            });

            const antrianToday = await Antrian.count({
                where: {
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianPending = await Antrian.count({
                where: {
                    status: 'Pending',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianSelesai = await Antrian.count({
                where: {
                    status: 'Selesai',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const pendingApprovals = await DoctorScheduleOverride.count({
                where: { status: 'Pending' }
            });

            const dokterAktif = await Dokter.count();

            // Recent Activity
            const recentAntrian = await Antrian.findAll({
                limit: 5,
                order: [['created_at', 'DESC']],
                include: [
                    { model: Pasien, attributes: ['nama'] },
                    { model: Dokter, attributes: ['nama'] }
                ]
            });

            stats = {
                totalPasienToday,
                totalPasienMonth,
                antrianToday,
                antrianPending,
                antrianSelesai,
                pendingApprovals,
                dokterAktif,
                recentAntrian
            };

        } else if (role === 'petugas') {
            // Petugas Stats
            const antrianToday = await Antrian.count({
                where: {
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianPending = await Antrian.count({
                where: {
                    status: 'Pending',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianSelesai = await Antrian.count({
                where: {
                    status: 'Selesai',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const totalPasien = await Pasien.count();
            const poliTersedia = await Poli.count();

            const recentAntrian = await Antrian.findAll({
                limit: 5,
                order: [['created_at', 'DESC']],
                include: [
                    { model: Pasien, attributes: ['nama'] },
                    { model: Dokter, attributes: ['nama'] }
                ]
            });

            stats = {
                antrianToday,
                antrianPending,
                antrianSelesai,
                totalPasien,
                poliTersedia,
                recentAntrian
            };

        } else if (role === 'dokter' && userId) {
            // Dokter Stats
            const antrianToday = await Antrian.count({
                where: {
                    dokter_id: userId,
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianPending = await Antrian.count({
                where: {
                    dokter_id: userId,
                    status: 'Pending',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const antrianSelesai = await Antrian.count({
                where: {
                    dokter_id: userId,
                    status: 'Selesai',
                    created_at: { [Op.between]: [startOfDay, endOfDay] }
                }
            });

            const startOfWeek = new Date(today);
            startOfWeek.setDate(today.getDate() - today.getDay());

            const pasienDilayani = await Antrian.count({
                where: {
                    dokter_id: userId,
                    status: 'Selesai',
                    created_at: { [Op.gte]: startOfWeek }
                }
            });

            // Upcoming schedule (3 days)
            const threeDaysLater = new Date();
            threeDaysLater.setDate(today.getDate() + 3);

            const upcomingSchedule = await DoctorScheduleOverride.findAll({
                where: {
                    dokter_id: userId,
                    date: { [Op.between]: [today.toISOString().split('T')[0], threeDaysLater.toISOString().split('T')[0]] },
                    status: 'Approved'
                },
                order: [['date', 'ASC']]
            });

            // Stats needing User ID
            const dokter = await Dokter.findByPk(userId);
            let pendingRequests = 0;
            if (dokter && dokter.userId) {
                pendingRequests = await DoctorScheduleOverride.count({
                    where: {
                        requested_by: dokter.userId,
                        status: 'Pending'
                    }
                });
            }

            stats = {
                antrianToday,
                antrianPending,
                antrianSelesai,
                pasienDilayani,
                upcomingSchedule,
                pendingRequests
            };
        }

        return res.json(stats);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

module.exports = { getDashboardStats };
