# ✦ Magic Ledger

**Track. Save. Achieve.**

A powerful personal finance tracker with a bold neo-brutalist design, built with Flutter. Magic Ledger combines expense tracking, income management, budgeting, smart SMS detection, AI-powered insights, and 20+ features into one offline-first app.

**Author:** Visagan S  
**Brand:** [Visainnovations](mailto:visainnovations123@gmail.com) — *Making Tomorrow Magical*

---

## Screenshots

> *Neo-brutalist design with bold borders, colored shadows, and chunky typography across light and dark modes.*

---

## Why Magic Ledger?

Most finance apps are either too simple or too bloated. Magic Ledger hits the sweet spot — it's feature-rich without being overwhelming, looks distinctive without sacrificing usability, and works entirely offline without compromising on intelligence.

- **Offline-first** — All data lives on your device via Hive. No servers, no accounts, no subscriptions.
- **Neo-brutalist UI** — Bold, opinionated design that stands out from every other finance app.
- **Smart by default** — Auto-detects bank transactions from SMS, categorizes spending, and coaches you with on-device AI.
- **Privacy-respecting** — PIN + biometric lock, encrypted backups, all processing happens locally.

---

## Features

### Core Finance

- **Expense Tracking** — Add expenses with categories, tags, locations, receipts, and accounts. Sort by date or amount with date-grouped headers (Today, Yesterday, This Week, etc.).
- **Income Tracking** — Record income sources with account linking and recurring support.
- **Multi-Account System** — Create unlimited accounts (Cash, Bank, Wallet, etc.) with balances, transfers between accounts, and per-account filtering across the entire app.
- **Budget Management** — Set monthly budgets per category with progress tracking and overspend alerts.
- **Category System** — Unlimited custom categories with emoji icons and color coding.
- **Recurring Transactions** — Set expenses and incomes to auto-generate daily, weekly, monthly, or yearly.

### Smart Features

- **SMS Auto-Detection** — Reads bank SMS (HDFC, SBI, ICICI, Axis, Kotak, and 20+ Indian banks) and extracts transaction amount, merchant, UPI ID, account number, and reference number. One-tap to add as expense or income.
- **AI Money Coach** — On-device TFLite intent classifier (18 intents, 96.6% accuracy) answers questions about your spending, savings, and financial habits.
- **Spending Insights** — Auto-generated digest of spending patterns, top categories, and trends.
- **Smart Search** — Search across all expenses, incomes, and todos instantly.

### Analytics & Reports

- **Interactive Analytics** — Pie charts, line charts, category breakdowns, and trend analysis.
- **Period Navigation** — Browse any month/year with comparison to previous periods.
- **PDF Reports** — Generate and share visual PDF reports of your finances.
- **CSV Export** — Export all data, expenses only, or incomes only as CSV files.

### Productivity

- **Todo System** — Task management with priorities (High/Med/Low), due dates, and completion tracking.
- **Financial Calendar** — Calendar view of all transactions and upcoming events.
- **Savings Goals** — Set targets, contribute/withdraw, and track progress toward goals.
- **Debt & EMI Tracker** — Track debts with payment recording and remaining balance.
- **Subscription Tracker** — Monitor recurring subscriptions with renewal dates.
- **Split Expenses** — Track shared expenses with friends/groups and who owes what.

### AI & Lifestyle

- **Monthly Money Story** — Auto-generated narrative summary of your month's financial activity.
- **Expense Mood Journal** — Tag expenses with moods to understand emotional spending patterns.
- **What-If Simulator** — Simulate financial scenarios (what if I save X more per month?).
- **Expense Templates** — Save frequent expenses as one-tap quick-adds.

### Security & Backup

- **PIN Lock** — 4-6 digit PIN with SHA-256 hashing and lockout protection.
- **Biometric Auth** — Fingerprint/face unlock via local_auth.
- **Recovery Phrase** — 12-word recovery phrase for PIN reset (like crypto wallets).
- **Auto-Lock** — Configurable lock timeout when app goes to background.
- **Encrypted Backup** — File-level .hive binary backup with gzip compression and XOR encryption. Share via any app, restore on any device.

### Achievements & Gamification

- **15 Achievements** — Unlock badges for financial milestones (first expense, budget streak, savings goal reached, etc.).
- **Streak Tracking** — Track consecutive days of expense logging.
- **Android Home Widget** — Glanceable balance and spending summary on your home screen.

---

## Design System

Magic Ledger uses a **neo-brutalist** design language throughout:

- **Bold 3px borders** on all interactive elements
- **Offset box shadows** (colored, not grey) that create a layered, tactile feel
- **Button press effects** — shadow collapses and element shifts on tap
- **Chunky typography** — w900 weight headers, monospace accents
- **Vibrant color palette** — 10 accent colors that adapt for dark mode
- **Staggered animations** — fadeIn + slideY on page load, elastic scale on key elements

The theme is centralized in `neo_brutalism_theme.dart` with helpers like `neoBox()`, `getThemedColor()`, and shared widgets (`NeoButton`, `NeoCard`, `NeoAutocompleteInput`).

---

## Architecture

```
Pattern:    MVC with GetX
State:      GetX reactive (Rx variables + Obx widgets)
Storage:    Hive (12 typed boxes, 12 model adapters)
Navigation: GetX named routes with GetView/GetxController
DI:         GetX dependency injection (permanent services in InitialBinding)
AI:         TFLite on-device inference (66.4KB model)
```

### Project Structure

```
lib/app/
├── bindings/
│   └── initial_binding.dart
├── data/
│   ├── models/           # 12 Hive models (TypeId 0-11)
│   ├── providers/
│   │   └── hive_provider.dart
│   └── services/
│       ├── auth_service.dart
│       ├── backup_service.dart
│       ├── export_service.dart
│       ├── home_widget_service.dart
│       ├── insights_service.dart
│       ├── money_coach_service.dart
│       ├── notification_service.dart
│       ├── period_service.dart
│       ├── recurring_service.dart
│       ├── sms_transaction_service.dart
│       └── transaction_parser.dart
├── modules/
│   ├── home/              # Dashboard + bottom navigation
│   ├── expense/           # Expense CRUD + sort/filter/date-headers
│   ├── income/            # Income CRUD
│   ├── todo/              # Todo management
│   ├── analytics/         # Charts and breakdowns
│   ├── account/           # Multi-account + transfers
│   ├── budget/            # Budget management
│   ├── category/          # Category management
│   ├── auth/              # PIN setup, lock screen, reset
│   ├── backup/            # Encrypted backup & restore
│   ├── savings/           # Savings goals
│   ├── debt/              # Debt/EMI tracker
│   ├── subscription/      # Subscription tracker
│   ├── split/             # Split expenses
│   ├── search/            # Smart search
│   ├── notifications/     # SMS transaction inbox
│   ├── coach/             # AI money coach
│   ├── story/             # Monthly money story
│   ├── mood/              # Mood journal
│   ├── simulator/         # What-if simulator
│   ├── insights/          # Spending insights
│   ├── settings/          # App settings
│   └── achievements/      # Badges & streaks
├── routes/
│   └── app_pages.dart
├── theme/
│   └── neo_brutalism_theme.dart
└── widgets/
    ├── neo_button.dart
    ├── neo_card.dart
    ├── neo_autocomplete_input.dart
    └── neo_date_range_picker.dart
```

### Hive Data Models

| TypeId | Model | Box Name |
|--------|-------|----------|
| 0 | ExpenseModel | `expenses` |
| 1 | IncomeModel | `income` |
| 2 | TodoModel | `todos` |
| 3 | BudgetModel | `budgets` |
| 4 | CategoryModel | `categories` |
| 5 | ReceiptModel | `receipts` |
| 6 | AccountModel | `accounts` |
| 7 | TransferModel | `transfers` |
| 8 | SavingsGoalModel | `savings_goals` |
| 9 | DebtModel | `debts` |
| 10 | SplitModel | `splits` |
| 11 | SubscriptionModel | `subscriptions` |

Additional untyped boxes: `expense_moods`, `sms_processed`, `sms_suggestions`, `expense_templates`, `achievements`

---

## SMS Auto-Detection

Magic Ledger reads incoming bank SMS and extracts transaction details using regex patterns. Supported formats from 20+ Indian banks:

**Supported Banks:** HDFC, SBI, ICICI, Axis, Kotak, PNB, BOB, IndusInd, Yes Bank, IDFC, Federal, Canara, Union, IOB, Indian Bank, Bandhan, RBL, DBS, Citi, HSBC, Standard Chartered, Paytm, Fi, Jupiter, Niyo, Slice

**Auto-Extracted Fields:**
- Transaction type (credit/debit)
- Amount
- Bank name & account last 4 digits
- Merchant/payee name
- UPI ID & reference number
- Suggested category (Swiggy → Food, Uber → Transport, Amazon → Shopping, etc.)
- Transaction date (parsed from SMS body)

**Notification Inbox Features:**
- Filter by: All, Today, Week, Month, Credits, Debits
- Date-grouped headers: Today, Yesterday, This Week, This Month, older months
- Configurable scan depth: 7 / 30 / 90 / 180 / 365 days
- One-tap add or edit-then-add workflow
- Swipe to dismiss (session-only, returns on rescan)

---

## AI Money Coach

On-device TFLite model trained on 14,500+ augmented samples across 18 intents:

`greeting, total_spending, spending_by_category, budget_status, savings_advice, compare_months, top_expense, daily_average, income_summary, recurring_expenses, spending_trend, financial_health, reduce_spending, set_budget, upcoming_bills, debt_status, split_expenses, export_data`

Model size: **66.4KB** — runs instantly on-device with zero latency.

---

## Setup

### Prerequisites

- Flutter SDK 3.10.0+
- Android Studio / VS Code
- Android device or emulator (SMS features require physical device)

### Installation

```bash
git clone https://github.com/visainnovations/magic_ledger.git
cd magic_ledger
flutter pub get
flutter run
```

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

### Build Release APK

```bash
flutter build apk --release --target-platform android-arm64
```

> Optimized build: ~43MB (single arch, minified, shrunk resources)

---

## Dependencies

```yaml
dependencies:
  get: ^4.7.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  fl_chart: ^0.66.0
  intl: ^0.19.0
  flutter_animate: ^4.3.0
  telephony: ^0.2.0+1
  local_auth: ^2.1.8
  crypto: ^3.0.3
  file_picker: ^6.1.1
  flutter_local_notifications: ^17.0.0
  tflite_flutter: ^0.10.4
```

---

## Privacy

Magic Ledger is designed with privacy as a core principle:

- **All data stored locally** — nothing leaves your device
- **No analytics or tracking** — zero telemetry
- **No accounts or sign-up** — just install and use
- **SMS parsing happens on-device** — no SMS data sent anywhere
- **AI inference runs locally** — TFLite model, no API calls
- **Encrypted backups** — AES-derived XOR encryption with user passphrase

---

## Roadmap

- [ ] Smart Alerts (budget exceeded, unusual spending patterns)
- [ ] Financial Score (0-100 health metric)
- [ ] Spending Heatmap (calendar-style visualization)
- [ ] Multi-Currency Support
- [ ] Cloud Sync (optional, encrypted)
- [ ] iOS Release

---

## License

Proprietary. All rights reserved.  
© 2026 Visainnovations

---

## Contact

**Visagan S**  
📧 visainnovations123@gmail.com  
🏢 Visainnovations — *Making Tomorrow Magical*

---

> *Magic Ledger: Where finance meets bold design and smarter decisions.*