# Cost and Latency Analysis

## Latency Breakdown

The system is designed with deterministic rule engines (rather than large language models) for the core critical path. This ensures ultra-low latency and predictable execution.

1. **Patient Ingestion & Validation**: < 5ms
2. **Triage Engine (Deterministic Rules & Scoring)**: < 10ms
3. **Action Planner & Constraints**: < 15ms
4. **Execution Simulation & Recovery**: ~100ms (includes simulated API call overhead)
5. **Outcome Metrics Generation**: < 5ms

**Total Expected Pipeline Latency (`/api/demo/run-full`)**: ~135ms
**Target SLA**: < 2.0 seconds

## Cost Analysis

- **AI Token Cost**: $0.00. The core decision engine relies on a weighted risk-scoring algorithm instead of LLM generation, ensuring 100% deterministic safety and zero token cost per patient.
- **Compute Cost**: Minimal. Can run on a small EC2 instance (e.g., t3.micro) or locally on hospital edge servers.
- **API Call Cost**: Depends on external hospital systems (e.g., SMS alerts via Twilio), but the core agentic planning is free.
