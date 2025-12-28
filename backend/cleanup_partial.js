const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function cleanup() {
    try {
        await sequelize.authenticate();
        console.log('Connected. cleaning up...');

        const t = await sequelize.transaction();

        try {
            // Disable FK Checks
            await sequelize.query("SET FOREIGN_KEY_CHECKS = 0", { transaction: t });

            // Drop user_id columns if exist
            try { await sequelize.query("ALTER TABLE dokters DROP COLUMN user_id", { transaction: t }); console.log('Dropped dokters.user_id'); } catch (e) { console.log('dokters:', e.message); }
            try { await sequelize.query("ALTER TABLE pegawais DROP COLUMN user_id", { transaction: t }); console.log('Dropped pegawais.user_id'); } catch (e) { console.log('pegawais:', e.message); }
            try { await sequelize.query("ALTER TABLE pasiens DROP COLUMN user_id", { transaction: t }); console.log('Dropped pasiens.user_id'); } catch (e) { console.log('pasiens:', e.message); }

            // Drop users table
            try { await sequelize.query("DROP TABLE IF EXISTS users", { transaction: t }); console.log('Dropped users table'); } catch (e) { console.log('users:', e.message); }

            // Enable FK Checks
            await sequelize.query("SET FOREIGN_KEY_CHECKS = 1", { transaction: t });

            await t.commit();
            console.log('Cleanup Committed.');
        } catch (error) {
            await t.rollback();
            console.error('Cleanup Rolled back:', error);
        }

        console.log('Cleanup Done.');

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

cleanup();
