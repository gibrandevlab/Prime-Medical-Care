const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function check() {
    try {
        await sequelize.authenticate();

        // Check tables
        const [tables] = await sequelize.query("SHOW TABLES LIKE 'users'");
        console.log('Users table:', tables);

        // Check columns in dokters
        const [dCols] = await sequelize.query("SHOW COLUMNS FROM dokters LIKE 'user_id'");
        console.log('Dokters.user_id:', dCols);

        // Check columns in pegawais
        const [pCols] = await sequelize.query("SHOW COLUMNS FROM pegawais LIKE 'user_id'");
        console.log('Pegawais.user_id:', pCols);

        // Check columns in pasiens
        const [pasCols] = await sequelize.query("SHOW COLUMNS FROM pasiens LIKE 'user_id'");
        console.log('Pasiens.user_id:', pasCols);

        // Check if email column exists in dokters (to verify if we can safe drop users)
        const [dEmail] = await sequelize.query("SHOW COLUMNS FROM dokters LIKE 'email'");
        console.log('Dokters.email:', dEmail);

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

check();
