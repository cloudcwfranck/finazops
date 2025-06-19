from difflib import get_close_matches
from pathlib import Path
import subprocess
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="FinOps CLI API")

BASE_DIR = Path(__file__).resolve().parent

class Prompt(BaseModel):
    prompt: str


def _choose_script(text: str) -> Optional[str]:
    text = text.lower()
    if "budget" in text:
        return "check-budgets.sh"
    if "waste" in text:
        return "detect-waste.sh"
    if "saving" in text or "recommend" in text:
        return "generate-recommendations.sh"

    keywords = {
        "budget": "check-budgets.sh",
        "waste": "detect-waste.sh",
        "savings": "generate-recommendations.sh",
    }
    for word in text.split():
        match = get_close_matches(word, keywords.keys(), n=1, cutoff=0.8)
        if match:
            return keywords[match[0]]
    return None


def handle_prompt(text: str) -> dict:
    script = _choose_script(text)
    if not script:
        raise HTTPException(status_code=400, detail="No matching command found")
    script_path = BASE_DIR / script
    result = subprocess.run(["bash", str(script_path)], capture_output=True, text=True)
    return {"return_code": result.returncode, "output": result.stdout}


@app.post("/prompt")
async def prompt_endpoint(body: Prompt):
    return handle_prompt(body.prompt)
