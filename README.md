# 🧾 Receipt Scanner +

> AI-powered receipt scanning and budget tracking app — Web PWA + Flutter mobile app

**🔗 Live Demo:** [https://receipt-scanner-plus.web.app](https://receipt-scanner-plus.web.app)

---

## ✨ Features

- 📸 **AI Receipt Scanning** — Powered by Google Gemini 2.5 Flash
- 💰 **Budget Tracking** — Set monthly budgets, track spending in real-time
- 📊 **Insights & Analytics** — Category breakdowns, top merchants, spending trends
- 📋 **History** — View all scanned receipts grouped by date
- 🌐 **Web PWA** — Installable on any device from the browser
- 📱 **Flutter App** — Native mobile experience for Android & iOS
- 🔥 **Firebase Backend** — Auth, Firestore, Storage

---

## 🚀 Getting Started

### Web App

Just open `index.html` in a browser, or visit the [live demo](https://receipt-scanner-plus.web.app).

You'll need a **Google Gemini API key** — enter it in the app's Profile tab. Get one free at [aistudio.google.com](https://aistudio.google.com).

---

### Flutter App

#### Prerequisites

- Flutter SDK (latest stable)
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

#### Setup

```bash
cd flutter_app
flutter pub get
```

#### Configure Firebase (Required)

This repo does **not** include `firebase_options.dart` or `google-services.json` for security reasons.

You need to connect your own Firebase project:

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication**, **Firestore**, and **Storage**
3. Run:

```bash
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` and downloads `google-services.json` for Android.

#### Run the app

```bash
flutter run
```

---

## 🗂 Project Structure

```
receipt-budget-app-updated/
├── index.html          # Web PWA entry point
├── app.js              # Web app logic
├── style.css           # Web app styles
├── manifest.json       # PWA manifest
├── sw.js               # Service worker
├── proxy.js            # API proxy helper
├── icon.png            # App icon
└── flutter_app/        # Flutter mobile app
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── screens/
    │   ├── services/   # Gemini, Firebase, Auth, DB
    │   ├── providers/
    │   └── theme/
    ├── assets/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

---

## 🔐 Environment & Secrets

| File | Status | Notes |
|---|---|---|
| `firebase_options.dart` | ❌ Not in repo | Run `flutterfire configure` |
| `google-services.json` | ❌ Not in repo | Downloaded via FlutterFire CLI |
| Gemini API Key | ✅ User-provided | Entered in app at runtime |

---

## 🛠 Tech Stack

- **Web:** Vanilla HTML/CSS/JS, Google Gemini API, Service Worker (PWA)
- **Mobile:** Flutter/Dart
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI:** Google Gemini 2.5 Flash

---

## 📄 License

MIT License — feel free to use and modify.
