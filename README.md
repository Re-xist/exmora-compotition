# Examora - Smart Assessment Platform

> **Modern, Secure, and Scalable Online Examination System**

[![Java](https://img.shields.io/badge/Java-11+-blue.svg)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Tomcat-10+-yellow.svg)](https://tomcat.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Author-Re--xist-purple.svg)](https://github.com/Re-xist)

## Overview

Examora is a comprehensive online examination system designed for schools, corporate training, and certification programs. Built with modern architecture principles, it provides a secure and scalable platform for conducting quizzes and exams.

## Features

- **User Management**: Multi-role system (Admin/Participant)
- **Quiz Management**: Create, edit, publish quizzes with ease
- **Question Bank**: Multiple choice questions with 4 options
- **Auto-Scoring**: Automatic score calculation
- **Timer System**: Countdown timer with auto-submit
- **Result Analysis**: Detailed score reports and statistics
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Security**: Password hashing, CSRF protection, input sanitization

## Technology Stack

| Component | Technology |
|-----------|------------|
| Backend | Java 11+, JSP, Servlet |
| Server | Apache Tomcat 10+ |
| Database | MySQL 8.0+ / MariaDB |
| Frontend | HTML5, CSS3, Bootstrap 5 |
| Build Tool | Maven |

## Quick Start

### Prerequisites

- Java Development Kit (JDK) 11 or higher
- Apache Maven 3.6+
- MySQL 8.0+ or MariaDB
- Apache Tomcat 10+

### Installation

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

   Edit `src/main/resources/db.properties` or update `src/main/webapp/WEB-INF/web.xml`:
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

## Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@examora.com | admin123 |
| User | user@examora.com | user123 |

> **Important**: Change the default passwords in production!

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
├── pom.xml                    # Maven configuration
└── README.md                  # This file
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/LoginServlet` | GET/POST | User authentication |
| `/RegisterServlet` | GET/POST | User registration |
| `/LogoutServlet` | GET/POST | User logout |
| `/QuizServlet` | GET/POST | Quiz CRUD operations |
| `/QuestionServlet` | GET/POST | Question management |
| `/ExamServlet` | GET/POST | Exam taking operations |
| `/AdminServlet` | GET/POST | Admin dashboard |

## Database Schema

- **users**: User accounts (admin/peserta)
- **quiz**: Quiz/exam definitions
- **questions**: Multiple choice questions
- **submissions**: User exam submissions
- **answers**: Individual question answers
- **quiz_sessions**: Active exam sessions

## Security Features

- Password hashing (SHA-256 with salt)
- SQL injection prevention (Prepared Statements)
- XSS prevention (Input sanitization)
- CSRF token protection
- Session management
- Role-based access control

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@examora.com or join our Discord channel.

## Author

**Re-xist** - [GitHub](https://github.com/Re-xist)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Examora** - Empowering Education Through Technology

Made with ❤️ by [Re-xist](https://github.com/Re-xist)
