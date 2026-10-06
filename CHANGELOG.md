# Changelog

All notable changes to the **My NELFund** application and ecosystem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.2.5] - 2026-10-06

### Added
- **Interactive WhatsApp Digital Solutions CTA**: Introduced an Apple Frosted Glass Card (`_buildDigitalSolutionsCtaCard`) inviting individuals, businesses, and organisations needing custom mobile/web apps or software platforms to connect directly on WhatsApp with pre-filled inquiry text.
- **Official Statutory Loan Inquiries Routing**: Prominent official advisory directing student loan concerns (SVS, application status, disbursement, and stipends) exclusively to `info@nelf.gov.ng` with an active `mailto:` deeplink.
- **Bilingual Hausa Translations**: Full localized strings for digital software capabilities and official inquiry guidance in `AppTranslations`.

### Changed
- **Developer Identity Refinement**: Updated developer profile to strictly highlight academic affiliation as a student at Ahmadu Bello University (ABU), Zaria, removing external agency designations.
- **Strictly Technical Feedback Focus**: Explicitly communicated that developer feedback channels are dedicated solely to mobile application bugs, performance improvements, and UI enhancements.
- **Version Bump**: Upgraded production build target to `v2.2.5` (Build 10).

---

## [2.2.4] - 2026-10-06

### Added
- **Language-Targeted Push Notifications**: Firebase Cloud Messaging (FCM) topic subscriptions for `lang_en` (English) and `lang_ha` (Hausa), enabling targeted bulletins based on active student language preferences.
- **Enterprise Telemetry & Audience Breakdown**: Added `/api/user-stats` in the Admin Portal server tracking registered device count segmented by English and Hausa speakers.
- **Automated Statutory FAQ Push Dispatches**: Adding or editing FAQ policies via the Enterprise Admin Portal automatically triggers targeted push notifications to all student devices in both languages.
- **Resilient Offline FAQ Mode**: Dedicated offline fallback banner with a manual "Retry Connection" button when no local cache or internet is available.
- **Dynamic Network Connectivity Monitoring**: Integrated `connectivity_plus` to automatically detect restored internet access and trigger background sync for statutory FAQs.
- **In-App Version History & Changelog Modal**: Cupertino modal accessible directly from the About & Support tab detailing all updates in English and Hausa.

### Changed
- **Localized Notification Center**: In-app notifications now dynamically resolve and display localized English or Hausa titles and bodies according to the user's selected language.
- **Bilingual Push Notifications Composer**: Admin portal push notification composer now supports simultaneous English and Hausa title and body input fields.
- **Updated Version Indicators**: Synchronized production version markers across `pubspec.yaml`, About tab, and Admin Portal footer to `v2.2.4`.

### Fixed
- Addressed edge cases where FAQ fetch on cold boot without an active internet connection could leave the list in an empty unhandled state.
- Enhanced test coverage in `test/faq_test.dart` and `test/app_integration_test.dart` for offline states and multi-language notification lookups.

---

## [2.2.3] - 2026-10-02

### Added
- **Local Persistence for Custom Loans**: Student loan parameters (tuition amounts, upkeep months, payment history) now persist on device storage via `shared_preferences` across app restarts.
- **Persistent Notification Center Inbox**: Dispatched bulletins and read/unread statuses are cached locally, preserving notification history offline.
- **Cloud Firestore Synchronization for 19 In-App FAQs**: Complete two-way sync between bundled static FAQs and Cloud Firestore with server-and-cache fallback.

---

## [2.2.0] - 2026-10-02

### Added
- **Enterprise Administration Portal**: Web dashboard hosted on `http://localhost:4040` for real-time FAQ CRUD operations and push notification broadcasting via Firebase Admin SDK.
- **Fullscreen In-App Notification Center**: Dedicated notifications interface displaying high-priority alerts, timestamped bulletins, and category badges.
- **ABU Zaria & NELFUND Animated Dual-Logo Splash**: Dynamic splash sequence featuring rocket flight trajectory animation and the official tagline *"Education is a Right, Not a Privilege"*.
- **Upkeep Month Calendar Selector**: Interactive upkeep allowance calculator with monthly selectors and voluntary repayment schedule visualizer.

### Fixed
- Resolved modal scrolling and real-time listener race conditions in the web administrative console.

---

## [2.1.0] - 2026-09-21

### Added
- **Complete Hausa Language Localization**: Added full Hausa translations across all 5 core tabs, statutory guidelines, calculation cards, and legal citations.
- **Header Language Switcher**: One-tap toggle in the Home header allowing seamless switching between English and Hausa (`AppLanguage.english` / `AppLanguage.hausa`).
- **Bilingual Onboarding Sheet**: Interactive welcome modal explaining core Students Loans Act 2024 principles in the user's preferred language.

---

## [1.0.0+2] - 2026-09-08

### Added
- **Automated TestFlight Delivery**: Added fast direct iOS distribution workflow using `xcrun altool` and automated CI signing.
- **Android High-Priority Notification Channel**: Configured native heads-up notifications with sound, vibration, and data payload handling.
- **In-App Store Review & Live Updates**: Integrated `in_app_review` and `in_app_update` for seamless user feedback and prompt app upgrades.
- **About & Civic Support View**: Replaced legacy timeline tab with a dedicated About & Support tab featuring developer credits, WhatsApp support hotline, and official civic disclaimers.

### Changed
- Refined NELFUND crest icon centering and padding for Android adaptive safe zone and iOS square standards.
- Added platform-aware App Store and Google Play Store deep links.

---

## [1.0.0] - 2026-09-06

### Added
- **Initial Production Release**: First official release of My NELFund mobile application.
- **Apple Cupertino Human Interface Guidelines (HIG)**: Premium design foundation utilizing frosted cards, SF typography, and emerald brand accents.
- **Tab 1 — Home & Overview**: Application window status card, 3 core pillars (0% interest, direct tuition disbursement, ₦20,000 monthly upkeep stipend), and quick-action navigation.
- **Tab 2 — Eligibility Checker**: Multi-step interactive diagnostic checklist covering NIN, BVN, JAMB requirements, and statutory disqualification rules.
- **Tab 3 — Repayment Calculator**: 10% statutory deduction calculator (PAYE and Self-Employed IBR), 2-year post-NYSC moratorium countdown, and default escalation visualizer.
- **Tab 4 — FAQ Knowledge Base**: 19 official statutory questions and answers organized across 4 lifecycle stages (Applying, Disbursement, Repayment, Default).
- **Tab 5 — SLA Timeline Tracker**: Official turnaround benchmark tracker (20-day ETI verification, 15-day evaluation, 10-day approval, 10-day disbursement).
- **Automated Test Suite**: 24 passing automated tests verifying calculation logic, SLA timelines, and UI scaffolds.
