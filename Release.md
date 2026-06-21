# 🚀 Release Changelog - Policy Centrepoint

This document records the version history, feature updates, and platform changes for the **Policy Centrepoint** mobile application.

---

## 📱 [v1.0.0+1] — 2026-06-21
> **Initial Firebase Setup & Platform Re-branding**

### 🌟 Key Enhancements

#### 1. Firebase Core Integration
We have successfully connected the application to Firebase services.
- **Package Added:** `firebase_core: ^4.11.0`
- **Application Initialization:** Configured `main.dart` to initialize Flutter bindings and boot Firebase asynchronously using native platform options.

#### 2. Platform Re-branding (Package Rename)
To support production releases and correct identity registration, the application's unique package name / bundle identifier has been updated from `com.example.centrepoint` to **`com.parzello.centrepoint`** across all five target systems:

| Platform | Configuration File Modified | Changes Applied |
| :--- | :--- | :--- |
| **Android** | [`build.gradle.kts`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/android/app/build.gradle.kts) | Updated `namespace` & `applicationId` to `com.parzello.centrepoint`. Moved `MainActivity.kt` to the new package folder tree `com/parzello/centrepoint/`. |
| **iOS** | [`project.pbxproj`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/ios/Runner.xcodeproj/project.pbxproj) | Updated all instances of `PRODUCT_BUNDLE_IDENTIFIER` to `com.parzello.centrepoint`. |
| **macOS** | [`AppInfo.xcconfig`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/macos/Runner/Configs/AppInfo.xcconfig) | Updated `PRODUCT_BUNDLE_IDENTIFIER` and updated copyrights to `com.parzello`. |
| **Windows** | [`Runner.rc`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/windows/runner/Runner.rc) | Updated company identifier `CompanyName` and copyright statements. |
| **Linux** | [`CMakeLists.txt`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/linux/CMakeLists.txt) | Updated GTK `APPLICATION_ID` configuration variable. |

#### 3. Firebase Project Synchronized
- Automatically registered the new package name `com.parzello.centrepoint` inside the Firebase project `gen-lang-client-0115699822`.
- Synchronized client application metadata inside the `google-services.json` layout.
- Regenerated [`firebase_options.dart`](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/firebase_options.dart) with valid credentials for all five registered targets (Web, Android, iOS, macOS, Windows).
