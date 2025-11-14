# 📱 Public Complaint Management System

A comprehensive Flutter-based mobile application that enables citizens to file, track, and manage public complaints. The app features multi-language support, anonymous complaint filing, real-time status updates, and an admin dashboard for efficient complaint management.

## ✨ Features

### 👤 User Features
- **User Authentication**: Secure email/password login and registration
- **File Complaints**: Submit complaints with title, description, category, location, and photos
- **Track Complaints**: View all filed complaints with real-time status updates
- **Multi-language Support**: Available in 8 languages (English, Hindi, Spanish, French, Arabic, Kannada, Telugu, Tamil)
- **Anonymous Complaints**: File sensitive complaints without revealing identity
- **Location Services**: Automatic GPS location capture with address conversion
- **Image Upload**: Attach photos from camera or gallery
- **Complaint Categories**: Organize complaints by type (Road Issues, Water Supply, Electricity, etc.)

### 👨‍💼 Admin Features
- **Admin Dashboard**: View all complaints from all users
- **Filter & Search**: Filter complaints by category and status
- **Status Management**: Update complaint status (Pending, In Progress, Resolved, Rejected)
- **Department Assignment**: Categorize complaints for departmental handling
- **Real-time Updates**: See new complaints as they're filed

## 🛠️ Technologies Used

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Material Design** - UI components

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - Image storage
- **Geolocator** - GPS location services
- **Geocoding** - Address conversion
- **Image Picker** - Camera/gallery access
- **Shared Preferences** - Local storage

### Localization
- **Flutter Localizations** - Multi-language support
- **ARB Files** - Translation resources

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** / **Xcode** (for mobile development)
- **Firebase Account** (for backend services)
- **Git** (for version control)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd public_complaint_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Enable **Authentication** (Email/Password)
4. Create **Cloud Firestore** database
5. Create **Firebase Storage** bucket

#### Android Configuration
1. Register your Android app in Firebase Console
2. Download `google-services.json`
3. Place it in `android/app/` directory

#### iOS Configuration (if developing for iOS)
1. Register your iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory

### 4. Configure Firebase

Create `lib/services/firebase_config.dart`:

```dart
class FirebaseConfig {
  static Map<String, String> webConfig = {
    "apiKey": "YOUR_API_KEY",
    "authDomain": "YOUR_PROJECT_ID.firebaseapp.com",
    "projectId": "YOUR_PROJECT_ID",
    "storageBucket": "YOUR_PROJECT_ID.appspot.com",
    "messagingSenderId": "YOUR_SENDER_ID",
    "appId": "YOUR_APP_ID",
  };
}
```

### 5. Set Up Firestore Security Rules

Go to Firebase Console → Firestore Database → Rules and paste the rules from `FIRESTORE_RULES_UPDATED.txt`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /complaints/{complaintId} {
      allow read: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.token.email in ['admin@gmail.com'] ||
          resource.data.isAnonymous == true
        );

      allow create: if 
        (
          (request.auth != null && 
           request.auth.uid == request.resource.data.userId &&
           request.resource.data.isAnonymous != true) ||
          (request.auth == null &&
           request.resource.data.isAnonymous == true &&
           request.resource.data.userId == null &&
           request.resource.data.userEmail == null)
        );

      allow update, delete: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.token.email in ['admin@gmail.com']
        );
    }
  }
}
```

**Important:** Update `'admin@gmail.com'` with your actual admin email address.

### 6. Configure Admin Email

Edit `lib/services/auth_service.dart` and update the admin email list:

```dart
static const List<String> _adminEmails = [
  'admin@gmail.com', // Change to your admin email
];
```

### 7. Run the Application

```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>
```

## 📁 Project Structure

```
public_complaint_app/
├── lib/
│   ├── generated/          # Auto-generated localization files
│   ├── l10n/              # Translation files (.arb)
│   │   ├── app_en.arb     # English
│   │   ├── app_hi.arb     # Hindi
│   │   ├── app_es.arb     # Spanish
│   │   ├── app_fr.arb     # French
│   │   ├── app_ar.arb     # Arabic
│   │   ├── app_kn.arb     # Kannada
│   │   ├── app_te.arb     # Telugu
│   │   └── app_ta.arb     # Tamil
│   ├── models/            # Data models
│   │   └── complaint_model.dart
│   ├── screens/           # UI screens
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── file_complaint_screen.dart
│   │   ├── anonymous_complaint_screen.dart
│   │   ├── admin_login_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   └── ...
│   ├── services/          # Business logic
│   │   ├── auth_service.dart
│   │   ├── complaint_service.dart
│   │   ├── language_service.dart
│   │   ├── location_service.dart
│   │   └── image_service.dart
│   └── main.dart          # App entry point
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── pubspec.yaml          # Dependencies
└── README.md             # This file
```

## 🔐 Admin Access

To access the admin dashboard:
1. Create a user account with the email configured in `auth_service.dart`
2. Use the "Admin Login" button on the login screen
3. Login with the admin email and password

## 🌍 Supported Languages

- 🇬🇧 English
- 🇮🇳 Hindi (हिंदी)
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇸🇦 Arabic (العربية)
- 🇮🇳 Kannada (ಕನ್ನಡ)
- 🇮🇳 Telugu (తెలుగు)
- 🇮🇳 Tamil (தமிழ்)

Users can change language from Settings → Language

## 📱 Screenshots

### User Screens
- Login Screen with language options
- Dashboard showing user complaints
- File Complaint form with image and location
- Anonymous Complaint filing
- Complaint details view

### Admin Screens
- Admin Dashboard with all complaints
- Filter by category and status
- Status update interface
- Complaint statistics

## 🔧 Configuration

### Permissions Required

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `INTERNET` - Network access
- `CAMERA` - Camera access
- `READ_EXTERNAL_STORAGE` - Gallery access
- `WRITE_EXTERNAL_STORAGE` - Image saving
- `ACCESS_FINE_LOCATION` - GPS location
- `ACCESS_COARSE_LOCATION` - Network location

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription`
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

## 🐛 Troubleshooting

### Build Errors
- **Gradle errors**: Run `flutter clean` then `flutter pub get`
- **Firebase not initialized**: Ensure `google-services.json` is in correct location
- **Permission errors**: Check AndroidManifest.xml permissions

### Runtime Errors
- **Firestore permission denied**: Update security rules in Firebase Console
- **Image upload fails**: Check Firebase Storage rules
- **Location not working**: Grant location permissions in device settings

### Common Issues
- **Language not changing**: Run `flutter pub get` to regenerate localization files
- **Anonymous complaint fails**: Verify Firestore rules allow unauthenticated creation
- **Admin login fails**: Check admin email in `auth_service.dart`

## 📝 Key Features Explained

### Complaint ID
Firebase Firestore automatically generates unique document IDs for each complaint when created.

### Real-time Updates
Uses Firestore's `.snapshots()` stream to listen for real-time changes. When admin updates status, users see changes immediately.

### Anonymous Complaints
Allows users to file complaints without authentication. Data is marked with `isAnonymous: true` and no user identification is stored.

### Image Storage
Images are uploaded to Firebase Storage, and the download URL is stored in Firestore. This keeps the database lightweight.

### Location Services
Uses GPS to get coordinates, then reverse geocoding to convert to readable address. Both are stored for precise location tracking.

## 🚧 Future Enhancements

- [ ] Push notifications for status updates
- [ ] Offline mode with local caching
- [ ] Multiple images per complaint
- [ ] Comment/chat system for follow-up
- [ ] Analytics dashboard
- [ ] Complaint history and trends
- [ ] SMS/Email notifications
- [ ] Department-specific categories
- [ ] Complaint export functionality
- [ ] Rating system for resolved complaints

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Developed as a Flutter project for public complaint management.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All package maintainers
- Open source community

## 📞 Support

For issues, questions, or contributions, please open an issue on the repository.

---

**Note:** Make sure to configure Firebase properly and update admin email before running the application. The app requires an active internet connection for all features.
