const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, 'seeders');

fs.readdir(dir, (err, files) => {
    if (err) throw err;

    for (const file of files) {
        if (file.endsWith('.js')) {
            fs.unlink(path.join(dir, file), err => {
                if (err) console.error(`Failed to delete ${file}: ${err}`);
                else console.log(`Deleted ${file}`);
            });
        }
    }
});
