# 🐾 PawPoint
**A Comprehensive Pet Healthcare Management System**

PawPoint is a cross-platform mobile application designed to bridge the gap between pet owners, veterinary clinics, and doctors. The system features a Flutter frontend and a FastAPI backend, both integrated with Firebase for authentication and cloud data storage.

---

## 🏗️ Project Structure

```
Pawpoint/
├── frontend/          # Flutter mobile application
│   ├── lib/
│   │   ├── auth/              # Authentication utilities
│   │   ├── domain/            # Business logic
│   │   ├── models/            # Data models (e.g., PetModel)
│   │   ├── presentation/     # All UI pages & widgets
│   │   │   ├── widgets/       # Reusable components (SharedBottomNavBar)
│   │   │   ├── dashboard_page.dart
│   │   │   ├── my_pets_page.dart
│   │   │   ├── book_now_page.dart
│   │   │   ├── appointments_page.dart
│   │   │   ├── profile_page.dart
│   │   │   └── ...
│   │   ├── firebase_options.dart
│   │   └── main.dart          # App entry point
│   ├── assets/images/         # Image assets
│   └── pubspec.yaml
│
└── backend/           # FastAPI server
    ├── main.py
    └── requirements.txt
```

---

## ✨ Features

### 👤 User (Customer) UI
- **Pet Management:** Add, edit, and track profiles for multiple pets.
- **Service Discovery:** Browse clinic services and transparent pricing.
- **Easy Booking:** Schedule appointments with specific doctors.
- **Appointment Tracking:** Real-time status of current and past bookings.
- **Profile Customization:** Manage personal contact details.

### 🔐 Admin Dashboard
- **Service Management:** Create, update, or disable clinic services.
- **Staff Onboarding:** Register and manage Doctor accounts.
- **Business Intelligence:** Visualized sales data and monthly appointment density via graphs.

### 🩺 Doctor Portal
- **Smart Scheduling:** View daily/weekly agendas.
- **Appointment Control:** Accept or decline bookings based on real-time availability.
- **History Logs:** Access record of all past consultations.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | FastAPI (Python), Uvicorn |
| **Database** | Cloud Firestore |
| **Authentication** | Firebase Auth |
| **Fonts** | Google Fonts (Poppins) |
| **Version Control** | Git |
| **Project Management** | Jira (Scrum/Kanban) |

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed on your machine:

| Tool | Version | Download |
|------|---------|----------|
| **Flutter SDK** | 3.10.7+ | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | Bundled with Flutter | — |
| **Android Studio** or **VS Code** | Latest | [developer.android.com/studio](https://developer.android.com/studio) |
| **Python** | 3.10+ | [python.org/downloads](https://python.org/downloads) |
| **Git** | Latest | [git-scm.com](https://git-scm.com) |
| **Firebase CLI** | Latest | [firebase.google.com/docs/cli](https://firebase.google.com/docs/cli) |
| **FlutterFire CLI** | Latest | `dart pub global activate flutterfire_cli` |

You will also need:
- A physical Android/iOS device or emulator
- A Firebase project (see [Firebase Setup](#-firebase-setup) below)

---

### 1. Clone the Repositories

Both repos are hosted under the [PawPoint](https://github.com/PawPoint) GitHub organization:

```bash
# Clone the frontend
git clone https://github.com/PawPoint/PawPoint_frontend.git

# Clone the backend
git clone https://github.com/PawPoint/PawPoint_backend.git
```

---

### 2. Backend Setup

```bash
cd PawPoint_backend
python -m venv venv

# Activate the virtual environment:
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --reload
```

The backend server will start at `http://127.0.0.1:8000`.

---

### 3. Firebase Setup

Since `firebase_options.dart` contains project-specific credentials, you need to connect your own Firebase project:

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com).

2. **Enable the following Firebase services:**
   - **Authentication** → Enable **Email/Password** sign-in method.
   - **Cloud Firestore** → Create a database (start in **test mode** for development).

3. **Install and configure FlutterFire CLI:**
   ```bash
   # Install FlutterFire CLI (if not already installed)
   dart pub global activate flutterfire_cli

   # Navigate to the frontend directory
   cd PawPoint_frontend

   # Configure Firebase for your project
   flutterfire configure
   ```
   This will auto-generate a new `firebase_options.dart` file with your project's credentials.

4. **For Android:** Make sure the `google-services.json` file is placed in `PawPoint_frontend/android/app/`.

5. **For iOS:** Make sure the `GoogleService-Info.plist` is placed in `PawPoint_frontend/ios/Runner/`.

---

### 4. Frontend Setup

```bash
cd PawPoint_frontend

# Install Flutter dependencies
flutter pub get

# Verify your environment is ready
flutter doctor
```

---

### 5. Run the App

```bash
# Make sure an emulator is running or a device is connected
flutter devices

# Run the app
flutter run
```

> **Tip:** To run on a specific device, use:
> ```bash
> flutter run -d <device-id>
> ```

---

## 📁 Firestore Database Structure

The app expects the following Firestore collections:

```
pawpoint-db/
├── users/                  # User profiles
│   └── {userId}
│       ├── name
│       ├── email
│       └── ...
├── pets/                   # Pet records
│   └── {petId}
│       ├── petName
│       ├── petType
│       ├── ownerId
│       └── ...
└── appointments/           # Booking records
    └── {appointmentId}
        ├── userId
        ├── doctorName
        ├── service
        ├── date
        ├── status
        └── ...
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter pub get` fails | Run `flutter clean` then `flutter pub get` again |
| Firebase connection error | Re-run `flutterfire configure` and ensure your Firebase project is active |
| Emulator not detected | Run `flutter doctor` and follow the setup instructions |
| Gradle build fails (Android) | Ensure your `minSdkVersion` is at least **21** in `android/app/build.gradle` |
| `google-services.json` missing | Download it from Firebase Console → Project Settings → Android app |

---

## 📄 License

This project is for academic/educational purposes.

---

## 👥 Contributors

- **Rane** — Developer
- **Sean** — Developer