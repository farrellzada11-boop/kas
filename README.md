# KAS - Kereta Api System

Aplikasi manajemen kereta api dengan Flutter frontend dan CodeIgniter 4 REST API backend.

## Features

### User
- 🔐 Login/Register
- 🔍 Cari jadwal kereta
- 🎫 Booking tiket
- 📋 Lihat tiket saya

### Admin
- 📊 Dashboard statistik
- 🚂 Kelola kereta
- 📅 Kelola jadwal
- 📝 Kelola booking

## Tech Stack

- **Frontend**: Flutter 3.35+
- **Backend**: CodeIgniter 4
- **Database**: MySQL/MariaDB

## Setup

### Backend (CI4)

```bash
cd backend

# Install dependencies
composer install

# Copy env file
cp env .env

# Configure database in .env
# database.default.hostname = localhost
# database.default.database = kas_db
# database.default.username = root
# database.default.password = 

# Run migrations
php spark migrate

# Seed demo data
php spark db:seed DatabaseSeeder

# Start server
php spark serve
```

### Frontend (Flutter)

```bash
# Get dependencies
flutter pub get

# Run app
flutter run
```

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| User | user@mail.com | password |
| Admin | admin@mail.com | password |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Login |
| POST | /api/auth/register | Register |
| GET | /api/stations | List stations |
| GET | /api/trains | List trains |
| GET | /api/schedules | List schedules |
| GET | /api/schedules/search | Search schedules |
| GET | /api/bookings | User bookings |
| POST | /api/bookings | Create booking |

## Configuration

Edit `lib/config/app_constants.dart`:

```dart
// Use mock data (no backend needed)
static const bool useMockData = true;

// Use CI4 backend
static const bool useMockData = false;
```

## License

MIT
