const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function forceDrop() {
    try {
        await sequelize.authenticate();
        console.log('Connected.');

        // We cannot guarantee same connection without transaction or connection acquisition.
        // So we use a managed transaction but expect implicit commits.
        // Or we just try to drop.

        const [results] = await sequelize.query("SELECT DATABASE()");
        console.log('DB:', results);

        // Try dropping user_id from dokters
        try {
            // Disable FK checks globally for this session? 
            // We really need to ensure we don't fail on FK.
            // Let's try to remove FK references first.

            // Find constraints?
            // Hard to find names.

            // Just try simpler approach:
            // If users table is gone, the FK constraint MIGHT be gone or broken.
            // MySQL reference: If you drop parent table, child FKs might remain but be broken.

            await sequelize.query(`ALTER TABLE dokters DROP COLUMN user_id`);
            console.log('Dropped dokters.user_id');
        } catch (e) { console.log('dokters error:', e.message); }

        try {
            await sequelize.query(`ALTER TABLE pegawais DROP COLUMN user_id`);
            console.log('Dropped pegawais.user_id');
        } catch (e) { console.log('pegawais error:', e.message); }

        try {
            await sequelize.query(`ALTER TABLE pasiens DROP COLUMN user_id`);
            console.log('Dropped pasiens.user_id');
        } catch (e) { console.log('pasiens error:', e.message); }

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

forceDrop();
