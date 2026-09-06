# My NELFund — Modular Segment Roadmap & Task Log

## 1. Modular Execution Protocol
To ensure the highest accuracy, rigorous quality control, and Apple Human Interface Guidelines (HIG) fidelity, the development of **My NELFund** is strictly segmented. 

Each segment follows a clean two-step lifecycle:
1. **Segment Implementation Plan**: Detailed plan covering design, files, logic, and verification submitted for your review and explicit approval.
2. **Execution & Walkthrough**: Once approved, the segment is fully built, tested, and documented in a segment walkthrough before moving to the plan for the next segment.

---

## 2. Segments Breakdown

### Segment 1: Project Scaffolding, Logo Assets & Cupertino App Shell
- Initialize Flutter project with Cupertino focus and core dependencies (`cupertino_icons`, `intl`, `provider`, `shared_preferences`, `flutter_launcher_icons`).
- Ingest official NELFUND logo from `C:\Users\HP\Downloads\Nigerian_Education_Loan_Fund_(NELFUND).png` into app assets and configure native launcher icons.
- Build design tokens: `NelfundColors` (Sovereign Emerald `#008751`, Cupertino dynamic dark/light surfaces), `NelfundTypography` (Apple SF-style), and `AppleFrostedCard`.
- Setup `CupertinoTabScaffold` hosting all 5 core navigation tabs with frosted glass navigation bar.

### Segment 2: Tab 1 — Home & Overview
- Hero banner with official NELFUND logo and empathetic student welcome.
- "What is NELFUND" plain-English briefing based on the Students Loans Act 2024.
- Application Window Status Card (current open session, batch closing countdown, updateable).
- 3 Core Pillars summary (0% Interest, Direct Institutional Fees, ₦20,000 Monthly Upkeep).
- Quick-access interactive action cards to jump directly to Calculator, Eligibility Checker, FAQ, and Timeline Tracker.

### Segment 3: Tab 2 — Interactive Eligibility & Disqualification Checker
- Interactive multi-step checklist:
  - Nationality (NIN + BVN requirement).
  - Academic Qualification (Fresh Entry, Direct Entry, Full-time Undergraduate).
  - KYC Requirements (JAMB Number, BVN, NIN, Contact Info, Passport Photograph).
- Disqualification filter (prior default, active govt scholarship, disciplinary misconduct, criminal convictions, first degree holder).
- Non-binding diagnostic result banner ("Likely Eligible" vs "May be Disqualified") with actionable guidance and explanations.

### Segment 4: Tab 3 — Repayment Calculator & Default Escalation Visualizer
- Segmented toggle: Employed (PAYE) vs Self-employed (IBR).
- Interactive input fields & smooth sliders for Loan Amount and Monthly Salary / Business Profit.
- 10% statutory deduction calculation and payoff duration in months & years.
- 2-year post-NYSC moratorium countdown / timeline projection.
- Voluntary extra prepayment slider showing timeline shortening.
- **"Risks of Default" Escalation Panel**:
  1. Warning Notifications (SMS/Email)
  2. Credit Bureau & CRMS Blacklisting (credit frozen nationwide)
  3. Public Defaulter List publication
  4. GSI Mandate auto-debit across ALL BVN-linked bank accounts
  5. Legal Action & Court Prosecution.

### Segment 5: Tab 4 — FAQ Knowledge Base
- Stage-based category tabs: **Applying** | **Disbursement** | **Repayment** | **Default**.
- Real-time search bar and keyword filter.
- Detailed coverage of critical legal aspects: GSI mandate across all BVN accounts, quarterly employment disclosures, 60-day business disclosure for self-employed, official 15/10/10 SLA days.

### Segment 6: Tab 5 — Timeline & SLA Tracker
- Visual journey map with step-by-step SLA indicators:
  - Institutional verification: max 20 working days
  - NELFUND evaluation: 15 calendar days
  - Approval: max 10 working days
  - Disbursement: max 10 working days
  - ETI receipt: max 7 working days.
- Interactive "On-Track Evaluator": User inputs application date to check whether processing is on schedule or overdue.

### Segment 7: Final Polish, Automated Tests & Verification
- Unit test suite (`flutter test`) verifying calculation formulas, moratorium math, and SLA validations.
- Static analysis pass (`flutter analyze`) with 0 errors and 0 warnings.
- End-to-end walkthrough and release sign-off.

---

## 3. Active Segment Status Log

| Segment | Scope | Status | Walkthrough |
|---|---|---|---|
| **Segment 1** | Scaffolding, Logo, Cupertino Shell & Tokens | **Planned (Awaiting Approval)** | Pending |
| **Segment 2** | Tab 1: Home & Overview | Queued | Pending |
| **Segment 3** | Tab 2: Eligibility & Disqualification Checker | Queued | Pending |
| **Segment 4** | Tab 3: Repayment Calculator & Default Escalation | Queued | Pending |
| **Segment 5** | Tab 4: FAQ Knowledge Base | Queued | Pending |
| **Segment 6** | Tab 5: Timeline & SLA Tracker | Queued | Pending |
| **Segment 7** | Final Polish, Test Suite & End-to-End Review | Queued | Pending |
