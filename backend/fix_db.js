const { Sequelize, DataTypes } = require('sequelize');
const config = require('./config/config.json')['development'];

const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    dialect: config.dialect
});

async function fix() {
    try {
        await sequelize.authenticate();
        console.log('Connected.');

        const table = 'doctor_schedule_overrides';
        const [cols] = await sequelize.query(`DESCRIBE ${table}`);
        const colNames = cols.map(c => c.Field);
        console.log('Current Columns:', colNames);

        // 1. Rename 'date' -> 'start_date' if needed
        if (colNames.includes('date') && !colNames.includes('start_date')) {
            console.log('Renaming date -> start_date...');
            await sequelize.query(`ALTER TABLE ${table} CHANGE COLUMN \`date\` \`start_date\` DATE;`); // DATE or DATEONLY
        }

        // 2. Add 'end_date' if missing
        if (!colNames.includes('end_date')) {
            console.log('Adding end_date...');
            await sequelize.query(`ALTER TABLE ${table} ADD COLUMN \`end_date\` DATE AFTER \`start_date\`;`);
            // Update data
            await sequelize.query(`UPDATE ${table} SET end_date = start_date WHERE end_date IS NULL;`);
        }

        // 3. Add 'requested_by' if missing
        if (!colNames.includes('requested_by')) {
            console.log('Adding requested_by...');
            await sequelize.query(`ALTER TABLE ${table} ADD COLUMN \`requested_by\` INT(11) NULL;`);
        }

        // 4. Add 'substitute_doctor_id' if missing
        if (!colNames.includes('substitute_doctor_id')) {
            console.log('Adding substitute_doctor_id...');
            await sequelize.query(`ALTER TABLE ${table} ADD COLUMN \`substitute_doctor_id\` INT(11) NULL;`);
        }

        console.log('Fix Complete.');
        const [newCols] = await sequelize.query(`DESCRIBE ${table}`);
        console.log('New Columns:', newCols.map(c => c.Field));

    } catch (e) {
        console.error(e);
    } finally {
        sequelize.close();
    }
}

fix();
