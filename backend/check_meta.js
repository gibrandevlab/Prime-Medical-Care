const { Sequelize } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function checkMeta() {
    try {
        await sequelize.authenticate();
        const [results] = await sequelize.query("SELECT * FROM SequelizeMeta");
        console.log(results.map(r => r.name));
    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

checkMeta();
