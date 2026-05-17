# Phase Handoff Notes

## Phase 5A / 6A (Member 1) Updates

**To Member 2:**
I have completed the backend endpoints for the **Action Planner** and **Constraints** (Phase 5A), and I needed to test the integration (Phase 6A). 

Because the Phase 2 Flutter UI skeleton was previously deleted, I have temporarily unblocked myself by creating a **minimal demo version** of the Flutter UI in `mobile/lib/main.dart`. This demo simply provides an input form and hits the live backend endpoints (`/api/triage/evaluate` and `/api/actions/plan`) to display the priority and action chain.

**What you need to do next:**
1. Please continue working on Phase 5B (Execution Simulator and Recovery). Your uncommitted files (`executor_service.py`, `recovery_service.py`, etc.) are still kept safely in the working directory and have NOT been committed.
2. Please rebuild the full, hospital-grade Phase 2 Flutter UI so we can integrate properly. My `main.dart` is just a temporary demo placeholder to prove the backend integration works!

## LLM Explanation Layer (Member 1 optional feature)

**To Member 2:**
I have implemented an optional **LLM-assisted explanation layer** in `backend/app/explanation_service.py` to phrase clinical reasoning, summarize your intake nurse notes, and generate audit summaries. 

### What was done:
1. **API response**: The triage response `POST /api/triage/evaluate` (and the `POST /api/demo/run-full` route) now contains an optional `llm_explanation` field (a string) in the JSON response, representing the formatted clinical phrasing.
2. **Safe design**: The LLM runs strictly as a presentation layer. It **cannot** modify or override core fields like `priority_level`, `risk_score`, `red_flags`, `contradictions`, or `recommended_actions`.
3. **Medical Safety Fallback**: If the LLM call fails or times out, it seamlessly falls back to the deterministic `reasoning` array as a string so the client app never crashes or displays empty reasoning.
4. **Offline templating**: To maintain 0ms latency and 100% availability for our demo, it currently uses clinically safe structured templates.

### What we can do if we want to hook up a real LLM:
If we want to show off a real Gemini or OpenAI call in our demo, we can:
- Add a real API client inside `backend/app/explanation_service.py` under `generate_llm_explanation`.
- Store our API keys in the `.env` file and load them.
- All frontend UI code remains exactly the same because the backend handles all LLM API logic internally and always returns the final string in the `llm_explanation` field of `TriageResult`!

## How to Run the Demo
1. Start the backend: `cd backend` then `uvicorn app.main:app --reload`
2. Run the Flutter app: `cd mobile` then `flutter run -d chrome`
3. Enter a chief complaint and click the run button to see the backend connection in action.
