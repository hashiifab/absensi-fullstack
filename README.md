# 🚀 Presence System - Laravel & Flutter Stack

## 🛠 Tech Stack

**Backend**:
- Laravel 10 (PHP Framework)
- MySQL/SQLite Database
- Sanctum (API Authentication)

**Frontend**:
- Flutter 3.13 (Mobile Framework)
- Dart 3.1
- Riverpod (State Management)

## 🌟 Key Features

- 📱 Mobile-first Presence Tracking System
- 🔑 JWT Authentication Flow
- 📅 Daily Attendance Recording
- 📊 Real-time Attendance Reports
- 📱 Cross-platform Mobile App
- 🔄 Bi-directional Sync Capability

## 📂 Folder Structure

```
presensi-fullstack/
├── backend/           # Laravel API
│   ├── app/
│   │   ├── Http/     # API Controllers
│   │   └── Models/   # Database Models
│   ├── config/       # Configuration Files
│   ├── database/     # Migrations & Seeders
│   └── routes/       # API Endpoints
└── frontend/         # Flutter Mobile
    ├── lib/
    │   ├── models/   # Data Models
    │   ├── utils/    # Helpers & Services
    │   └── views/    # UI Screens
    ├── android/      # Android Specific
    └── ios/         # iOS Specific
```

## 🖥 Local Setup

## 📚 API Documentation

[![Run in Postman](https://run.pstmn.io/button.svg)](https://god.gw.postman.com/run-collection/your-collection-id-here)

Access our ready-to-use Postman collection containing all API endpoints:
- **Collection Link**: [Presensi API Collection](https://drive.google.com/file/d/1lOIBfz-xo-2ksL6a2_PqI9oodsyasUs2/view?usp=sharing)


## 🛠 How to Use

### API Testing
1. Import Postman collection from the link above
2. Set environment variables:
   - `base_url`: http://localhost:8000
   - `token`: [Obtain from login response]
3. Start testing endpoints:
   - Authentication (Login/Register)
   - Attendance Records
   - User Management

### Mobile App Development


**Backend**:
```bash
cd backend
composer install
cp .env.example .env
php artisan serve
```

**Frontend**:
```bash
cd frontend
flutter pub get
flutter run
```

### Backend Configuration
## 🔑 Environment Variables

Create `.env` in backend:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=presensi
DB_USERNAME=root
DB_PASSWORD=

APP_KEY=
SANCTUM_STATEFUL_DOMAINS=localhost:8080
```

## 👨💻 Author
- GitHub: [@hashiifabdillah](https://github.com/hashiifab)
- LinkedIn: [Hashiif Abdillah](https://www.linkedin.com/in/hashiif-abdillah-665373297/)