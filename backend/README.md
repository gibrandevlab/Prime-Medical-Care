# Aplikasi Poliklinik — Database setup (Sequelize)

This folder contains Sequelize migrations and seeders to create the database schema and populate it with realistic dummy data for local development.

Prerequisites
- Node.js (>=14)
- MySQL server
- `npx sequelize-cli` available (installed locally via devDependencies or use `npx`)

Configuration
1. Edit the database connection at `backend/config/config.json` (development section). By default it points to:

- database: `klinik_db`
- username: `root`
- password: `` (empty)
- host: `127.0.0.1`
- dialect: `mysql`

If you already use a different connection approach (e.g. `backend/config/database.js`), keep that for runtime — `sequelize-cli` uses `config/config.json` when running migrations/seeders.

Install dependencies

```bash
cd backend
npm install
```

Generate the database and run migrations
1. Create the MySQL database (example):

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS klinik_db;"
```

2. Run migrations:

```bash
npx sequelize-cli db:migrate --config config/config.json
```

Run all seeders

```bash
npx sequelize-cli db:seed:all --config config/config.json
```

Start server

```bash
npm start
# or with nodemon
nodemon app.js
```

Default seeded credentials
- Admin:
  - email: `siti.nurhayati@example.com`
  - password: `admin123`

- Petugas 1:
  - email: `andi.saputra@example.com`
  - password: `petugas123`

- Petugas 2:
  - email: `dewi.kartika@example.com`
  - password: `petugas456`

Notes & Tips
- Passwords in the `pegawais` seeder are hashed with `bcryptjs`.
- The seeders assume `polis` seed creates 4 entries (ids 1..4) which are referenced by the `dokters` seeder.
- If you customize table names or model definitions, ensure migration table names and seeders match your models.

Sequelize CLI commands used to initially generate files
(run these only if you want to scaffold files with `sequelize-cli` instead of using the files provided here):

```bash
# Initialize (if not already done)
npx sequelize-cli init

# Generate models+migration (example commands)
npx sequelize-cli model:generate --name Poli --attributes nama_poli:string,keterangan:text
npx sequelize-cli model:generate --name Pegawai --attributes nip:string,nama:string,tanggal_lahir:date,nomor_telepon:string,email:string,password:string,role:enum
npx sequelize-cli model:generate --name Dokter --attributes nama:string,nip:string,nomor_telepon:string,poli_id:integer
npx sequelize-cli model:generate --name Pasien --attributes nomor_rm:string,nik:string,nama:string,tanggal_lahir:date,nomor_telepon:string,alamat:text

# After generating, edit migrations to set foreign keys and timestamps as desired, then run:
npx sequelize-cli db:migrate
npx sequelize-cli db:seed:all
```

If you run into issues
- Ensure `config/config.json` matches your MySQL credentials.
- Make sure MySQL server is running and the `klinik_db` database exists (or create it manually).
- If enum types cause problems when rolling back, you can manually drop the enum type in your DB or adjust migration `down` logic.
