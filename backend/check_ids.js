const { Pasien, Dokter, Poli } = require('./models');

async function check() {
    try {
        const p = await Pasien.findByPk(3);
        const d = await Dokter.findByPk(1);
        const pl = await Poli.findByPk(1);

        console.log('Pasien 3:', p ? 'Found' : 'Not Found');
        console.log('Dokter 1:', d ? 'Found' : 'Not Found');
        console.log('Poli 1:', pl ? 'Found' : 'Not Found');
    } catch (e) {
        console.error(e);
    }
}

check();
