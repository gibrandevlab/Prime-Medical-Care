const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];
const { User, Poli, Dokter, Pasien } = require('./models');

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function check() {
    try {
        await sequelize.authenticate();
        console.log('Connection OK.');

        // 1. Check Polis
        const polis = await Poli.findAll();
        console.log(`Found ${polis.length} polis.`);
        polis.forEach(p => console.log(` - ${p.nama_poli} (${p.keterangan})`));

        // 2. Check Users
        const users = await User.findAll();
        console.log(`Found ${users.length} users.`);

        // 3. Check Dokters
        const dokters = await Dokter.findAll({ include: User });
        console.log(`Found ${dokters.length} dokters.`);
        dokters.forEach(d => console.log(` - ${d.nama} (User ID: ${d.userId}, Role: ${d.User?.role})`));

    } catch (err) {
        console.error('Error:', err);
    } finally {
        await sequelize.close();
    }
}

check();
