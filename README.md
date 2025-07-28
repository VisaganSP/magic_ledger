
# 📒 Magic Ledger

**A beautiful and smart expense + todo tracker app built with Flutter**  
**Author:** Visagan S • 📧 visagansvvg@gmail.com  
**Company:** visainnovations

---

## 🚀 Overview

**Magic Ledger** is a modern finance tracker with a twist. Built using Flutter, it fuses **expense management**, **todo tracking**, and **powerful analytics** under a bold **neo-brutalist** design. Featuring animated UI elements, smart notifications, and local-first storage via Hive, this app makes personal finance **visual, intelligent, and fun**.

---

## 🧠 App Highlights

- ✅ **Offline-First**: Works entirely with local storage (Hive)
- 🎨 **Neo-Brutalist UI**: Bold design with custom shadows, animations, and components
- 📊 **Advanced Analytics**: Interactive charts, breakdowns, and PDF reports
- 🔔 **Smart Features**: Budget alerts, reminders, recurring expenses, predictions
- 💾 **Persistent & Performant**: Hive-powered local database, blazing fast
- 📱 **Modern Flutter Stack**: MVC architecture with GetX for clean, reactive code

---

## 📁 Project Structure

```bash
lib/
├── main.dart
├── app/
│   ├── bindings/            # Initial dependency injection setup
│   ├── data/
│   │   ├── models/          # Expense, Category, Todo, Budget, Receipt models
│   │   ├── providers/       # Hive database provider
│   │   └── services/        # PDF, Notifications, Images
│   ├── modules/             # App modules (Home, Expenses, Todos, Analytics, etc.)
│   ├── routes/              # App routes and navigation
│   ├── theme/               # App-wide theming and neo-brutalist styling
│   └── widgets/             # Reusable components (NeoButtons, Charts, etc.)
````

---

## ✨ Features

### 🎨 Neo-Brutalism Design

* Bold borders, offset shadows
* Vibrant color palette (Yellow, Pink, Green, Blue, etc.)
* Custom animations and press effects

### 💰 Expense Management

* Add expenses with receipts, tags, locations
* Support for daily/weekly/monthly recurring expenses
* Smart categorization and color-coded entries

### ✅ Todo System

* Add todos with priorities and reminders
* Link todos to specific expenses
* Notifications for due dates and priorities

### 📈 Advanced Analytics

* Interactive pie + line charts for trends and breakdowns
* Top spender categories
* Custom date range selection
* Generate PDF reports with visual charts

### 🔔 Smart Notifications

* Budget alerts when spending exceeds thresholds
* Smart reminders for recurring expenses and tasks

### 🗂️ Organizational Tools

* Custom categories (unlimited icons and colors)
* Tag system for advanced filtering
* Receipt storage and location tracking

### 🎮 Gamification Touches

* Animated counters
* Visual feedback and achievements (planned)

---

## 🛠️ Tech Stack

* **Flutter**: Cross-platform UI toolkit
* **Dart**: Core language
* **GetX**: State management and routing
* **Hive**: Lightweight local database
* **Path Provider**: For local file paths
* **PDF / Notifications Packages**: Custom file and alert generation

---

## 📦 Setup Instructions

1. **Clone the repo**

```bash
git clone https://github.com/visainnovations/magic_ledger.git
cd magic_ledger
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

> ✅ Requires Flutter SDK 3.10.0 or higher

---

## 📄 Resources

* [Flutter Documentation](https://docs.flutter.dev/)
* [GetX Guide](https://pub.dev/packages/get)
* [Hive Docs](https://docs.hivedb.dev/)
* [Neo-Brutalism UI Principles](https://brutalist-web.design/)

---

## 📬 Contact

**Author**: Visagan S
**Email**: [visagansvvg@gmail.com](mailto:visagansvvg@gmail.com)
**Company**: [visainnovations](mailto:visagansvvg@gmail.com)

---

> Magic Ledger: Where finance meets bold design and smarter decisions.
