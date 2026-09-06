# My NELFund — Modular Segment Roadmap & Task Log

## 1. Modular Execution Protocol
To ensure the highest accuracy, rigorous quality control, and Apple Human Interface Guidelines (HIG) fidelity, the development of **My NELFund** is strictly segmented. 

Each segment follows a clean two-step lifecycle:
1. **Segment Implementation Plan**: Detailed plan covering design, files, logic, and verification submitted for your review and explicit approval.
2. **Execution & Walkthrough**: Once approved, the segment is fully built, tested, and documented in a segment walkthrough before moving to the plan for the next segment.

---

## 2. Segments Breakdown

### Segment 1: Project Scaffolding, Logo Assets & Cupertino App Shell
- Initialize Flutter project with Cupertino focus and core dependencies.
- Ingest official NELFUND logo and configure native launcher icons.
- Build design tokens (`NelfundColors`, `NelfundTypography`, `NelfundTheme`, `AppleFrostedCard`).
- Setup `CupertinoTabScaffold` hosting 5 core navigation tabs.
- **Status: COMPLETED (Commit: `feat(core): scaffold My NELFund...`)**

### Segment 2: Tab 1 — Home & Overview
- Hero banner with official NELFUND logo and empathetic student welcome.
- "What is NELFUND" plain-English briefing based on the Students Loans Act 2024.
- Application Window Status Card (current open session, batch closing countdown, updateable).
- 3 Core Pillars summary (0% Interest, Direct Institutional Fees, ₦20,000 Monthly Upkeep).
- Quick-access interactive action cards to jump directly to Calculator, Eligibility Checker, FAQ, and Timeline Tracker.
- **Status: IN PLANNING (Awaiting Approval)**

### Segment 3: Tab 2 — Interactive Eligibility & Disqualification Checker
- Interactive multi-step checklist (Nationality NIN/BVN, Academic criteria, KYC requirements).
- Disqualification filter (prior default, active govt scholarship, disciplinary misconduct, criminal convictions, first degree holder).
- Non-binding diagnostic result banner ("Likely Eligible" vs "May be Disqualified") with actionable guidance and explanations.
- **Status: Queued**

### Segment 4: Tab 3 — Repayment Calculator & Default Escalation Visualizer
- Segmented toggle: Employed (PAYE) vs Self-employed (IBR).
- Interactive input fields & smooth sliders for Loan Amount and Monthly Salary / Business Profit.
- 10% statutory deduction calculation and payoff duration in months & years.
- 2-year post-NYSC moratorium countdown / timeline projection.
- Voluntary extra prepayment slider showing timeline shortening.
- "Risks of Default" Escalation Panel (Warning → CRMS/Credit Bureau → Defaulter List → GSI Auto-Debit → Legal Action).
- **Status: Queued**

### Segment 5: Tab 4 — FAQ Knowledge Base
- Stage-based category tabs: **Applying** | **Disbursement** | **Repayment** | **Default**.
- Real-time search bar and keyword filter.
- Detailed coverage of critical legal aspects (GSI across all BVN accounts, quarterly employment disclosures, 60-day business disclosure, 15/10/10 SLAs).
- **Status: Queued**

### Segment 6: Tab 5 — Timeline & SLA Tracker
- Visual journey map with step-by-step SLA indicators.
- Interactive "On-Track Evaluator": User inputs application date to check whether processing is on schedule or overdue.
- **Status: Queued**

### Segment 7: Final Polish, Automated Tests & Verification
- Unit test suite (`flutter test`) verifying calculation formulas, moratorium math, and SLA validations.
- Static analysis pass (`flutter analyze`) with 0 errors and 0 warnings.
- End-to-end walkthrough and release sign-off.
- **Status: Queued**

---

## 3. Active Segment Status Log

| Segment | Scope | Status | Walkthrough | Commit Reference |
|---|---|---|---|---|
| **Segment 1** | Scaffolding, Logo, Cupertino Shell & Tokens | **COMPLETED** | [Walkthrough 1](file:///C:/Users/HP/.gemini/antigravity/brain/60e71855-f55c-4a33-8801-2a43a4566c26/walkthrough.md) | `feat(core): scaffold My NELFund...` |
| **Segment 2** | Tab 1: Home & Overview | **In Planning (Awaiting Approval)** | Pending | Pending |
| **Segment 3** | Tab 2: Eligibility & Disqualification Checker | Queued | Pending | Pending |
| **Segment 4** | Tab 3: Repayment Calculator & Default Escalation | Queued | Pending | Pending |
| **Segment 5** | Tab 4: FAQ Knowledge Base | Queued | Pending | Pending |
| **Segment 6** | Tab 5: Timeline & SLA Tracker | Queued | Pending | Pending |
| **Segment 7** | Final Polish, Test Suite & End-to-End Review | Queued | Pending | Pending |
