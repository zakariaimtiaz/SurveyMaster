<div align="center">

# SurveyMaster

**A full-stack questionnaire form-builder with a visual flow editor, multi-tenancy, and offline mobile data collection.**

[![Java](https://img.shields.io/badge/Java-1.8-orange.svg)](https://www.java.com)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.0.2-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8-blue.svg)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Features

- **Visual Questionnaire Builder** — Drag-and-drop list view with a jsPlumb-powered flow editor for branching logic
- **Dynamic Question Types** — Text, number, select, radio, checkbox, date, file upload, sections, and calculated fields
- **Conditional Logic** — Show/hide questions and jump to specific questions based on answers
- **Multi-Tenancy** — Each company sees only its own questionnaires, agents, and responses
- **Role-Based Access** — Admin and User roles with Spring Security
- **QR Code Generation** — Per-company and per-questionnaire QR codes for mobile access
- **API Key Authentication** — Flutter mobile client authenticates via API keys
- **CSV Export** — Export responses to CSV with one click
- **JSON Import/Export** — Share questionnaire configs between instances
- **Responsive UI** — Bootstrap 5 frontend, no build step required

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java 8, Spring Boot 2.0.2, Spring Security, Spring JDBC |
| Frontend | JSP, Vanilla JS (ES5), Bootstrap 5, jsPlumb |
| Database | MySQL 8 (HikariCP connection pool) |
| Build | Maven, WAR packaging |
| Mobile | Flutter 3.x (Android + iOS, offline-first) |
| QR Codes | ZXing 3.5.1 |

## Getting Started

### Prerequisites

- **JDK 1.8** (required — Spring Boot 2.0.2 + CGLIB fails on JDK 11+)
- **Maven 3.x**
- **MySQL 8**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/zakariaimtiaz/SurveyMaster.git
   cd SurveyMaster
   ```

2. **Configure the database**
   ```bash
   cp src/main/resources/application.properties.example src/main/resources/application.properties
   ```
   Edit `application.properties` and set your MySQL credentials:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/survey_master?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
   spring.datasource.username=your_username
   spring.datasource.password=your_password
   ```

3. **Initialize the database schema** (optional)
   ```properties
   app.db.init-schema=true
   ```
   This runs `db-schema.sql` on startup — safe to re-run (`IF NOT EXISTS` / `INSERT IGNORE`).

4. **Build and run**
   ```bash
   mvn clean package -DskipTests
   java -jar target/SurveyMaster-1.0.1.war
   ```

5. **Access the application**
   ```
   http://localhost:8080/SurveyMaster/
   ```

### Default Login

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `123` |

> **Note:** Change the admin password after first login.

## Development

Run with the `dev` profile for hot-reload:

```bash
java -jar target/SurveyMaster-1.0.1.war --spring.profiles.active=dev
```

- JSPs recompile automatically — just refresh the browser
- CSS/JS/images under `src/main/webapp/resources/` are served directly from source — edit and refresh
- Java changes require a rebuild to trigger devtools restart

## Project Structure

```
SurveyMaster/
├── src/main/java/com/imtiaz/
│   ├── App.java                    # Entry point
│   ├── config/                     # Web config, schema init, properties
│   ├── controller/                 # REST + MVC controllers
│   ├── model/                      # JPA/Security models
│   ├── repo/                       # Data access layer
│   └── security/                   # Spring Security config
├── src/main/resources/
│   ├── application.properties      # Main config (gitignored)
│   ├── application.properties.example
│   ├── db-schema.sql               # Schema + seed data
│   └── db-migration.sql            # Migration scripts
├── src/main/webapp/
│   ├── view/                       # JSP views
│   └── resources/                  # Static assets (CSS, JS, images)
├── pom.xml
└── README.md
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/response/submit` | POST | Submit questionnaire response (API key auth) |
| `/response/export/csv` | GET | Export responses as CSV |
| `/company/{id}/qrcode` | GET | Download company QR code (PNG) |
| `/company/{id}/apikey/generate-token` | GET | Generate API key token |
| `/questionnaire/{id}/qrcode` | GET | Download questionnaire QR code |

## Questionnaire Builder

The core feature — build questionnaires with:

- **12+ question types**: text, number, select, radio, checkbox, date, time, file, section, calc, and more
- **Branching logic**: Conditional visibility (`visibleIf`) and jump rules (`jump`)
- **Flow visualization**: Visual flow editor with color-coded connectors (gray = sequential, red = jump, green = condition)
- **Calculated fields**: Auto-compute values (sum, avg, count, min, max) from other questions
- **Bulk option entry**: Paste `value|caption` lines to add options quickly

## Mobile Client (Flutter)

The `mobile/` directory contains a Flutter app for offline data collection:

1. Configure server URL and API key in the app settings
2. Download questionnaires from the server
3. Fill forms offline (saved to SQLite)
4. Sync responses when online

```bash
cd mobile/
flutter pub get
flutter run
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Author

**Zakaria Imtiaz** — [GitHub](https://github.com/zakariaimtiaz)
