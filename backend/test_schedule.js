const AvailabilityService = require('./services/availabilityService');
const { sequelize } = require('./models');

async function test() {
    try {
        const id = 1; // Dr Budi

        // 1. Check a valid Monday (e.g. 2024-12-23 is Mon)
        const res1 = await AvailabilityService.checkAvailability(id, '2024-12-23');
        console.log('Monday 2024-12-23:', res1);

        // 2. Check Christmas (Override Libur)
        const res2 = await AvailabilityService.checkAvailability(id, '2024-12-25');
        console.log('Christmas 2024-12-25:', res2);

        // 3. Check Sunday (No Schedule)
        const res3 = await AvailabilityService.checkAvailability(id, '2024-12-22');
        console.log('Sunday 2024-12-22:', res3);

    } catch (e) {
        console.error(e);
    }
}

test();
