# EXAMORA - Secure Assessment Platform

> **Official Secure Assessment Platform by IDS Cyber Security Academy**

[![Java](https://img.shields.io/badge/Java-11+-blue.svg)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Tomcat-10+-yellow.svg)](https://tomcat.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Author-Re--xist-purple.svg)](https://github.com/Re-xist)

---

## Apa Itu Examora?

Examora adalah platform ujian online lengkap yang digunakan dalam program **IDS Cyber Security Academy** untuk mengukur, memvalidasi, dan mendokumentasikan kompetensi peserta secara terstruktur melalui sistem quiz teori.

Platform ini dilengkapi dengan fitur **Quiz Online**, **Arena Mode** (kompetisi real-time), **Sistem Absensi**, **Integrasi Google Drive** untuk pengumpulan tugas dan feedback mentor, serta **Statistik & Analitik** lengkap.

---

## Fitur Utama

### 1. Manajemen Quiz
- Buat dan kelola quiz dengan multiple choice questions
- Atur durasi dan timer countdown dengan auto-submit
- Set deadline per quiz dengan timezone WIB
- Publish/unpublish quiz ke peserta
- Support gambar pada soal dan opsi jawaban

### 2. Arena Mode (Real-time Competition)
- Mode kompetisi quiz secara real-time
- Host membuat room dengan kode unik
- Peserta bergabung dengan kode arena
- Real-time leaderboard dan live scoring
- Timer per soal untuk keseruan maksimal

### 3. Sistem Absensi
- Admin membuat sesi absensi dengan kode unik 6 karakter
- Peserta input kode untuk melakukan absensi
- Target absensi per tag/kelompok
- Jadwal sesi dengan waktu mulai dan selesai
- Deteksi terlambat otomatis dengan threshold yang dapat dikustomisasi
- Export rekap kehadiran ke PDF dan CSV
- Riwayat absensi peserta

### 4. Integrasi Google Drive
- Setiap peserta memiliki link Google Drive pribadi
- Untuk pengumpulan tugas dan assignment
- Menerima feedback dari mentor
- Dokumen pembelajaran dan hasil review

### 5. Statistik & Analitik
- Distribusi nilai visual (chart)
- Pass rate analysis
- Detail hasil per peserta
- Export hasil ke PDF
- Analisis performa per soal

### 6. Manajemen User
- Multi-role system (Admin & Peserta)
- Tag/kelompok untuk grouping peserta
- Import CSV untuk pendaftaran massal
- CRUD user lengkap dengan foto profil

### 7. Riwayat Ujian
- History lengkap semua pengerjaan
- Review jawaban dan pembahasan
- Detail skor per quiz
- Waktu pengerjaan tersimpan

### 8. Auto Grading
- Koreksi otomatis instan
- Perhitungan skor real-time
- Feedback langsung setelah submit
- Hasil akurat dan transparan

### 9. Secure Assessment
- Session validation
- Prevent cheating (disable context menu, text selection)
- Single submit enforcement
- Secure database handling
- Password hashing (SHA-256 with salt)

### 10. Profil & Settings
- Upload foto profil
- Ganti password
- Edit profil peserta

---

## Posisi Examora dalam Ekosistem IDS

```
Materi → Examora (Quiz Teori + Nilai) → Lab / CTF → Final Assessment → Certification
```

Examora berfungsi sebagai **platform asesmen teori** dimana peserta mengerjakan soal quiz untuk mendapatkan nilai dari pengyelenggara.

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Backend | Java 11+, JSP, Servlet |
| Server | Apache Tomcat 10+ |
| Database | MySQL 8.0+ / MariaDB |
| Frontend | HTML5, CSS3, Bootstrap 5, Bootstrap Icons |
| Charts | Chart.js |
| Export | html2pdf.js |
| Build Tool | Maven |
| Container | Docker & Docker Compose |

---

## Quick Start

### Prerequisites

- Java Development Kit (JDK) 11 or higher
- Apache Maven 3.6+
- MySQL 8.0+ or MariaDB
- Apache Tomcat 10+ (or Docker)

### Installation with Docker (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/Re-xist/examora.git
   cd examora
   ```

2. **Run with Docker Compose**
   ```bash
   docker-compose up -d --build
   ```

3. **Access the application**

   Open your browser and navigate to: `http://localhost:8888`

### Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Re-xist/examora.git
   cd examora
   ```

2. **Create the database**
   ```bash
   mysql -u root -p < sql/schema.sql
   ```

3. **Configure database connection**

   Edit `src/main/resources/db.properties`:
   ```properties
   db.url=jdbc:mysql://localhost:3306/examora_db
   db.username=root
   db.password=your_password
   ```

4. **Build the project**
   ```bash
   mvn clean package
   ```

5. **Deploy to Tomcat**
   ```bash
   cp target/examora.war $TOMCAT_HOME/webapps/
   ```

6. **Start Tomcat**
   ```bash
   $TOMCAT_HOME/bin/startup.sh
   ```

7. **Access the application**

   Open your browser and navigate to: `http://localhost:8080/examora`

---

## Project Structure

```
Examora/
├── src/
│   ├── main/
│   │   ├── java/com/examora/
│   │   │   ├── controller/    # Servlet controllers
│   │   │   ├── dao/           # Data Access Objects
│   │   │   ├── filter/        # Security filters
│   │   │   ├── model/         # Entity classes
│   │   │   ├── service/       # Business logic
│   │   │   └── util/          # Utility classes
│   │   ├── resources/         # Configuration files
│   │   └── webapp/
│   │       ├── admin/         # Admin JSP pages
│   │       ├── user/          # User JSP pages
│   │       ├── common/        # Shared JSP pages
│   │       ├── assets/        # CSS, JS, images
│   │       └── WEB-INF/       # Web configuration
│   └── test/                  # Test classes
├── sql/                       # Database scripts
│   ├── schema.sql             # Main database schema
│   ├── sample_data.sql        # Sample data
│   └── add_*.sql              # Migration scripts
├── docker-compose.yml         # Docker configuration
├── Dockerfile                 # Docker build file
├── pom.xml                    # Maven configuration
└── README.md                  # This file
```

---

## Default Accounts

Setelah instalasi, Anda dapat login dengan akun default:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@examora.com | admin123 |

---

## Security Features

- Password hashing (SHA-256 with salt)
- SQL injection prevention (Prepared Statements)
- XSS prevention (Input sanitization)
- Session management
- Role-based access control
- Quiz deadline validation
- Timezone-aware timestamp handling (WIB/Jakarta)
- CSRF protection

---

## Screenshot

### Landing Page
Halaman utama dengan informasi fitur lengkap

### Dashboard Admin
- Kelola Quiz
- Kelola User dengan Import CSV
- Kelola Arena
- Kelola Absensi
- Lihat Statistik

### Dashboard Peserta
- Quiz Tersedia
- Arena Mode
- Absensi dengan Kode Unik
- Riwayat Ujian
- Google Drive Integration

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## Support & Contribution

Jika Anda ingin mendukung pengembangan berkelanjutan platform Examora, Anda dapat memberikan dukungan melalui:

| | |
|---|---|
| **Support Page** | [https://saweria.co/rexist](https://saweria.co/rexist) |

Dukungan Anda akan membantu pengembangan fitur baru, peningkatan keamanan sistem, dan inovasi platform assessment di masa depan.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Developer & Repository

| | |
|---|---|
| **Developer** | Re-xist |
| **Repository** | [https://github.com/Re-xist](https://github.com/Re-xist) |

Seluruh pengembangan sistem mengikuti prinsip **clean architecture**, **secure coding practice**, dan **production-ready deployment standard**.

---

**Examora** - Empowering Education Through Technology

Made with love by [Re-xist](https://github.com/Re-xist)
