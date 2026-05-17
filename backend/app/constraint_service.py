import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def load_resources() -> dict:
    return json.loads((ROOT / "data" / "resources.json").read_text())

def check_resources_for_action(action_type: str, resources: dict) -> bool:
    """
    AGENTIC AI MODULE: Environmental Constraint Checker
    
    This function gives the agent "environmental awareness". Before attempting to 
    execute an action, the agent checks if the required resources (doctors, beds, ECG) 
    are actually available in the current hospital state.
    
    This prevents the agent from hallucinating unachievable plans.
    """
    if action_type == "alert_doctor":
        docs = next((c for c in resources.get("clinicians", []) if c["role"] == "emergency_doctor"), None)
        return docs is not None and docs["available"] > 0
    elif action_type == "allocate_bed":
        beds = resources.get("beds", {})
        return beds.get("resuscitation", 0) > 0 or beds.get("acute", 0) > 0
    elif action_type == "setup_ecg":
        equipment = resources.get("equipment", {})
        return equipment.get("ecg_machines", 0) > 0 or equipment.get("oxygen_ports", 0) > 0
    return True
