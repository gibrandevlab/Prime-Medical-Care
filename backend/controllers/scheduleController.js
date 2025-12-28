const { DoctorSchedule, DoctorScheduleOverride, Dokter, Poli } = require('../models');
const AvailabilityService = require('../services/availabilityService');

async function getSchedules(req, res) {
    try {
        const { dokterId } = req.params;
        const user = req.user;

        // Security Check: 
        // 1. Admin/Petugas can view anyone.
        // 2. Dokter can only view THEMSELVES.
        // 3. Pasien might see schedule (public/booking) - usually this endpoint is for internal management. 
        //    Booking uses 'checkAvailability'.
        //    Let's assume this full schedule view is internal.
        if (user.role === 'dokter' && parseInt(dokterId) !== user.id) {
            return res.status(403).json({ message: 'Forbidden: You can only view your own schedule' });
        }
        if (user.role === 'pasien') {
            // Pasien shouldn't access this internal detailed view? 
            // Or maybe they can? User said "Admin & Pegawai only" for "Manajemen Jadwal".
            // So Pasien is forbidden.
            return res.status(403).json({ message: 'Forbidden' });
        }

        const base = await DoctorSchedule.findAll({ where: { dokter_id: dokterId } });
        const overrides = await DoctorScheduleOverride.findAll({
            where: { dokter_id: dokterId },
            order: [['start_date', 'DESC']],
            limit: 50
        });

        return res.json({ base, overrides });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function addOverride(req, res) {
    // Admin direct add
    try {
        const { dokterId, startDate, endDate, isAvailable, note } = req.body;
        if (!dokterId || !startDate) return res.status(400).json({ message: 'dokterId and startDate required' });

        const override = await DoctorScheduleOverride.create({
            dokter_id: dokterId,
            start_date: startDate,
            end_date: endDate || startDate,
            is_available: isAvailable,
            note,
            status: 'Approved' // Admin direct add is auto-approved
        });
        return res.status(201).json(override);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function deleteOverride(req, res) {
    try {
        const { id } = req.params;
        await DoctorScheduleOverride.destroy({ where: { id } });
        return res.json({ message: 'Deleted' });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function requestOverride(req, res) {
    // Doctor request (Leave / Reschedule)
    try {
        const { dokterId, startDate, endDate, isAvailable, note, substituteDokterId, startTime, endTime } = req.body;
        if (!dokterId || !startDate) return res.status(400).json({ message: 'dokterId and startDate required' });

        // Validate substitute if provided
        if (substituteDokterId) {
            const requester = await Dokter.findByPk(dokterId);
            const substitute = await Dokter.findByPk(substituteDokterId);

            if (!requester || !substitute) {
                return res.status(400).json({ message: 'Invalid dokter ID' });
            }

            if (requester.poliId !== substitute.poliId) {
                return res.status(400).json({ message: 'Pengganti harus se-Poli' });
            }

            // Check substitute availability for the whole range
            // Simplification: check only start date for now, ideally check each day in range
            const avail = await AvailabilityService.checkAvailability(substituteDokterId, startDate);
            if (!avail.available) {
                return res.status(400).json({ message: `Pengganti tidak tersedia di tanggal ${startDate}` });
            }
        }

        const override = await DoctorScheduleOverride.create({
            dokter_id: dokterId,
            start_date: startDate,
            end_date: endDate || startDate,
            is_available: isAvailable,
            note,
            start_time: startTime,
            end_time: endTime,
            substitute_doctor_id: substituteDokterId || null,
            requested_by: req.user.userId,
            status: 'Pending'
        });

        return res.status(201).json({
            ...override.toJSON(),
            message: 'Request berhasil dikirim, menunggu approval Admin'
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function approveOverride(req, res) {
    try {
        const { id } = req.params;
        const { approved, adminId } = req.body;

        const override = await DoctorScheduleOverride.findByPk(id);
        if (!override) return res.status(404).json({ message: 'Not found' });

        if (approved) {
            override.status = 'Approved';
            override.approved_by = req.user.userId;
            override.approved_at = new Date();
            await override.save();

            if (override.substitute_doctor_id) {
                // Create MIRROR override for substitute doctor
                // They become AVAILABLE on that range/time
                await DoctorScheduleOverride.create({
                    dokter_id: override.substitute_doctor_id,
                    start_date: override.start_date,
                    end_date: override.end_date,
                    is_available: true,
                    start_time: override.start_time, // Inherit time if specified
                    end_time: override.end_time,
                    note: `Menggantikan dokter (Request #${id})`,
                    status: 'Approved',
                    approved_by: req.user.userId,
                    approved_at: new Date()
                });
            }

            return res.json({ message: 'Request approved', override });
        } else {
            override.status = 'Rejected';
            override.approved_by = req.user.userId;
            override.approved_at = new Date();
            await override.save();
            return res.json({ message: 'Request rejected', override });
        }
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function getAvailableSubstitutes(req, res) {
    try {
        const { dokterId, date } = req.query; // date param is used for checking
        if (!dokterId || !date) return res.status(400).json({ message: 'dokterId and date required' });

        const requester = await Dokter.findByPk(dokterId);
        if (!requester) return res.status(404).json({ message: 'Dokter not found' });

        const samePoli = await Dokter.findAll({ where: { poliId: requester.poliId } });

        const availableDoctors = [];
        for (const dok of samePoli) {
            if (dok.id === parseInt(dokterId)) continue;

            const avail = await AvailabilityService.checkAvailability(dok.id, date);
            if (avail.available) {
                availableDoctors.push({
                    id: dok.id,
                    nama: dok.nama,
                    schedule: avail.schedule
                });
            }
        }

        return res.json({ availableDoctors });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

async function getPendingRequests(req, res) {
    try {
        const requests = await DoctorScheduleOverride.findAll({
            where: { status: 'Pending' },
            order: [['created_at', 'DESC']],
            include: [
                {
                    model: User, // Requester is now a User
                    as: 'Requester',
                    attributes: ['id', 'email'],
                    include: [
                        {
                            model: Dokter,
                            attributes: ['id', 'nama', 'nip'],
                            include: [{ model: Poli, attributes: ['nama_poli'] }]
                        }
                    ]
                },
                {
                    model: Dokter,
                    as: 'Substitute',
                    attributes: ['id', 'nama'],
                    include: [{ model: Poli, attributes: ['nama_poli'] }]
                }
            ]
        });

        return res.json({ requests });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Server error' });
    }
}

module.exports = {
    getSchedules,
    addOverride,
    deleteOverride,
    requestOverride,
    approveOverride,
    getAvailableSubstitutes,
    getPendingRequests
};
