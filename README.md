# Chargerrr - EV Charging Station Finder

**Flutter Internship Assessment Project**

A Flutter application that helps users find and view EV charging stations with user authentication and Google Maps integration.

## 📱 Features

- **User Authentication**: Sign up, login, logout with Firebase Auth
- **Station Discovery**: Browse list of EV charging stations
- **Station Details**: View detailed station info with Google Maps
- **Clean Architecture**: Proper separation of data, domain, and presentation layers
- **State Management**: GetX for reactive state management

## 🏗️ Architecture

This project follows Clean Architecture principles:

```
lib/
├── core/           # Utilities, constants, errors
├── data/           # Data sources, models, repositories
├── domain/         # Entities, repository interfaces, use cases
├── presentation/   # UI screens, controllers, widgets
└── routes/         # Navigation
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.0+)
- Firebase account
- Google Cloud account for Maps API

### Setup Instructions

1. **Clone and install dependencies**:
   ```bash
   git clone <your-repo-url>
   cd chargerrr
   flutter pub get
   ```

2. **Firebase Setup**: Follow the detailed guide in [SETUP_GUIDE.md](SETUP_GUIDE.md)

3. **Google Maps Setup**: Add your API key (instructions in setup guide)

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📊 Sample Data

The app uses Firebase Firestore with sample charging station data:
- Tata Power EZ Charge (New Delhi)
- Statiq EV Charging (Bengaluru)
- Ather Grid (Bengaluru)

## 🧪 Testing

```bash
# Run tests
flutter test

# Check app analysis
flutter analyze
```

## 📱 Screenshots

| Login Screen | Station List | Station Details |
|--------------|--------------|-----------------|
| Auth with Firebase | List of stations | Map integration |

## 🛠️ Built With

- **Flutter** - UI framework
- **GetX** - State management
- **Firebase** - Backend (Auth + Firestore)
- **Google Maps** - Location services
- **Clean Architecture** - Project structure

## 📋 Development Checklist

- [x] Project setup with Flutter
- [x] Clean architecture implementation
- [x] Firebase authentication
- [x] Firestore database integration
- [x] Station list display
- [x] Station details with maps
- [x] GetX state management
- [x] Error handling
- [x] UI/UX implementation

## 🤝 Assessment Requirements Met

- ✅ Flutter with GetX state management
- ✅ Clean Architecture (data/domain/presentation)
- ✅ Firebase Authentication
- ✅ Firestore database for stations
- ✅ Google Maps integration
- ✅ User-friendly UI
- ✅ Git version control with clear commits

## 📄 Assignment Details

This project fulfills the Flutter Internship Technical Assessment requirements:
- **Backend**: Firebase (recommended option)
- **Authentication**: Email/password with Firebase Auth
- **Data**: Charging stations stored in Firestore
- **Maps**: Google Maps for location features
- **Architecture**: Clean Architecture principles
- **State Management**: GetX package

---

**Built for Flutter Internship Assessment**