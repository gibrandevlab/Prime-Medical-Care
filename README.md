# DataPoli - Sistem Informasi Manajemen Poliklinik

## 📋 Latar Belakang & Permasalahan

Dalam operasional poliklinik konvensional, seringkali ditemukan berbagai kendala administratif dan operasional yang menghambat pelayanan kesehatan, antara lain:
*   **Manajemen Antrian yang Tidak Efisien**: Penumpukan pasien di ruang tunggu karena sistem antrian manual.
*   **Pencatatan Rekam Medis**: Kesulitan dalam mencari dan mengelola riwayat medis pasien secara fisik.
*   **Penjadwalan Dokter**: Konflik jadwal dan kesulitan dalam mengelola absensi atau penggantian jadwal dokter.
*   **Akses Informasi**: Pasien kesulitan mendapatkan informasi real-time mengenai status antrian dan jadwal dokter.

**DataPoli** hadir sebagai solusi komprehensif untuk mendigitalisasi proses-proses tersebut, mengintegrasikan manajemen antrian, rekam medis, dan administrasi kepegawaian dalam satu ekosistem yang terpadu.

---

## 🚀 Fitur Utama

Sistem ini memiliki fitur yang dibedakan berdasarkan hak akses pengguna:

### 🏥 Administrator
*   **Manajemen User**: Mengelola akun untuk Dokter, Pegawai, dan Pasien.
*   **Manajemen Data Master**: Mengelola data Poli, Jadwal Dokter, dan konfigurasi klinik.
*   **Dashboard Statistik**: Melihat ringkasan operasional klinik.
*   **Approval Jadwal**: Menyetujui atau menolak pengajuan libur/ganti jadwal dokter.

### 👨‍⚕️ Dokter
*   **Jadwal & Absensi**: Melihat jadwal praktik dan mengajukan perubahan jadwal (override/libur).
*   **Manajemen Pasien**: Melihat daftar antrian pasien yang ditugaskan.
*   **Rekam Medis**: Membuat dan melihat riwayat rekam medis (anamnesa, diagnosa, tindakan, resep).
*   **Dashboard Dokter**: Ringkasan pasien hari ini dan jadwal.

### 🧑‍💼 Petugas (Staff)
*   **Registrasi Pasien**: Mendaftarkan pasien baru dan mengelola data pasien.
*   **Manajemen Antrian**: Mengatur antrian harian (check-in, panggil, selesai).
*   **Administrasi**: Membantu operasional harian klinik.

### 🧑‍🦱 Pasien
*   **Dashboard Pasien**: Melihat status antrian aktif.
*   **Riwayat Medis**: Mengakses riwayat kunjungan dan diagnosa sendiri.
*   **Informasi Jadwal**: Melihat jadwal dokter dan poli yang tersedia.

---

## 📂 Struktur Proyek

Proyek ini menggunakan arsitektur **Monorepo** yang memisahkan Backend dan Frontend.

```
datapoli/
├── backend/                # Server-side Application (Node.js/Express)
│   ├── config/             # Konfigurasi Database
│   ├── controllers/        # Logika Bisnis & Request Handler
│   ├── middleware/         # Auth & Validation Middleware
│   ├── migrations/         # Database Migrations (Sequelize)
│   ├── models/             # Database Models (Schema Definition)
│   ├── routes/             # API Endpoints Definition
│   ├── seeders/            # Initial Data Seeding
│   ├── services/           # Business Logic Layer (Optional)
│   └── app.js              # Entry Point Backend
│
└── frontend/               # Client-side Application (Flutter)
    ├── lib/
    │   ├── ui/             # Halaman & Tampilan (Screens)
    │   ├── widget/         # Komponen UI Reusable
    │   ├── model/          # Data Models
    │   ├── service/        # API Client Services
    │   ├── helpers/        # Utility & Constants
    │   └── main.dart       # Entry Point Frontend
    ├── android/            # Native Android Config
    └── ios/                # Native iOS Config
```

---

## 🗄️ Skema Database

Sistem menggunakan **MySQL** dengan tabel-tabel berikut yang saling berelasi:

| Tabel | Deskripsi | Relasi Utama |
| :--- | :--- | :--- |
| **users** | Tabel utama untuk autentikasi (email, password, role). | Parent dari `pasiens`, `dokters`, `pegawais`. |
| **pasiens** | Data profil pasien (RM, NIK, Nama, Alamat). | `user_id` (FK ke users). |
| **dokters** | Data profil dokter (NIP, Poli). | `user_id` (FK ke users), `poli_id`. |
| **pegawais** | Data profil pegawai/staff. | `user_id` (FK ke users). |
| **polis** | Data poliklinik (Nama Poli). | Direferensikan oleh `dokters`. |
| **antrians** | Data antrian kunjungan. | `dokter_id`, `pasien_id` (implied). |
| **medical_records** | Catatan medis hasil pemeriksaan. | `pasien_id`, `dokter_id`. |
| **doctor_schedules** | Jadwal rutin dokter. | `dokter_id`. |
| **doctor_schedule_overrides** | Perubahan jadwal (cuti/ganti) dokter. | `dokter_id`. |

---

## 🔌 Dokumentasi API Endpoint

Berikut adalah daftar endpoint utama yang tersedia di Backend:

### **Authentication**
*   `POST /auth/login` - Login user untuk mendapatkan JWT Token.

### **Pasien**
*   `GET /pasien` - List semua pasien (Admin/Petugas).
*   `GET /pasien/:id` - Detail pasien.
*   `POST /pasien` - Tambah pasien baru (Admin/Petugas).
*   `PUT /pasien/:id` - Update data pasien.
*   `DELETE /pasien/:id` - Hapus data pasien.

### **Dokter**
*   `GET /dokter` - List semua dokter.
*   `GET /dokter/:id` - Detail dokter.
*   `POST /dokter` - Tambah dokter (Admin).
*   `PUT /dokter/:id` - Update data dokter.

### **Antrian**
*   `GET /antrian` - List antrian.
*   `GET /antrian/dokter/:dokterId` - List antrian spesifik dokter.
*   `POST /antrian` - Buat antrian baru (Petugas).
*   `PUT /antrian/:id/status` - Update status antrian (Menunggu -> Dipanggil -> Selesai).

### **Medical Record (Rekam Medis)**
*   `POST /medical-record` - Buat rekam medis baru (Dokter).
*   `GET /medical-record/pasien/:pasienId` - Lihat riwayat medis pasien.
*   `GET /medical-record/:id` - Detail rekam medis.

### **Pegawai**
*   `GET /pegawai` - List pegawai.
*   `POST /pegawai` - Tambah pegawai (Admin).
*   `PUT /pegawai/:id` - Update data pegawai.

### **Jadwal & Poliklinik**
*   `GET /poli` - List data poli.
*   `GET /schedule/:dokterId` - Lihat jadwal dokter.
*   `POST /schedule/request-override` - Dokter mengajukan perubahan jadwal.
*   `PUT /schedule/approve-override/:id` - Admin menyetujui perubahan jadwal.

---

## 🛠️ Instalasi & Menjalankan

### Persyaratan
*   Node.js & NPM
*   Flutter SDK
*   MySQL Database

### Backend Setup
1.  Masuk ke folder backend: `cd backend`
2.  Install dependencies: `npm install`
3.  Konfigurasi database di `config/database.js` atau `.env`.
4.  Jalankan migrasi database: `npx sequelize-cli db:migrate`
5.  Jalankan seeder (opsional): `npx sequelize-cli db:seed:all`
6.  Jalankan server: `npm start` atau `npm run dev`

### Frontend Setup
1.  Masuk ke folder frontend: `cd frontend`
2.  Install dependencies: `flutter pub get`
3.  Jalankan aplikasi: `flutter run`