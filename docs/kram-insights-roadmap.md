# Kram Insights Pipeline — Product Roadmap

---

## Overview

The Kram Insights Pipeline transforms the platform from a passive data store into an active intelligence layer. Instead of teachers and admins manually looking for problems, the system surfaces them automatically — and eventually predicts them before they happen.

### Core Principle

| Version | Question Answered |
|---|---|
| V1 | What just happened? |
| V2 | What has been happening? |
| V3 | What is about to happen? |

---

## V1 — Real-Time Event Intelligence

**Timeline:** 6 weeks
**Goal:** Replace nightly batch processing with live triggers. Dashboard feels alive.

### How It Works

Whenever data changes in the system, thresholds are checked and insights fire immediately:

```
Teacher marks attendance → 3rd absence detected   → insight fires instantly
Exam result saved        → class average drops 10% → insight fires instantly
Assignment not submitted → 3rd consecutive miss    → insight fires instantly
```

Insights are pushed to the frontend in real time via WebSocket — no polling, no page refresh.

### Progressive Insight Cards

Each insight card has 3 layers of depth:

| Layer | What the user sees |
|---|---|
| Layer 1 (Card) | "5 students with high absences this week" |
| Layer 2 (Expand) | Ahmed, Sara, John — with their individual patterns |
| Layer 3 (Action) | "Send parent notice" — one tap executes it |

### Existing Infrastructure Used

| Existing Piece | How It's Used |
|---|---|
| `Attendance` model | Trigger source for absence thresholds |
| `ExamResult` model | Trigger source for score drops |
| `Submission` model | Trigger source for missed homework |
| `AiService` | Generates the insight text |
| `SystemAlert` model | Repurposed as the Insights table |
| `Communication` module | Executes the "Send parent notice" action |

### What Gets Built

- `InsightsModule` with threshold listeners on data change events
- WebSocket gateway for real-time push to frontend
- `GET /insights` endpoint filtered by role (admin / teacher)
- `POST /insights/:id/action` to execute one-tap actions
- `Insight` database model with severity, category, entity, and action fields

### Sample Insight Object

```json
{
  "severity": "critical",
  "category": "attendance",
  "title": "5 students with high absences",
  "body": "Ahmed, Sara, and 3 others have missed 3+ classes this week.",
  "actionLabel": "Send Parent Notice",
  "entityType": "class",
  "entityId": 42
}
```

---

## V2 — Pattern Recognition

**Timeline:** 3 months after V1
**Goal:** Move from isolated events to multi-week trends per student.

### How It Works

A weekly pattern job runs every Sunday night per student:

```
Collects last 4 weeks of:
  - Attendance rate          (trend: improving / stable / declining)
  - Homework submission rate
  - Exam score trajectory
  - Behavioral log frequency

        ↓

AI summarizes the pattern per student

        ↓

Stored as a StudentPattern record
```

### V1 vs V2 Insight Quality

| Version | Insight |
|---|---|
| V1 | "Ahmed missed 3 classes this week" |
| V2 | "Ahmed's attendance has dropped every week for 4 weeks. Now at 60%." |

### Monday Teacher Digest

Every Monday morning, each teacher receives a class summary:

```
This week in Grade 9B:
  - 3 students showing declining patterns
  - 2 students significantly improved
  - Math homework completion dropped to 65%
```

### What Gets Built

- `StudentPattern` model — weekly snapshot per student
- Pattern analyzer service — reads last 4 weeks, AI generates summary
- Monday digest scheduler
- Push notification trigger when a pattern crosses a threshold

---

## V3 — Predictive Intelligence

**Timeline:** 6 months after V1
**Goal:** Surface risk before it becomes a problem. The system sees it coming.

### How It Works

A monthly risk scoring engine runs per student:

```
Inputs:
  - 3+ months of StudentPattern records (from V2)
  - Historical outcome data from your own schools

        ↓

AI scores each student: Low / Medium / High risk
With confidence level: "High risk — 74% confidence"

        ↓

Predictive insight card fires for teacher and admin
```

### Sample V3 Insight

> **Ahmed is showing early disengagement signals.**
>
> Attendance: declining 4 weeks straight
> Homework: 40% submission rate (was 85% in Term 1)
>
> Similar patterns in past terms led to underperformance in 7 out of 9 cases.
>
> **Recommended:** Schedule a counselor check-in before Week 6.

### Outcome Feedback Loop

```
Insight fired → Teacher acted → Student outcome tracked
                                        ↓
               System learns which interventions work at your school
                                        ↓
                        Future recommendations get sharper
```

### Admin Analytics (End of Term)

> "Early interventions triggered by Kram improved outcomes for 23 students this term."

### What Gets Built

- `RiskScore` model — monthly per student, with confidence and AI reasoning
- Outcome tracker — was the prediction accurate? did the action help?
- Recommendation engine — what worked for similar students before?
- Admin analytics dashboard — intervention impact over time

---

## Full Timeline

```
NOW        V1 (6 wks)          V2 (3 months)        V3 (6 months)
 |              |                    |                    |
 |─── 6 wks ───|──── 3 months ──────|──── 6 months ──────|
 |              |                    |                    |
 Existing       Event triggers       Pattern tracking     Predictive risk
 chat AI        WebSocket push       Weekly digests       Outcome feedback
                Progressive cards    Trend insights       Self-improving
```

---

## Architecture Summary

### Data Flow

```
Raw Data (Attendance, Exams, Submissions)
        ↓
Threshold / Pattern / Risk Engine (Backend)
        ↓
AI generates natural language insight (AiService)
        ↓
Stored in Insights / StudentPattern / RiskScore tables
        ↓
Pushed to Frontend via WebSocket (V1) or polled via REST
        ↓
Rendered as insight cards on Admin / Teacher dashboard
```

### Design Principles

- **Backend decides everything meaningful** — severity, category, risk level, recommended action
- **Frontend decides only presentation** — colors, icons, ordering, read/unread state
- **AI is an interpreter, not a data source** — it reads your real data and translates it into human language
- **No chat required** — the system proactively surfaces what matters without the user needing to ask

---

*Kram — The Academic Atelier: Where administrative clarity meets intuitive design.*
