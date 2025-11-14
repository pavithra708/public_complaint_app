# 📱 Running Your Flutter App on Mobile Device

Follow these steps to run your Public Complaint App on an Android or iOS device.

## Prerequisites

1. **Flutter SDK** installed (check with `flutter doctor`)
2. **Android Studio** (for Android) or **Xcode** (for iOS - Mac only)
3. **Physical device** or **Emulator/Simulator**
4. **Firebase Project** set up

---

## 🔧 Step 1: Setup Firebase for Mobile

### For Android:

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project**: `public-complaint-app`
3. **Add Android App**:
   - Click the Android icon or "Add app"
   - Package name: `com.example.public_comp` (found in `android/app/build.gradle.kts`)
   - App nickname: `Public Complaint App Android`
   - Click "Register app"

4. **Download `google-services.json`**:
   - Download the `google-services.json` file
   - **Place it here**: `public_complaint_app/android/app/google-services.json`

5. **Enable Required Services**:
   - Go to Firebase Console → Authentication → Enable Email/Password
   - Go to Firestore Database → Create database (if not done)
   - Go to Storage → Enable Storage

### For iOS (if using iPhone):

1. **Add iOS App in Firebase Console**:
   - Package name: `com.example.publicComp` (or your bundle ID)
   - Download `GoogleService-Info.plist`
   - **Place it here**: `public_complaint_app/ios/Runner/GoogleService-Info.plist`

---

## 📲 Step 2: Connect Your Device

### Android Device:
1. Enable **Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   
2. Enable **USB Debugging**:
   - Settings → Developer Options → USB Debugging (ON)

3. Connect phone via USB

4. Verify connection:
   ```bash
   flutter devices
   ```
   Your phone should appear in the list

### iOS Device (Mac only):
1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. In Xcode: Window → Devices and Simulators → Select your device
4. Verify:
   ```bash
   flutter devices
   ```

---

## 🚀 Step 3: Run the App

### Option A: Using Command Line

1. **Navigate to project directory**:
   ```bash
   cd public_complaint_app
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Check connected devices**:
   ```bash
   flutter devices
   ```

4. **Run on connected device**:
   ```bash
   flutter run
   ```
   
   Or specify device:
   ```bash
   flutter run -d <device-id>
   ```

### Option B: Using Android Studio / VS Code

**Android Studio:**
1. Open the project folder
2. Wait for indexing to complete
3. Select your device from the device dropdown (top bar)
4. Click the green "Run" button (▶️)

**VS Code:**
1. Open the project folder
2. Press `F5` or click "Run" → "Start Debugging"
3. Select your device when prompted

---

## 🐛 Troubleshooting

### Issue: "No devices found"
- **Android**: Make sure USB Debugging is enabled and computer is authorized
- **iOS**: Open Xcode and trust the device
- Try: `adb devices` (Android) to check ADB connection

### Issue: "google-services.json not found"
- Make sure you downloaded it from Firebase Console
- Verify path: `android/app/google-services.json`
- File should be in JSON format

### Issue: Build errors
- Clean and rebuild:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### Issue: Firebase connection errors
- Check Firebase configuration matches your project
- Verify `package name` matches in Firebase Console and `build.gradle.kts`
- Ensure Firebase services are enabled in Console

### Issue: Permission denied errors
- Check AndroidManifest.xml has required permissions
- On Android 13+ (API 33+), some permissions require runtime requests
- App should request permissions automatically when needed

---

## 📝 Important Notes

1. **First Run**: The app will request permissions for:
   - Camera (when taking photos)
   - Location (when filing complaints with location)
   - Storage (when accessing gallery)

2. **Internet Required**: The app needs internet to connect to Firebase

3. **Firebase Setup**: Make sure Authentication and Firestore are enabled in Firebase Console

4. **Package Name**: The package name `com.example.public_comp` must match in:
   - Firebase Console Android app settings
   - `android/app/build.gradle.kts` (applicationId)

---

## ✅ Success Checklist

- [ ] Firebase project created
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Device connected and recognized (`flutter devices`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully on device
- [ ] Can sign up/login
- [ ] Can file a complaint
- [ ] Can upload images
- [ ] Can get location

---

## 🎯 Testing Your App

1. **Test Authentication**:
   - Create a new account
   - Login/Logout

2. **Test Complaint Filing**:
   - File a complaint with title and description
   - Add a photo (camera/gallery)
   - Add location
   - Submit and verify it appears in dashboard

3. **Test Features**:
   - View complaint details
   - Check status updates
   - Test language switching
   - Test profile editing

---

Need help? Check:
- Flutter Docs: https://docs.flutter.dev
- Firebase Docs: https://firebase.google.com/docs/flutter/setup

