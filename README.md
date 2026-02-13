# EXAMORA - Secure Assessment Platform

> **Official Secure Assessment Platform by IDS Cyber Security Academy**

[![Java](https://img.shields.io/badge/Java-11+-blue.svg)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Tomcat-10+-yellow.svg)](https://tomcat.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Author-Re--xist-purple.svg)](https://github.com/Re-xist)

---

## Apa Itu Examora?

Examora adalah platform ujian dan sistem evaluasi resmi yang digunakan dalam program **IDS Cyber Security Academy** untuk mengukur, memvalidasi, dan mendokumentasikan kompetensi peserta secara terstruktur.

Examora dirancang sebagai **Secure Online Assessment System** yang memastikan setiap peserta benar-benar memahami konsep keamanan siber sebelum melanjutkan ke tahap praktik dan eksploitasi di lab.

Platform ini bukan sekadar sistem quiz biasa, melainkan bagian dari arsitektur akademik yang terintegrasi dengan:
- Kurikulum pembelajaran
- Lab praktik dan CTF
- Sistem pelaporan akademik
- Standarisasi kelulusan

---

## Fungsi Utama Examora

### Validasi Kompetensi

Examora digunakan untuk memastikan bahwa peserta memahami:
- Konsep dasar cybersecurity
- Logic serangan (SQLi, XSS, SSRF, dll)
- Authentication & session security
- OWASP Top 10
- Metodologi penetration testing

### Platform Ujian Resmi

- Quiz mingguan
- Ujian tengah program
- Final exam
- Pre-test & post-test
- Assessment sebelum akses lab tertentu

### Monitoring & Tracking Progres

- Melihat performa peserta
- Menganalisis kelemahan materi
- Mengukur tingkat kelulusan
- Membuat laporan akademik terpusat

### Secure Assessment System

- Timed exam system
- Randomisasi soal
- Auto grading
- Session validation
- Single submit enforcement
- Secure database handling

---

## Posisi Examora dalam Ekosistem IDS

```
Materi → Examora (Validasi Teori) → Lab / CTF → Final Assessment → Certification
```

Examora berfungsi sebagai **validation layer** antara teori dan praktik.

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Backend | Java 11+, JSP, Servlet |
| Server | Apache Tomcat 10+ |
| Database | MySQL 8.0+ / MariaDB |
| Frontend | HTML5, CSS3, Bootstrap 5 |
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
├── docker-compose.yml         # Docker configuration
├── Dockerfile                 # Docker build file
├── pom.xml                    # Maven configuration
└── README.md                  # This file
```

---

## Security Features

- Password hashing (SHA-256 with salt)
- SQL injection prevention (Prepared Statements)
- XSS prevention (Input sanitization)
- Session management
- Role-based access control
- Quiz deadline validation
- Timezone-aware timestamp handling

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
