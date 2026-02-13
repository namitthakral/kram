# AI Integration Guide (Kram)

This document details the architecture and usage of the AI Assistant module integrated into Kram.

## 🧠 Architecture Overview

The AI system is designed using a **Multi-Provider Architecture** (Strategy Pattern) on the backend, enhanced with a **Smart Context Retrieval System (RAG)** for personalized and data-aware responses.

### 1. Backend (`/backend/src/ai`)
*   **Module**: `AiModule`
*   **Service**: `AiService` acts as the orchestrator. It manages the chat flow and AI provider selection.
*   **Smart Context System (`ContextService` + `SchemaHelper`)**: 
    *   **Purpose**: Gives the AI access to **all system tables** via a dynamically generated schema map and on-demand SQL queries.
    *   **Mechanism**: A 2-Step RAG workflow (Plan -> Query -> Answer).
    *   **Data Points**: Access to the entire database schema (read-only) tailored to the user's needs.
*   **Providers**:
    *   `GeminiProvider`: Uses `@google/generative-ai` (Default, Model: **gemini-2.5-flash-lite**).
    *   `OpenAIProvider`: Uses `openai`.
    *   `ClaudeProvider`: Uses `@anthropic-ai/sdk`.

### 2. Frontend (`/frontend/lib/modules/ai_assistant`)
*   **Service**: `AiService` (Dart) communicates with the backend API.
    *   **Identity**: Automatically attaches the current `userId` (from `LoginProvider`) to every request to enable context features.
*   **UI**: `AiChatScreen` provides a modern, chat-based interface with Markdown rendering support.

---

## 🛠 Configuration

To configure the AI provider, update your `backend/.env` file.

### Option 1: Google Gemini (Default & Recommended)
Fast, cost-effective, and multimodal.
```bash
AI_PROVIDER=gemini
GEMINI_API_KEY=your_gemini_api_key
# Model: gemini-2.5-flash-lite
```

### Option 2: OpenAI (ChatGPT)
Industry standard, highly capable.
```bash
AI_PROVIDER=openai
OPENAI_API_KEY=your_openai_api_key
```

### Option 3: Anthropic Claude
Great for nuanced and safe responses.
```bash
AI_PROVIDER=claude
ANTHROPIC_API_KEY=your_anthropic_api_key
```

---

## 🔍 Smart Context System (Advanced RAG)
The system uses a **Text-to-Query** workflow to access data dynamically:

1.  **Planning Phase**: 
    - The AI receives the user's question along with a **Compact Schema Map** of the database.
    - It analyzes if it needs specific data to answer the question.
    - **Outcome**: It either generates a SQL `SELECT` query or decides to answer directly.

2.  **Execution Phase**:
    - If a query is generated, the backend executes it securely (Read-Only).
    - Example Query: `SELECT count(*) FROM students WHERE course_id = 5`

3.  **Answer Phase**:
    - The retrieved data is fed back to the AI.
    - The AI generates the final, natural language response for the user.

### 🌟 Context Capabilities

The AI is now **"System-Aware"** and supports complex questions like:
*   *"How many students are enrolled in B.Sc Computer Science?"*
*   *"What is the class average for the Data Structures exam?"*
*   *"List all pending assignments for my child."* (Parent View)
*   *"Show me the syllabus for the next Math module."*

---

## 🚀 How to Extend

### 1. Adding New Data Support
You generally **don't need to do anything**! 
Because the system reads the `prisma/schema.prisma` file dynamically via `SchemaHelper`, any new tables or fields you add to the database are automatically visible to the AI.

### 2. Adding a New Provider
1.  **Create Provider**: Create a new class in `backend/src/ai/providers/` implementing `AiProvider`.
2.  **Register**: Add (and export) the provider in `backend/src/ai/ai.module.ts`.
3.  **Update Switch**: Update the provider selection logic in `backend/src/ai/ai.service.ts`.

---

## 📱 Client Integration
*   **Access**: Floating Action Button (FAB) on `HomeScreen`.
*   **State**: `LoginProvider` is used to fetch the current user ID for context.
