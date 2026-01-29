# AI-Driven Budget Planning Module (Finance App)

## Purpose
This document defines a **questionnaire-based budgeting system** for a finance application.
The budgeting module starts empty and builds personalized monthly budgets by asking users
structured questions. Based on the responses, the system generates **3–5 viable budgeting plans**.

The design is **Nepal-aware** but **globally adaptable**.

---

## 1. Core Design Principles

- No assumptions about user income or expenses
- Fully user-driven input
- Monthly planning by default
- Flexible allocations (spend, save, invest, repay loans)
- AI-assisted recommendations, not hard rules
- Works for any currency or country

---

## 2. Budget Creation Flow

### Step 1: User Onboarding for Budgeting
When the user opens the Budget section for the first time:
- Show empty state
- Explain: *“We’ll ask a few questions to help you build a budget that fits your life.”*

---

## 3. Questionnaire (Input Collection)

### 3.1 Income
Ask the user:
- Primary monthly income (salary/business)
- Secondary income (freelance, rent, remittance, etc.)
- Income frequency (monthly / irregular)

**Output**
```json
{
  "totalMonthlyIncome": number
}
```

---

### 3.2 Fixed Commitments (Needs)
Ask:
- Rent or housing cost
- Loan / EMI payments
- Insurance
- Utilities (electricity, water, internet)
- Education fees
- Other fixed monthly commitments

**Output**
```json
{
  "fixedExpenses": {
    "rent": number,
    "emi": number,
    "utilities": number,
    "others": number
  }
}
```

---

### 3.3 Variable Living Expenses
Ask approximate monthly spending:
- Food & groceries
- Transportation
- Personal & household
- Entertainment
- Festivals / irregular expenses (monthly average)

---

### 3.4 Savings Preferences
Ask:
- Do you currently save money? (Yes/No)
- Desired monthly savings (amount or %)
- Emergency fund goal (months of expenses)

---

### 3.5 Investment Preferences
Ask:
- Do you invest currently? (Yes/No)
- Preferred investment types:
  - Fixed deposits
  - Mutual funds
  - Stocks
  - Other
- Risk preference: Low / Medium / High

---

### 3.6 Flexibility & Lifestyle
Ask:
- Priority order (rank):
  - Saving
  - Investing
  - Spending freely
  - Paying off debt faster
- Comfort with strict limits (Low / Medium / High)

---

## 4. AI Budget Plan Generation Logic

After collecting inputs:
1. Calculate disposable income
2. Identify constraints (EMI, rent, essentials)
3. Detect user priorities
4. Generate **3–5 plans**, each with:
   - Monthly allocations
   - Pros & trade-offs
   - Who the plan is best for

---

## 5. Budget Plan Types (3–5 Options)

### Plan 1: Balanced Budget (50/30/20 Inspired)
**Structure**
- Needs: ~50%
- Wants: ~30%
- Savings + Investments: ~20%

**Best for**
- First-time budgeters
- Stable income users

---

### Plan 2: High Savings & Investment Plan
**Structure**
- Needs: Optimized minimum
- Savings & Investments: 30–40%
- Wants: Flexible remainder

**Best for**
- Goal-driven users
- Future planning (house, education)

---

### Plan 3: Debt-Focused Plan
**Structure**
- EMI & debt: Priority
- Needs: Covered
- Savings: Minimum safety buffer
- Wants: Limited

**Best for**
- Users with high loans
- EMI-heavy households

---

### Plan 4: Zero-Based Budget
**Structure**
- Every unit of income is assigned
- No unallocated money

**Best for**
- Detail-oriented users
- Expense control mindset

---

### Plan 5: Flexible Lifestyle Plan
**Structure**
- Fixed needs covered
- Large discretionary bucket
- Adaptive saving/investing

**Best for**
- Freelancers
- Variable income users

---

## 6. Sample Plan Output (In-App)

```json
{
  "planName": "Balanced Budget",
  "monthlyIncome": 100000,
  "allocation": {
    "needs": 50000,
    "wants": 30000,
    "savings": 20000
  },
  "notes": "A safe and flexible plan suitable for stable income."
}
```

---

## 7. Nepal Context (Optional Layer)

- Currency-agnostic design
- Supports:
  - Festival expenses (Dashain, Tihar)
  - Local investments (FDs, cooperatives)
- EMI-first logic common in Nepal households

---

## 8. AI Enhancements (Future Scope)

- Detect overspending patterns
- Suggest budget adjustments month-to-month
- Natural language budget explanation
- “What-if” simulations (salary change, new loan)

---

## 9. Key Outcome

At the end of this flow:
- User sees **3–5 personalized budget plans**
- User can:
  - Select one
  - Customize it
  - Switch plans anytime

---

## 10. Intended Use

This markdown file can be:
- Sent directly to an AI agent
- Used as a product spec
- Used by developers to implement budgeting logic
