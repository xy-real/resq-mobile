# 🚀 TASKS — Main Page (Home / Status Screen)

## Project: VSU Disaster Status Mobile App (Flutter)

This document defines the development tasks for the **Main Page (Home / Status Screen)** of the mobile application.

Scope: UI + Local State Logic only.
Out of scope: Backend integration, admin panel, SMS gateway server, background services.

---

# 🎯 OBJECTIVE

Build a stress-optimized emergency Home Screen that allows students to:

- View current status
- Submit new status
- See disaster mode indicator
- See connectivity indicator
- See last update time
- See location sharing state
- View SMS fallback instructions when offline

This is the most important screen in the application.

---

# 🧱 TECH REQUIREMENTS

Use:

- Flutter (latest stable)
- Provider or Riverpod (state management)
- SharedPreferences (persistence)
- connectivity_plus (internet status)
- intl (timestamp formatting)
- url_launcher (SMS deep linking)
- permission_handler (location permission stub only)

---

# 📂 FILE STRUCTURE

Create:

```
lib/
 ├── screens/
 │    └── home_screen.dart
 ├── widgets/
 │    ├── status_button.dart
 │    ├── disaster_mode_banner.dart
 │    ├── connectivity_banner.dart
 │    ├── status_header.dart
 │    └── sms_fallback_card.dart
 ├── providers/
 │    └── app_state_provider.dart
 ├── utils/
 │    └── time_formatter.dart
```

---

# 📱 MAIN PAGE COMPONENTS

## 1️⃣ Disaster Mode Banner

- Full width banner
- High contrast (red)
- Text: "DISASTER MODE ACTIVE"
- Only visible if disasterMode == true

---

## 2️⃣ Status Header

Display:

- Student ID
- Current Status
- Last Updated ("5 mins ago")
- Connectivity Indicator (green = online, red = offline)

Handle case where no status has been submitted.

---

## 3️⃣ Status Buttons (Primary Section)

Create large buttons:

- SAFE (Green)
- NEEDS ASSISTANCE (Orange)
- CRITICAL (Red)
- EVACUATED (Blue)

Requirements:

- Only one active at a time
- Highlight active button
- CRITICAL requires confirmation dialog
- Debounce rapid taps (2 seconds)
- Large tap areas
- Optional light haptic feedback

This section must occupy most of the screen.

---

## 4️⃣ Location Section

Display:

- Location Sharing: ON / OFF
- Last Location Update: X minutes ago

If permission denied:

- Show warning banner
- Still allow status submission

Do NOT include map widget.

---

## 5️⃣ Offline SMS Fallback Card

If no internet connection:

Display card containing:

Offline Mode Active  
Send SMS using format:

VSU <StudentID> <STATUS>

Example:

VSU 202312345 CRITICAL

Include:

- Copy to clipboard button
- Button to open SMS app using:
  sms:?body=VSU 202312345 CRITICAL

This card must only appear when offline.

---

# 🧠 STATE MODEL

Create AppState model:

```dart
class AppState {
  String studentId;
  String? currentStatus;
  DateTime? lastUpdated;
  bool disasterMode;
  bool isConnected;
  bool locationEnabled;
  DateTime? lastLocationUpdate;
}
```

Persist locally:

- studentId
- currentStatus
- lastUpdated

---

# ⚠ EDGE CASES

- App opened offline → show last saved status
- Rapid button tapping → debounce
- CRITICAL accidental tap → confirmation dialog
- No status yet → show "No status submitted"
- Location permission denied → show warning
- Proper timestamp formatting
- Avoid unnecessary scrolling

---

# 📌 FUNCTIONS TO IMPLEMENT

- void updateStatus(String status)
- Future<void> confirmCritical()
- String formatTimeAgo(DateTime timestamp)
- String generateSmsFormat(String studentId, String status)

---

# 🧪 DEV SUPPORT

Inside HomeScreen:

```dart
bool devDisasterMode = true;
```

Allow manual toggling for testing banner visibility.

---

# 🚫 DO NOT IMPLEMENT

- Backend API calls
- Background GPS tracking
- Queue system
- Navigation routing
- Admin logic

---

# 🔥 DESIGN PRINCIPLES

- Large fonts
- High contrast
- Clear spacing
- Minimal clutter
- No heavy animations
- Fast interaction
- Designed for panic scenarios

---

# ✅ OUTPUT EXPECTATION

- Fully working Home Screen UI
- Modular widgets
- Clean provider structure
- Local persistence
- Production-ready Flutter code

This branch is UI-focused only.

