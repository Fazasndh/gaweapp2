Dokumentasi Proyek: Gawee App
1. Deskripsi Aplikasi
   Gawee App merupakan sistem informasi berbasis mobile yang dikembangkan untuk memfasilitasi para seeker untuk mencari pekerjaan dan untuk company memposting lowongan kerja.
   Aplikasi ini dirancang menggunakan arsitektur client-server, di mana Flutter digunakan untuk pengembangan antarmuka pengguna (front-end) dan Laravel digunakan sebagai kerangka kerja back-end untuk mengelola logika bisnis, autentikasi, serta persistensi data.

2. Cara Menjalankan Backend (Laravel)
   - Pastikan lingkungan pengembangan PHP telah terpasang (seperti XAMPP atau Laragon).
   - Masuk ke direktori back-end melalui terminal.
   - Instal dependensi dengan menjalankan perintah: composer install
   - Salin file .env.example menjadi .env dan konfigurasikan basis data Anda.
   - Jalankan migrasi basis data: php artisan migrate
   - Jalankan server dengan perintah berikut agar dapat diakses oleh perangkat seluler dalam satu jaringan: php artisan serve --host=0.0.0.0 --port=8000

3. Cara Menjalankan Proyek Flutter
   - Pastikan Flutter SDK telah terkonfigurasi dengan benar di perangkat Anda.
   - Masuk ke direktori proyek Flutter.
   - Instal dependensi yang diperlukan: flutter pub get
   - Sesuaikan konfigurasi API pada file lib/services/api_service.dart: static const String baseUrl = 'http://192.168.18.32:8000/api';
   - Hubungkan perangkat seluler melalui kabel data (pastikan USB Debugging aktif) atau gunakan emulator.
   - Jalankan aplikasi: flutter run
     
4. Konfigurasi Basis Data
   Konfigurasi basis data dilakukan pada file .env di direktori Laravel:
   DB_CONNECTION: mysql
   DB_HOST: 127.0.0.1
   DB_PORT: 3306
   DB_DATABASE: db_gawee
   DB_USERNAME: root
   DB_PASSWORD: -

5. Cara Penggunaan API
   Aplikasi ini berkomunikasi dengan server melalui format JSON menggunakan metode HTTP request. Berikut adalah endpoint utama yang digunakan:
   - Autentikasi: POST /api/login - Digunakan untuk memverifikasi kredensial pengguna dan mendapatkan access token.
   - Manajemen Pekerjaan: GET /api/jobs - Mengambil daftar seluruh lowongan pekerjaan yang tersedia.
   - Profil Perusahaan: GET /api/company/profile - Mengambil informasi profil perusahaan yang sedang masuk (logged in).

6. Akun Login (Uji Coba)
   Untuk keperluan evaluasi, berikut adalah data akun yang dapat digunakan:
   - company
     Email: hrd@abadi.co.id
     Password: password123
   - Seeker:
     Email: fazas@gmail.com
     Password: password123
     
Catatan Penting:
- Pastikan laptop dan perangkat seluler terhubung ke titik akses Wi-Fi yang sama.
- Apabila terjadi kendala koneksi (Connection Timeout), harap pastikan Firewall Windows telah memberikan izin akses (Allow) untuk port 8000.
