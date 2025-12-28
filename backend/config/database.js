const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

const sequelize = new Sequelize('klinik_db', 'root', '', {
	host: 'localhost',
	dialect: 'mysql',
});

module.exports = sequelize;
