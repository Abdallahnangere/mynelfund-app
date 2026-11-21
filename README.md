# My NELFund

An independent, bilingual (English and Hausa) mobile companion for Nigerian tertiary students navigating the **Students Loans (Access to Higher Education) Act 2024** (NELFUND).

Built with Flutter and Cupertino design principles for smooth native performance, offline resilience, and statutory accuracy.

---

## Core Capabilities

- **Program Overview & Statutory Reference**: Clear summary of the 2024 Act covering `0%` zero-interest student financing, direct institutional tuition disbursement, and the `₦20,000` monthly upkeep allowance.
- **Eligibility & KYC Diagnostic**: Interactive assessment across Fresh Entry (`100L`), Direct Entry (`200L`), and Returning Undergraduate streams against Section 2.0 criteria, Section 3.0 disqualification bars, and mandatory KYC readiness (`BVN`, `NIN`, `JAMB`, `SVS`).
- **10% Statutory Repayment Calculator**: Multi-session academic portfolio builder (`100L–600L`) with a 12-month upkeep selector, post-NYSC 2-year protected moratorium timeline, PAYE / IBR stream switcher, and voluntary accelerated repayment modeling.
- **Official 5-Stage SLA Tracker**: Evaluates application processing health (`On Track`, `Approaching Deadline`, `Overdue`) in working days against official NELFUND SLA benchmarks and Section 6.0 escalation channels.
- **Offline-First Bilingual FAQ & Bulletins**: Searchable statutory Q&A and real-time Cloud Firestore / FCM announcement feed cached locally via `SharedPreferences`.

---

## Architecture

The codebase follows a **Feature-First Clean Architecture**:

```text
lib/
├── app/                         # Application root, Cupertino tab shell, fallback delegates
├── core/
│   ├── constants/               # Statutory Act 2024 constants and bilingual loan pillars
│   ├── formatters/              # Cached Naira currency & cursor-safe input formatters
│   ├── localization/            # Bilingual (en / ha) provider and translation catalog
│   ├── services/                # Analytics, FCM notifications, in-app review, update services
│   └── theme/                   # Color tokens, Cupertino themes, typography scale
├── features/
│   ├── about/                   # System settings, independent disclaimer, developer attribution
│   ├── calculator/              # Domain projection models, debounced provider, calculator UI
│   ├── eligibility/             # Statutory diagnostic models, checklist cards, report modal
│   ├── faq/                     # Searchable FAQ repository/provider, spotlight & accordion UI
│   ├── home/                    # Dashboard overview, quick-access grid, language header toggle
│   ├── notifications/           # Real-time bulletin inbox, unread tracking, offline cache
│   ├── promo/                   # Remotely configurable Sauki Go companion utility cards
│   ├── splash/                  # Dual-crest ABU/NELFUND splash bridge with parabolic animation
│   └── timeline/                # 5-stage SLA calculator and Section 6.0 escalation directory
├── shared/
│   └── widgets/                 # Reusable Apple frosted cards, glass header, capsule nav bar, badges
└── main.dart                    # Application entrypoint
```

---

## Technical Stack

- **Framework**: Flutter (`3.x`) & Dart (`>=3.11.5`)
- **State Management**: `provider` with scoped `Selector` / `ChangeNotifier` separation
- **Persistence & Sync**: `shared_preferences`, `cloud_firestore`, `firebase_core`, `firebase_messaging`, `firebase_analytics`
- **Localization & Formatting**: `flutter_localizations`, `intl` (English & Hausa)
- **External Integrations**: `url_launcher`, `in_app_review`, `connectivity_plus`

---

## Local Development & Verification

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Build verification:

```bash
flutter build web
flutter build apk --debug
```

---

## Statutory & Privacy Notice

**My NELFund** is an independent civic student utility designed for educational and financial planning purposes. It is **not affiliated with, endorsed by, or operated by** the Nigerian Education Loan Fund (NELFUND). Loan calculations and eligibility checks run locally on-device with zero collection of `BVN`, `NIN`, `JAMB`, or banking credentials. For official applications, visit `https://nelf.gov.ng`.
