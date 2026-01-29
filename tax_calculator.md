# Product Requirements Document (PRD)

## Feature Name

**Income Tax Calculator (Nepal-focused, Generic Support)**

## Overview

This feature replicates the **exact calculation logic and visual breakdown** of the provided Excel-based Tax Calculator into the existing Flutter app. The goal is to maintain **formula parity**, **slab-wise tax visibility**, and **monthly in-hand salary calculation**, while making the UI mobile-friendly and extensible for future tax rule changes.

The feature will be added to the existing app as a new module and must not break existing flows.

---

## Objectives

* Match **all formulas and outputs** from the Excel file
* Provide **clear visual representation** of tax slabs and deductions
* Support **Nepal income tax rules** while keeping architecture generic
* Enable **real-time recalculation** on input changes
* Make tax logic **configurable and testable**

---

## Target Users

* Salaried individuals
* Users with fixed monthly income
* Users contributing to CIT / SSF
* Married & unmarried taxpayers

---

## Inputs (User Provided)

### Personal & Employment Inputs

* Monthly Total Gross Salary
* Monthly Basic Salary
* Marital Status (Single / Married)
* Enrolled in SSF (Yes / No)
* Female Tax Rebate (Yes / No)

### Monthly / Annual Deductions

* Monthly CIT Contribution
* Monthly SSF Contribution
* Annual Life Insurance
* Annual Health Insurance
* Festive / Leave / Incentive Income (Annual)

---

## Derived Annual Values (Formulas)

### Annual Assessable Income

```
(Monthly Gross × 12) + Annual Incentives
```

### Annual CIT

```
Monthly CIT × 12
```

### Annual SSF Contribution

```
Monthly SSF × 12
```

### Retirement Deduction Cap

```
min(Annual CIT + Annual SSF, 500000)
```

### Insurance Deduction

```
min(Life Insurance + Health Insurance, 40000)
```

### Net Taxable Income

```
Annual Assessable Income
- Retirement Deduction
- Insurance Deduction
```

---

## Tax Slabs (Nepal – FY Standard)

### Slab Definitions

| Slab | Rate               | Single Range          | Married Range         |
| ---- | ------------------ | --------------------- | --------------------- |
| I    | 0% (1% if not SSF) | 0 – 5,00,000          | 0 – 6,00,000          |
| II   | 10%                | 5,00,001 – 7,00,000   | 6,00,001 – 8,00,000   |
| III  | 20%                | 7,00,001 – 10,00,000  | 8,00,001 – 11,00,000  |
| IV   | 30%                | 10,00,001 – 20,00,000 | 11,00,001 – 20,00,000 |

---

## Tax Calculation Logic

### Slab-wise Tax Formula

For each slab:

```
Tax in Slab = min(
  Slab Upper Limit - Slab Lower Limit,
  Remaining Taxable Income
) × Slab Rate
```

### First Slab Special Rule

* If SSF = Yes → 0%
* If SSF = No → 1%

---

## Outputs

### Tax Breakdown View (Visible Slabs)

* Slab Name
* Tax Amount per Slab
* Percentage Rate

### Summary

* Total Annual Tax
* Monthly TDS (Average)

Formula:

```
Monthly TDS = Total Annual Tax / 12
```

---

## Monthly In-Hand Salary Calculation

### Formula

```
In-Hand = Monthly Gross
- Monthly Tax (TDS)
- Monthly CIT
- Monthly SSF
```

### Breakdown Display

* Gross Salary
* Tax Deduction
* CIT Deduction
* SSF Deduction
* Final In-Hand Amount

---

## UI / UX Requirements

### Screens

1. **Input Form Screen**

   * Step-based or grouped inputs
   * Real-time validation

2. **Tax Breakdown Screen**

   * Slab-wise expandable cards
   * Highlight active slabs

3. **Summary Card**

   * Annual Tax
   * Monthly TDS

4. **In-Hand Salary Card**

   * Visual deduction breakdown

---

## Visual Representation Guidelines

* Use **cards** for sections (Inputs, Slabs, Summary)
* Slab breakdown should resemble Excel rows
* Use color coding per slab (neutral tones)
* Currency: NPR

---

## Architecture & Tech Notes

### Flutter

* Feature module based structure
* State management: Riverpod
* Pure Dart service for tax calculations

### Calculation Service

* Stateless
* Fully unit-testable
* No UI dependency

---

## Non-Functional Requirements

* All calculations must be deterministic
* No hardcoded UI values for slabs
* Slabs must be configurable via constants or JSON
* Performance: instant recalculation

---

## Out of Scope (Phase 1)

* Multiple income sources
* Capital gains tax
* Export to PDF
* Historical tax comparison

---

## Acceptance Criteria

* Output values exactly match Excel for same inputs
* Slab-wise totals are correct
* Monthly in-hand matches Excel
* Works for both Single & Married cases

---

## Future Enhancements

* FY selection
* Country-based tax engines
* Tax saving recommendations
* PDF / Excel export
