# AgroVision

[![CI](https://github.com/sahannavo/AgroVision/actions/workflows/ci.yml/badge.svg)](https://github.com/sahannavo/AgroVision/actions/workflows/ci.yml)

AgroVision (SE205.3) is an offline-first mobile application designed to empower nightshade crop (tomato, brinjal, chilli) farmers in Sri Lanka with automated pest and disease diagnosis, localized weather-informed irrigation planning, and community outbreak alert systems.

---

## Key Features

- **On-Device Plant Disease Diagnosis**: Lightweight TensorFlow Lite deep learning model running directly on-device without requiring internet connectivity.
- **Offline-First Smart Irrigation Planner**: Calculates daily water requirements based on crop variety, growth stage, soil type, and cached local weather forecasts.
- **Disease Outbreak & Early-Warning Alerts**: Cloud Functions trigger spatial outbreak alerts when clusters of infections are reported, notifying nearby farmers via Firebase Cloud Messaging (FCM).
- **Comprehensive Farm Management**: Track crop plot cycles, treatment history, and localized agronomic guidelines.

---

## Tech Stack & Architecture

- **Mobile Client**: Flutter (Dart) with Riverpod state management and feature-first architecture.
- **Backend Services**: Firebase Auth, Cloud Firestore (with offline caching enabled), Firebase Storage, Firebase Cloud Messaging.
- **Serverless Automation**: Firebase Cloud Functions (Node 20, TypeScript).
- **Machine Learning**: TensorFlow Lite, MobileNet transfer learning, on-device inference with parity testing.
- **CI / CD**: GitHub Actions automated linting and test suite execution.

---

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.24.0)
- Node.js (>= 20) for Firebase Functions
- Firebase CLI (`npm install -g firebase-tools`)

### Running the App Locally with Fakes (Default)
By default, the application runs using local in-memory fake repositories, allowing full UI exploration without connecting to live Firebase emulators:
```bash
cd app
flutter pub get
flutter run
```

### Running with Real Firebase Backend / Emulators
To run against the Firebase Emulator Suite:
```bash
# In the repository root
firebase emulators:start

# In the app directory
flutter run --dart-define=USE_FAKES=false
```

---

## Development & Contribution

Please review [CONTRIBUTING.md](CONTRIBUTING.md) for branch management rules, daily sync workflows, and commit conventions before submitting pull requests.
