# Materi Presentasi Aplikasi DataPoli

Dokumen ini berisi konten untuk slide presentasi (visual) dan naskah presenter (speaker notes) untuk aplikasi DataPoli.

---

## Slide 2: Latar Belakang & Masalah

### 🖥️ Konten Slide (Visual)
**Latar Belakang: Inefisiensi dalam Pelayanan Kesehatan**
*   **Kondisi Saat Ini:** Proses administrasi manual memicu antrian fisik yang panjang.

**Masalah Utama**
1.  **Monitoring Jadwal:** Sulit memantau jadwal dokter secara *real-time*.
2.  **Aksesibilitas:** Pasien kesulitan mendaftar tanpa datang langsung ke lokasi.
3.  **Manajemen Data:** Admin tidak memiliki *dashboard* data yang terpusat.

**Solusi Kami**
*   **Aplikasi Mobile Terintegrasi:** Menghubungkan **Pasien**, **Dokter**, dan **Admin** dalam satu ekosistem digital.

### 🗣️ Naskah Presenter
"Bapak/Ibu sekalian, aplikasi ini lahir dari masalah nyata di lapangan. Saat ini, administrasi manual menyebabkan penumpukan pasien. Kami mengidentifikasi tiga masalah krusial: pasien tidak tahu jadwal dokter secara pasti, harus datang fisik hanya untuk mendaftar, dan admin yang kesulitan merekap data harian. Solusi kami adalah aplikasi mobile yang mengintegrasikan ketiga peran ini—Pasien, Dokter, dan Admin—ke dalam satu sistem yang efisien."

---

## Slide 3: Arsitektur & Tech Stack (Mobile Frontend)

### 🖥️ Konten Slide (Visual)
**Framework Utama**
*   **Flutter (Dart SDK ^3.9.2):** Pengembangan lintas platform (*cross-platform*) performa tinggi.

**Implementasi Teknis**
*   **State Management:** `setState` (Native) – Efisien dan ringan untuk skala aplikasi menengah.
*   **Networking:** `dio` (^5.0.0) – Menggunakan **Interceptors** untuk manajemen Token JWT otomatis.
*   **Local Storage:** `shared_preferences` – Persistensi sesi login pengguna.

**UI/UX Modern**
*   **Visual:** `flutter_svg` untuk aset vektor tajam.
*   **Interaksi:** `flutter_staggered_animations` untuk transisi halus.

### 🗣️ Naskah Presenter
"Di sisi frontend mobile, kami menggunakan **Flutter** versi terbaru untuk performa maksimal di Android. Untuk manajemen data, kami memilih pendekatan yang efisien: `setState` untuk state management yang ringan, dan library **Dio** untuk menangani koneksi jaringan yang aman dengan interceptor Token JWT. UI/UX kami dipercantik dengan aset SVG dan animasi stagrered agar aplikasi terasa modern dan hidup."

---

## Slide 4: Arsitektur & Tech Stack (Backend & Database)

### 🖥️ Konten Slide (Visual)
**Server-Side**
*   **Runtime:** Node.js dengan framework **Express.js**.
*   **Security:** JSON Web Token (JWT) untuk autentikasi *stateless* yang aman.

**Database Layer**
*   **Database:** MySQL (Relational Database).
*   **ORM:** **Sequelize** – Mempermudah manipulasi data, relasi, dan migrasi struktur database.

### 🗣️ Naskah Presenter
"Beralih ke sisi Backend, fondasi kami adalah **Node.js** dengan **Express**, yang dikenal cepat dan skalabel. Untuk keamanan, kami menerapkan **JWT** sehingga server tidak terbebani sesi (stateless). Data disimpan di **MySQL**, dikelola melalui **Sequelize ORM** yang memastikan struktur data dan relasi antar tabel terjaga dengan rapi dan mudah dimigrasi."

---

## Slide 5: Database Schema (ERD)

### 🖥️ Konten Slide (Visual)
**Entitas Utama (Core Entities)**
*   **users:** Pusat autentikasi (Menyimpan Email, Password, Role).
*   **dokters & pasiens:** Profil detail yang memiliki relasi ke tabel `users`.
*   **antrians:** Tabel transaksi utama (Berisi Pasien ID, Dokter ID, Status Antrian).

**Struktur Relasi**
*   **1-to-1:** User ke Profil (Satu akun user memiliki satu data profil dokter/pasien).
*   **1-to-Many:** Dokter ke Antrian (Satu dokter melayani banyak antrian).

### 🗣️ Naskah Presenter
"Struktur database kami dirancang terpusat. Tabel `users` adalah jantung autentikasi. Tabel profil seperti `dokters` dan `pasiens` terpisah namun terhubung relasi **1-to-1** ke user, menjaga data akun dan data profil tetap terorganisir. Transaksi utama terjadi di tabel `antrians`, yang mencatat interaksi antara pasien dan dokter dengan status yang dinamis."

---

## Slide 6: Fitur Utama 1: Authentication & Session

### 🖥️ Konten Slide (Visual)
**Mekanisme: Token-based Authentication**

**Alur Kerja**
1.  **Login:** User input kredensial -> API memvalidasi.
2.  **Token:** Server mengirimkan **JWT Token**.
3.  **Storage:** Aplikasi menyimpan Token di `SharedPreferences`.

**Fitur Auto-Login**
*   Pengecekan validitas token terjadi otomatis di **Splash Screen** sebelum masuk ke Beranda.

### 🗣️ Naskah Presenter
"Keamanan akses adalah prioritas. Kami menggunakan mekanisme berbasis Token. Saat user login, server memberikan 'kunci digital' berupa JWT yang disimpan aman di memori lokal HP (`SharedPreferences`). Ini memungkinkan fitur **Auto-Login**: saat aplikasi dibuka kembali, sistem otomatis mengecek kunci tersebut di Splash Screen, sehingga user tidak perlu login berulang kali."

---

## Slide 7: Fitur Utama 2: Role-Based Access Control (RBAC)

### 🖥️ Konten Slide (Visual)
**Konsep: 1 Aplikasi, Multi-Tampilan (Dynamic UI)**
*   UI di-render secara kondisional berdasarkan variabel `_role`.

**Hak Akses**
*   👨‍💼 **Admin:** Menu "Approval Jadwal" & Manajemen "Pegawai".
*   👨‍⚕️ **Dokter:** Menu "Input Diagnosa" & "Jadwal Saya".
*   🏥 **Pasien:** Menu "Pendaftaran Antrian" & "Riwayat Berobat".

### 🗣️ Naskah Presenter
"Satu aplikasi ini pintar beradaptasi. Kami menerapkan **Role-Based Access Control**. Tampilan antarmuka berubah dinamis sesuai siapa yang login. Admin akan melihat menu manajemen, Dokter melihat jadwal dan input medis, sedangkan Pasien fokus pada pendaftaran. Ini menjamin keamanan data dan kemudahan penggunaan karena user hanya melihat fitur yang relevan bagi mereka."

---

## Slide 8: Implementasi: Service Repository Pattern

### 🖥️ Konten Slide (Visual)
**Prinsip: Separation of Concerns (Pemisahan Logika)**

**Struktur Layer**
1.  **UI Layer:** Hanya memanggil fungsi (Contoh: `void getAntrian()`).
2.  **Service Layer:** Menangani logika HTTP Request & API (menggunakan Dio).

**Keuntungan**
*   ✅ Kode lebih rapi (*Clean Code*).
*   ✅ Mudah di-maintenance dan di-test.
*   ✅ Fungsi *Reusable* (dapat digunakan ulang).

### 🗣️ Naskah Presenter
"Agar kode kami tidak 'spaghetti' atau berantakan, kami menerapkan **Service Repository Pattern**. Kami memisahkan logika tampilan (UI) dengan logika data (Service). UI hanya tau cara menampilkan data, sedangkan urusan ambil data ke server diurus oleh Service Layer. Hasilnya? Aplikasi lebih stabil, kode lebih rapi, dan pengembangan fitur baru jadi jauh lebih cepat."

---

## Slide 9: Real-time Dashboard & Dashboard Logic

### 🖥️ Konten Slide (Visual)
**Fitur Dashboard**
*   Menampilkan statistik *real-time* (Antrian Hari Ini, Total Pasien, Jadwal Dokter).

**Tantangan & Solusi**
*   🛑 **Masalah:** Mengambil banyak data secara terpisah bikin loading lambat.
*   💡 **Solusi:** Endpoint Agregasi (`/dashboard/stats`).
    *   Satu request ke server mengembalikan semua data statistik sekaligus.
    *   Meminimalisir beban *request* dari mobile dan mempercepat *load time*.

### 🗣️ Naskah Presenter
"Di halaman Beranda, user butuh info cepat. Tantangannya adalah menampilkan banyak angka statistik tanpa membuat aplikasi lemot. Solusi cerdas kami adalah membuat **Endpoint Agregasi** di backend. Sekali panggil ke `/dashboard/stats`, server meramu semua data yang dibutuhkan, dan mengirimkannya dalam satu paket ringan ke HP. Dashboard tampil instan!"

---

## Slide 10: Struktur Folder Proyek

### 🖥️ Konten Slide (Visual)
**Organisasi Kode (Clean Architecture)**

*   📁 **lib/pages:** File UI utama (Screens/Halaman).
*   📁 **lib/widget:** Komponen UI *reusable* (Sidebar, Custom Buttons).
*   📁 **lib/service:** Logika komunikasi API & Backend.
*   📁 **lib/model:** Mapping data JSON ke Dart Object (*Serialization*).
*   📁 **lib/helpers:** Utilitas pendukung (ApiClient, UserInfo).

### 🗣️ Naskah Presenter
"Kerapian adalah kunci kolaborasi. Struktur folder kami bedakan dengan jelas. `Pages` untuk layar, `Widget` untuk potongan UI yang bisa dipakai ulang seperti tombol atau sidebar, `Service` untuk koneksi internet, dan `Model` untuk format data. Ini memudahkan tim developer menavigasi ribuan baris kode dengan efisien."

---

## Slide 11: Desain UI & Ikonografi

### 🖥️ Konten Slide (Visual)
**Tema: Modern & Medical**
*   **Style:** Minimalis dengan sudut *rounded* pada Card dan Ikon (memberi kesan *friendly*).
*   **Warna:** Dominan Biru/Hijau Medis (Psikologi warna: Ketenangan & Kesehatan).

**Visual Key (Iconography)**
*   🖥️ `monitor_heart`: Indikator Antrian Real-time.
*   🤕 `personal_injury`: Menu Pendaftaran Pasien.
*   (Menggunakan *Material Design Icons Rounded*)

### 🗣️ Naskah Presenter
"Desain aplikasi kesehatan tidak harus kaku. Kami memilih gaya modern dengan sudut membulat (*rounded*) untuk memberikan kesan ramah dan tidak mengintimidasi pasien. Warna dominan biru dan hijau dipilih untuk memberi efek menenangkan. Ikon-ikon dipilih secara semantik, seperti monitor detak jantung untuk antrian, memudahkan user memahami fungsi tombol tanpa perlu banyak membaca."

---

## Slide 12: Tantangan & Solusi Pengembangan

### 🖥️ Konten Slide (Visual)
**Tantangan 1: Koneksi Lambat & Asinkronus**
*   💡 **Solusi:** Penggunaan `FutureBuilder` dan *Loading Shimmer* agar user paham data sedang diproses, bukan aplikasi macet.

**Tantangan 2: Keamanan Sesi (Token Expired)**
*   💡 **Solusi:** Implementasi **Dio Interceptors**.
    *   Secara otomatis mendeteksi Error 401 (Unauthorized).
    *   Mengarahkan user untuk login ulang tanpa *crash*.

### 🗣️ Naskah Presenter
"Dalam pengembangan, kami menghadapi dua tantangan utama. Pertama, koneksi internet Indonesia yang tidak stabil. Kami mengatasinya dengan `FutureBuilder` dan efek *Shimmer*, jadi aplikasi tetap responsif saat loading. Kedua, soal token yang kedaluwarsa. Kami memasang 'penjaga' di sistem jaringan (*Interceptors*) yang otomatis mendeteksi jika sesi habis, dan mengamankan aplikasi secara graceful tanpa error yang membingungkan user."

---

## Slide 13: Kesimpulan

### 🖥️ Konten Slide (Visual)
**DataPoli: Aplikasi Kesehatan Standar Industri**

**Poin Keunggulan Utama**
1.  🔐 **Keamanan:** Terjamin dengan JWT Auth.
2.  ⚡ **Efisiensi:** Arsitektur *Service Pattern* dan komunikasi data yang optimal.
3.  🚀 **Skalabilitas:** Struktur kode modular (RBAC) siap untuk pengembangan fitur lanjutan.

### 🗣️ Naskah Presenter
"Sebagai penutup, DataPoli bukan sekadar aplikasi pendaftaran, tapi sebuah sistem standar industri. Dengan keamanan berbasis JWT, efisiensi kode lewat Service Pattern, dan struktur yang skalabel, aplikasi ini siap diimplementasikan dan dikembangkan lebih jauh untuk kebutuhan fasilitas kesehatan modern. Terima kasih."

---

## Slide 14: Sesi Tanya Jawab (Q&A)

### 🖥️ Konten Slide (Visual)
**Terima kasih!**

*Kami membuka sesi diskusi.*
Silakan ajukan pertanyaan terkait:
*   Implementasi Teknis Flutter
*   Backend Node.js & Database
*   Alur Proses Bisnis

### 🗣️ Naskah Presenter
"Sekian presentasi dari kami. Kami sangat terbuka untuk diskusi. Silakan jika Bapak/Ibu atau rekan-rekan memiliki pertanyaan, baik soal teknis Flutter dan Node.js, maupun alur sistem yang kami bangun. Terima kasih."
