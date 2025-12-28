const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function deepClean() {
    try {
        await sequelize.authenticate();
        console.log('Connected.');

        const tables = ['dokters', 'pegawais', 'pasiens'];
        const dbName = config.database;

        for (const table of tables) {
            // Find FK constraint name for user_id
            const sql = `
            SELECT CONSTRAINT_NAME 
            FROM information_schema.KEY_COLUMN_USAGE 
            WHERE TABLE_NAME = '${table}' 
            AND COLUMN_NAME = 'user_id' 
            AND TABLE_SCHEMA = '${dbName}';
        `;
            const [results] = await sequelize.query(sql);

            for (const row of results) {
                const constraint = row.CONSTRAINT_NAME;
                console.log(`Dropping FK ${constraint} on ${table}...`);
                try {
                    await sequelize.query(`ALTER TABLE ${table} DROP FOREIGN KEY ${constraint}`);
                } catch (e) {
                    console.log(`Error dropping FK ${constraint}: ` + e.message);
                }
            }

            // Now drop column
            console.log(`Dropping user_id on ${table}...`);
            try {
                await sequelize.query(`ALTER TABLE ${table} DROP COLUMN user_id`);
            } catch (e) {
                console.log(`Error dropping column on ${table}: ` + e.message);
            }
        }

        try {
            await sequelize.query("DROP TABLE IF EXISTS users");
            console.log("Dropped users table");
        } catch (e) {
            console.log(e.message);
        }

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

deepClean();
