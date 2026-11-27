# 🎟️ Punchd'in

**Punch in your attendance in a streak!**

**Punchd'in** is a tactile, retro punch-card and loyalty stamp-card inspired attendance tracking mobile application built with **Flutter**, **Dart**, and **Firebase**. Reimagined from a traditional dark-mode attendance logger, Punchd'in brings the nostalgic warmth of vintage factory timecards and physical stationery into a crisp, modern Bento-grid mobile experience.

---

## ✨ Features

* **🔐 Admin-Managed Authentication:** Secure, login-only access powered by **Firebase Authentication** (Email & Password) with public self-registration disabled for institutional or team control.
* **⏱️ Live Digital & Analog Timecard:** Real-time ticking digital clock (`HH:mm:ss` with tabular figures) paired with an analog clock face and current date stamp.
* **📸 Photo Check-In Verification:** Capture and submit a check-in photo directly from the app to timestamp your daily attendance.
* **🔥 Weekly Streak Loyalty Card:** Track Monday–Friday consistency (`M T W T F`) with interactive punch-hole stamps and celebratory streak milestones.
* **🛡️ Excuse Absence & Streak Protection:** Submit an excused absence (e.g., *Sick*, *Family/Personal*, *Official Duty*) directly from the Home screen to log the status without breaking your weekly streak.
* **📊 Color-Coded Attendance Stats & History:** At-a-glance counters and ticket-styled history logs categorized by **On Time**, **Late**, **Absent**, and **Excused**.
* **🌓 Light & Dark Mode Support:** Seamless theme switching between the signature **Warm Paper Cardstock** light theme and a tailored dark mode.

---

## 🎨 Design System & Color Palette

Punchd'in uses a **Classic Retro Punch-Card** aesthetic built with soft card elevation, subtle borders, and editorial typography (`Fraunces` / `Instrument Serif`, `Plus Jakarta Sans`, and `JetBrains Mono`).

| Role | Color Name | Hex |
| :--- | :--- | :--- |
| **Primary Brand** | Cobalt Cardstock Blue | `#4D6FB7` |
| **Brand Hover / Pressed** | Deep Cobalt | `#3B5898` |
| **Brand Soft Tint** | Cardstock Tint | `#DCE4F5` |
| **Secondary Accent** | Punch-Card Saffron Yellow | `#F4C430` |
| **Tertiary Accent** | Stamp Coral Red | `#FF6B4A` |
| **Canvas Background** | Warm Paper Cream | `#F6F5F0` |
| **Card Surface** | Crisp White | `#FFFFFF` |
| **Status: On Time** | Retro Teal | `#2EC4B6` |
| **Status: Late** | Saffron Yellow | `#F4C430` |
| **Status: Absent** | Stamp Crimson | `#E63946` |
| **Status: Excused** | Soft Periwinkle | `#A8B9DF` |

---

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **Typography:** `google_fonts` (`Fraunces`, `Plus Jakarta Sans`, `JetBrains Mono`)
* **Authentication:** Firebase Authentication
* **Database:** Cloud Firestore
* **Media / Camera:** Flutter Camera / Image Picker

---

## 📁 Project Structure

```text
lib/
├── core/                  # Theme configuration, color tokens, custom painters (OrbitClock)
├── features/
│   ├── auth/              # Login screen & Firebase Auth integration
│   ├── attendance/        # Home dashboard, live clock, streak card, photo check-in, history & excuse modal
│   └── profile/           # User profile card, avatar management, privacy notice & sign-out
├── app.dart               # Root MaterialApp & ThemeProvider setup
└── main.dart              # Firebase initialization & app entry point
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
* Dart SDK
* A configured [Firebase Project](https://console.firebase.google.com/) with **Email/Password Authentication** and **Cloud Firestore** enabled.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/punchdin.git
   cd punchdin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   * Place your own `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) in their respective platform directories, or generate `lib/firebase_options.dart` via the FlutterFire CLI:
     ```bash
     flutterfire configure
     ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🔥 Firebase Setup Notes

Because user self-registration is intentionally disabled in Punchd'in:
1. Create user accounts manually inside **Firebase Console → Authentication → Users**.
2. Ensure **Cloud Firestore** security rules allow authenticated users (`request.auth != null`) to read and write their own profile and attendance logs.
3. Supported attendance status values: `on_time`, `late`, `absent`, and `excused`.

---

## 📄 Credits

* **App Concept & Design:** Made by Karin
* **Refactored from:** Klock Attendance App