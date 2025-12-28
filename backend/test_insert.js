const { DoctorScheduleOverride } = require('./models');

async function testInsert() {
    try {
        console.log('Attempting INSERT...');
        const res = await DoctorScheduleOverride.create({
            dokter_id: 1,
            start_date: '2025-12-25',
            end_date: '2025-12-27',
            is_available: false,
            note: 'mau ke jogja',
            status: 'Pending',
            substitute_doctor_id: null,
            requested_by: 1
        });
        console.log('Success:', res.toJSON());
    } catch (err) {
        console.error('INSERT FAILED FULL ERROR:');
        console.error(err);
        if (err.parent) console.error('Parent Error:', err.parent);
    }
}

testInsert();
