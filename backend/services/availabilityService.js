const { DoctorSchedule, DoctorScheduleOverride, Antrian } = require('../models');
const { Op } = require('sequelize');

class AvailabilityService {

    /**
     * Check if a doctor is available on a specific date.
     * @param {number} dokterId 
     * @param {string|Date} date YYYY-MM-DD
     * @returns {Promise<{available: boolean, note: string, schedule: object|null}>}
     */
    static async checkAvailability(dokterId, date) {
        const targetDate = new Date(date);
        const dayOfWeek = targetDate.getDay(); // 0=Sun, 1=Mon...
        const dateString = targetDate.toISOString().split('T')[0];

        // 1. Check Overrides
        const override = await DoctorScheduleOverride.findOne({
            where: {
                dokter_id: dokterId,
                status: 'Approved',
                [Op.and]: [
                    { start_date: { [Op.lte]: dateString } },
                    { end_date: { [Op.gte]: dateString } }
                ]
            }
        });

        if (override) {
            if (!override.is_available) {
                return { available: false, note: override.note || 'Dokter Libur (Jadwal Khusus)', schedule: null };
            }
            // If available override (e.g. extra shift)
            return {
                available: true,
                note: override.note || 'Jadwal Khusus',
                schedule: { start: override.start_time, end: override.end_time }
            };
        }

        // 2. Check Base Schedule
        const schedule = await DoctorSchedule.findOne({
            where: {
                dokter_id: dokterId,
                day_of_week: dayOfWeek
            }
        });

        if (schedule) {
            return {
                available: true,
                note: 'Jadwal Rutin',
                schedule: { start: schedule.start_time, end: schedule.end_time }
            };
        }

        return { available: false, note: 'Tidak ada jadwal praktek', schedule: null };
    }

    /**
     * Check if a specific time slot is already taken.
     * @param {number} dokterId 
     * @param {Date} scheduledAt 
     * @param {number} durationMinutes Default 15 minutes
     * @returns {Promise<{conflict: boolean, note: string}>}
     */
    static async checkSlotConflict(dokterId, scheduledAt, durationMinutes = 15) {
        // Calculate end time of requested slot
        const startTime = new Date(scheduledAt);
        const endTime = new Date(startTime.getTime() + durationMinutes * 60000);

        // Find overlapping antrian
        // Overlap condition: (StartA < EndB) and (EndA > StartB)
        // Existing antrian: StartB = scheduled_at, EndB = scheduled_at + duration

        // LIMITATION: Database doesn't store duration. We assume existing slots also have 15 min duration.
        // Complex overlap check:
        // We look for any antrian where its scheduled_at is within [startTime - 15m, endTime]

        const windowStart = new Date(startTime.getTime() - durationMinutes * 60000);
        const windowEnd = endTime;

        const conflict = await Antrian.findOne({
            where: {
                dokter_id: dokterId,
                status: { [Op.ne]: 'Batal' }, // Ignore Cancelled
                scheduled_at: {
                    [Op.gt]: windowStart,
                    [Op.lt]: windowEnd
                }
            }
        });

        if (conflict) {
            return { conflict: true, note: `Slot waktu bertabrakan dengan antrian lain (${conflict.ticket_number})` };
        }

        return { conflict: false, note: 'Slot tersedia' };
    }
}

module.exports = AvailabilityService;
