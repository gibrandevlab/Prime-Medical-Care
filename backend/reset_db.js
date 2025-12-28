const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect,
    logging: false
});

async function reset() {
    try {
        await sequelize.authenticate();
        console.log('Connected. Resetting DB...');

        await sequelize.query("SET FOREIGN_KEY_CHECKS = 0");

        const [tables] = await sequelize.query("SHOW TABLES");
        for (const row of tables) {
            const tableName = Object.values(row)[0];
            if (tableName === 'sequelize_meta') continue; // Keep meta? No, usually reset means reset meta too for fresh migrate.
            // Actually user said "migrate", implying run migrations from scratch.
        }

        // Drop everything including SequelizeMeta to ensure clean migrate
        const [allTables] = await sequelize.query("SHOW TABLES");
        for (const row of allTables) {
            const tableName = Object.values(row)[0];
            console.log(`Dropping ${tableName}...`);
            await sequelize.query(`DROP TABLE IF EXISTS ${tableName}`);
        }

        await sequelize.query("SET FOREIGN_KEY_CHECKS = 1");
        console.log('Reset Complete.');

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

reset();
