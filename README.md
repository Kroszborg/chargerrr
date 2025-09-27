# Chargerrr - EV Charging Station Finder App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white" alt="Firebase">
  <img src="https://img.shields.io/badge/Google%20Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" alt="Google Maps">
</div>

## 📱 Overview

Chargerrr is a comprehensive Flutter application for finding and managing EV charging stations. Built with clean architecture, GetX state management, and Firebase backend, it provides users with real-time information about charging stations, availability, pricing, and navigation.

## ✨ Features

### 🔐 Authentication
- Email/Password authentication with Firebase Auth
- User registration and profile management
- Password reset functionality
- Email verification

### 🗺️ Station Discovery
- Real-time charging station data from Firestore
- Location-based station search
- Advanced filtering by connector type, price, rating
- Favorites management
- Search functionality

### 📍 Maps Integration
- Google Maps with custom markers
- Real-time location tracking
- Turn-by-turn navigation to stations
- Station availability visualization

### 💡 User Experience
- Modern Material Design 3 UI
- Dark/Light theme support
- Offline capabilities
- Push notifications
- Smooth animations and transitions

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App colors, strings, API constants
│   ├── errors/            # Exception and failure handling
│   ├── network/           # Network connectivity
│   └── utils/             # Utility functions and validators
├── data/                   # Data layer
│   ├── datasources/       # Remote data sources (Firebase)
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/                # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/        # Business logic use cases
├── presentation/          # Presentation layer
│   ├── controllers/      # GetX controllers
│   ├── pages/           # UI screens
│   ├── widgets/         # Reusable widgets
│   └── bindings/        # Dependency injection
└── routes/               # Navigation routing
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (≥ 3.6.0)
- Dart SDK
- Android Studio / VS Code
- Firebase CLI
- Google Cloud Console account

### 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/chargerrr.git
   cd chargerrr
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

   b. Enable Authentication with Email/Password

   c. Create Firestore database with the following collections:

   **Users Collection (`users`)**
   ```json
   {
     "id": "user_id",
     "email": "user@example.com",
     "fullName": "John Doe",
     "phoneNumber": "+1234567890",
     "profileImageUrl": "https://...",
     "isEmailVerified": true,
     "isActive": true,
     "favoriteStations": ["station1", "station2"],
     "createdAt": "timestamp",
     "updatedAt": "timestamp"
   }
   ```

   **Charging Stations Collection (`charging_stations`)**
   ```json
   {
     "id": "station-1",
     "name": "Tata Power EZ Charge",
     "address": "Connaught Place, New Delhi, Delhi 110001",
     "latitude": 28.6324,
     "longitude": 77.2187,
     "available_points": 3,
     "total_points": 5,
     "amenities": ["wifi", "restroom", "cafe"],
     "price_per_unit": 8.5,
     "connector_types": ["Type 2", "CCS", "CHAdeMO"],
     "rating": 4.2,
     "reviews_count": 156,
     "is_operational": true,
     "description": "Fast charging station in the heart of Delhi",
     "image_url": "https://...",
     "operator_name": "Tata Power",
     "operator_phone": "+91-1234567890",
     "operating_hours": {
       "monday": "6:00 AM - 10:00 PM",
       "tuesday": "6:00 AM - 10:00 PM",
       "wednesday": "6:00 AM - 10:00 PM",
       "thursday": "6:00 AM - 10:00 PM",
       "friday": "6:00 AM - 10:00 PM",
       "saturday": "6:00 AM - 10:00 PM",
       "sunday": "6:00 AM - 10:00 PM"
     },
     "created_at": "timestamp",
     "updated_at": "timestamp"
   }
   ```

   d. Install Firebase CLI and configure
   ```bash
   npm install -g firebase-tools
   firebase login
   flutterfire configure
   ```

   e. This will generate `lib/firebase_options.dart` - keep this file secure

4. **Google Maps Setup**

   a. Enable Maps SDK for Android and iOS in Google Cloud Console

   b. Create API key and restrict it to your app

   c. Add API key to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

   d. Add API key to `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_IOS_API_KEY=your-ios-api-key

# Google Maps API
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# App Configuration
APP_VERSION=1.0.0
MIN_SUPPORTED_VERSION=1.0.0
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Anyone can read charging stations (public data)
    match /charging_stations/{stationId} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can update
    }

    // Station reports require authentication
    match /station_reports/{reportId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Structure

```
test/
├── unit/
│   ├── controllers/
│   ├── usecases/
│   └── repositories/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── app_test.dart
```

## 📱 Screenshots

| Splash Screen | Login | Home | Station Details |
|---------------|-------|------|----------------|
| ![Splash](screenshots/splash.png) | ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Details](screenshots/details.png) |

## 🚀 Deployment

### Android

1. **Generate keystore**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/app/build.gradle`

3. **Build APK/AAB**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

### iOS

1. **Configure Xcode project**
   - Set team and bundle identifier
   - Configure signing certificates

2. **Build IPA**
   ```bash
   flutter build ios --release
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📋 Project Status

- [x] Clean Architecture Setup
- [x] Authentication System
- [x] Station Discovery & Search
- [x] Maps Integration
- [x] User Profile Management
- [ ] Payment Integration
- [ ] Push Notifications
- [ ] Offline Support
- [ ] Advanced Analytics

## 🐛 Known Issues

- Google Maps may not load without valid API key
- Location permissions required for nearby stations
- Some older Android devices may experience performance issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps for location services
- Material Design for UI guidelines

## 📞 Support

For support and questions:
- Create an issue in this repository
- Email: support@chargerrr.com
- Documentation: [Wiki](https://github.com/yourusername/chargerrr/wiki)

---

<div align="center">
  <p>Built with ❤️ using Flutter</p>
  <p>🚀 Generated with Claude Code</p>
</div>