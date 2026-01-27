# AI Integration Guide (Ed-Verse)

This document details the architecture and usage of the AI Assistant module integrated into Ed-Verse.

## 🧠 Architecture Overview

The AI system is designed using a **Multi-Provider Architecture** (Strategy Pattern) on the backend, enhanced with a **Context Retrieval System** (RAG) for personalized responses.

### 1. Backend (`/backend/src/ai`)
*   **Module**: `AiModule`
*   **Service**: `AiService` acts as the "Context" or switchboard. It reads the environment configuration and selects the appropriate provider strategy at runtime.
*   **Context System (`ContextService`)**: 
    *   **Purpose**: Fetches real-time data from the database (Prisma) to give the AI "memory" of the user.
    *   **Data Points**: User Profile, Role (Student/Teacher), Recent Grades, Attendance, and Timetable.
    *   **Privacy**: Data is fetched securely based on the authenticated `userId`.
*   **Controller**: `AiController` (`POST /api/ai/chat`)
    *   Accepts `prompt` and optional `userId`.
    *   Orchestrates the flow: `Request -> Fetch Context -> Prepend to Prompt -> Call AI -> Return Response`.
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

## 🔍 Context Retrieval System (RAG Lite)
The "Context Awareness" feature works as follows:

1.  **User Asks**: "How did I do in my last Math exam?"
2.  **Frontend**: Sends `prompt: "How did I..."` + `userId: 123`.
3.  **Backend (`ContextService`)**:
    *   Queries `Prisma` for Student ID 123.
    *   Retrieves: `Name: Deepak`, `Exam: Math (Score: 95/100, Grade: A)`.
4.  **AI Input**:
    ```text
    Current User Profile:
    - Name: Deepak
    - Role: Student
    - Recent Exams: Math (95/100, Grade A)

    User Question: How did I do in my last Math exam?
    ```
5.  **AI Output**: "You did excellent, Deepak! You scored 95/100 (Grade A) in your Math exam."

---

### 🌟 Advanced Capabilities (New!)

The system is now "Role-Aware" and supports:

*   **👨‍👩‍👧 Parents**:
    *   Can ask: *"How is my child doing?"*
    *   AI sees: Child's Attendance, Exams, and Upcoming Assignments.
    *   Result: Summary report of the child's progress.

*   **📚 Study Helper**:
    *   Can ask: *"What should I study for Biology?"*
    *   AI sees: The **Syllabus** and **Subject List**.
    *   Result: Targeted study advice based on the actual curriculum.

*   **📝 Assignments**:
    *   Can ask: *"What homework do I have due?"*
    *   AI sees: Pending **Assignments** with due dates.
    *   Result: Usage lists upcoming deadlines.

---

## 🚀 How to Extend

### Adding New Data to Context (New Generic System)
The system now uses a **Generic Algorithm**. You no longer need to write complex string formatting code.

1.  Open `backend/src/ai/context.service.ts`.
2.  Locate the `CONTEXT_CONFIG` object.
3.  Add the Prisma Relation you want to include.
    ```typescript
    student: {
      // ... existing
      libraryBooks: true, // Just add this!
      fees: true
    }
    ```
4.  **Done!** The generic algorithm will automatically fetch, format, and inject this data into the AI prompt.

### Adding a New Provider
1.  **Create Provider**: Create a new class in `backend/src/ai/providers/` implementing `AiProvider`.
2.  **Register**: Add to `backend/src/ai/ai.module.ts`.
3.  **Update Switch**: Update `backend/src/ai/ai.service.ts`.

---

## 📱 Client Integration
*   **Access**: Floating Action Button (FAB) on `HomeScreen`.
*   **State**: `LoginProvider` is used to fetch the current user ID for context.
