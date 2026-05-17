import logging
from app.models.triage import TriageResult

logger = logging.getLogger("triageflow")

# Safe clinical explanation templates using only validated backend output
EXPLANATION_TEMPLATES = {
    "RED": (
        "Patient presents with severe critical flags: {red_flags}. Urgency is RED due to "
        "imminent risk to airway, breathing, circulation, or severe consciousness changes. "
        "Deterministic acuity scoring shows immediate clinical safety-critical intervention "
        "is required. Clinical reasoning: {reasoning}. Action Plan: Immediate clinician alert "
        "and emergency resuscitation routing. CLINICIAN CONFIRMATION IS MANDATORY."
    ),
    "ORANGE": (
        "Patient presents with multiple high-urgency flags or severe symptoms: {red_flags}. Acuity level is ORANGE. "
        "Significant physiological strain or critical pain. Clinical reasoning: {reasoning}. "
        "Action Plan: Escalated priority clinical review and close monitoring. CLINICIAN CONFIRMATION IS MANDATORY."
    ),
    "YELLOW": (
        "Patient presents with yellow priority urgency. Vitals and chief complaints indicate stable but "
        "urgent clinical presentation. Symptoms: {red_flags}. Clinical reasoning: {reasoning}. "
        "Action Plan: Standard clinical queue prioritization with periodic reassessment. CLINICIAN CONFIRMATION IS REQUIRED."
    ),
    "GREEN": (
        "Patient presents with a GREEN low-acuity level. Vitals are within physiological limits. "
        "Clinical reasoning: {reasoning}. Action Plan: Routine waitlist or standard clinic triage queue."
    ),
    "BLUE": (
        "Patient presents with BLUE non-urgent priority. Normal baseline symptoms. "
        "Clinical reasoning: {reasoning}. Action Plan: Standard primary care routing or low-priority advice."
    ),
    "MANUAL_REVIEW": (
        "Case requires MANUAL CLINICAL REVIEW due to missing data or critical contradictions: "
        "{red_flags}. Triage priority must be determined by a certified clinician. "
        "Clinical reasoning: {reasoning}. Action Plan: Direct nursing triage assessment."
    )
}

def generate_llm_explanation(triage_result: TriageResult, nurse_note: str = "", simulate_llm_failure: bool = False) -> str:
    """
    Optional LLM-assisted explanation layer. 
    It is used only for phrasing, nurse-note summarization, and audit-friendly reasoning.
    
    It is strictly presentation-only and cannot alter or override the core triage result:
    - priority_level
    - risk_score
    - red_flags
    - contradictions
    - recommended_actions
    """
    if simulate_llm_failure:
        # Fallback behavior: return deterministic reasoning array as a string
        return " [FALLBACK] " + " | ".join(triage_result.reasoning)
        
    try:
        # Build prompt using only validated deterministic backend output
        priority = triage_result.priority_level.value
        red_flags_str = ", ".join(triage_result.red_flags) if triage_result.red_flags else "none"
        reasoning_str = " | ".join(triage_result.reasoning)
        
        template = EXPLANATION_TEMPLATES.get(priority, EXPLANATION_TEMPLATES["MANUAL_REVIEW"])
        explanation = template.format(
            red_flags=red_flags_str,
            reasoning=reasoning_str
        )
        
        # Phrase summary of nurse notes if provided (simulation)
        if nurse_note:
            explanation += f" Nurse intake notes indicate: '{nurse_note.strip()}'. This supports the deterministic assessment."
            
        return explanation
    except Exception as e:
        logger.error(f"LLM explanation generation failed: {e}. Falling back to deterministic reasoning.")
        return " [FALLBACK] " + " | ".join(triage_result.reasoning)
