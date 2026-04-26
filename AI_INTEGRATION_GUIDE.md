# AI Integration Guide (Kram)

This document details the architecture, philosophy, and usage of the AI Assistant module integrated into Kram. Our primary goal is to transform complex raw data, analytics, and statistics into clear, human-readable insights for all users—students, parents, and administrators.

---

## 🌟 Core Philosophy: Data as Narrative

We move beyond "Data Visualization" (showing data) to **"Data Interpretation"** (explaining data). Every piece of complex information in Kram should pass through our AI layer to ensure it is layman-friendly.

*   **Narrative-First UI**: Instead of standalone charts, we use **Insight Cards**. Every metric must be accompanied by a "Why" and a "Next Step."
*   **Progressive Disclosure**: We follow a **Summary → Story → Stats** hierarchy. Simple statuses first, detailed narratives next, and raw data only on demand.
*   **Human-Centric Statistics**: Prioritize directional trends (Growth/Drop) and social benchmarks (Context) over raw mathematical digits.

---

## 🧠 Architecture Overview

The AI system is designed using a **Multi-Provider Architecture** (Strategy Pattern) on the backend, enhanced with a **Smart Context Retrieval System (RAG)** for personalized and data-aware responses.

### 1. Backend (`/backend/src/ai`)
*   **Module**: `AiModule`
*   **Service**: `AiService` acts as the orchestrator. It manages the chat flow and AI provider selection.
*   **Smart Context System (`ContextService` + `SchemaHelper`)**: 
    *   **Purpose**: Gives the AI access to **all system tables** via a dynamically generated schema map and on-demand SQL queries.
    *   **Mechanism**: A 2-Step RAG workflow (Plan -> Query -> Answer).
*   **Agentic Intelligence**: Uses a **Tool-Calling loop** (up to 3 iterations) to investigate anomalies across tables (e.g., matching low attendance with exam performance) before formulating a response.

### 2. Frontend (`/frontend-v2`)
*   **Service**: `AiService` (Dart) communicates with the backend API.
*   **UI Components**:
    *   `AiChatScreen`: Full-screen conversational interface.
    *   `InsightCard`: (NEW) Contextual widgets that summarize dashboard sections in plain English.
    *   **Zero-Config Onboarding**: AI-assisted CSV mapping and school setup.

---

## 🛠 Configuration

To configure the AI provider, update your `backend/.env` file.

### Option 1: Google Gemini (Recommended)
Fast, cost-effective, and optimized for "Narrative" generation.
```bash
AI_PROVIDER=gemini
GEMINI_API_KEY=your_gemini_api_key
# Default Model: gemini-1.5-flash (for speed)
```

### Option 2: Anthropic Claude
Industry-leading for nuanced and empathetic academic reports.
```bash
AI_PROVIDER=claude
ANTHROPIC_API_KEY=your_anthropic_api_key
# Model: claude-3.5-sonnet
```

---

## 🔍 Smart Context System (Advanced RAG)

The system uses a **Text-to-Query** workflow to transform layman questions into precise data insights:

1.  **Planning Phase**: The AI analyzes the user's intent and checks the **Compact Schema Map**.
2.  **Execution Phase**: The backend executes secure, read-only queries based on the AI's plan.
3.  **Synthesis Phase**: The raw data is translated into a **Persona-Driven Narrative**:
    *   **For Parents**: Focused on well-being and clear status updates.
    *   **For Students**: Focused on gamification, badges, and encouragement.

### 🌟 Example Capabilities
*   *"Is my child on track for his final exams?"* (AI analyzes trends across assignments and mocks).
*   *"Who are the students needing attention this week?"* (Teacher view).
*   *"Summarize my academic growth since last term."* (Student view).

---

## 🚀 Scaling & Efficiency

*   **Asynchronous Processing**: We use `EventEmitterModule` to trigger AI analysis on data changes (like a new grade) and cache the resulting narrative for instant dashboard loading.
*   **Hybrid Intelligence**: Deterministic code handles the math (e.g., 90%); GenAI handles the "So What?" (e.g., "This puts you in the top 5%").
*   **Role-Specific Prompts**: Every interaction uses a system prompt tailored to the user's role (Parent, Student, Admin) to ensure appropriate tone and data access.

---

## 📱 Future Roadmap
*   **Phase 1**: Refactor all dashboard controllers to return a `naturalLanguageSummary` alongside raw numbers.
*   **Phase 2**: Implement the "Narrative Agent" that proactively identifies and reports performance anomalies.
*   **Phase 3**: Global Natural Language Search (AI Chat as the primary navigation tool).
