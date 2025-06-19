import subprocess
from difflib import get_close_matches
from typing import Optional

from finazops.cli import main


def run_natural_language(cmd: str) -> Optional[int]:
    """Execute a script based on a natural language command.

    The function looks for keywords related to budgets, waste or savings and
    dispatches to the corresponding shell script. If no direct keyword match is
    found, a fuzzy match on individual words is attempted.

    Parameters
    ----------
    cmd:
        Free form text describing the desired action.

    Returns
    -------
    Optional[int]
        The return code from the executed script or ``None`` if no match was
        found.
    """

    text = cmd.lower()

    # direct keyword detection
    if "budget" in text:
        script = "check-budgets.sh"
    elif "waste" in text:
        script = "detect-waste.sh"
    elif "saving" in text or "recommend" in text:
        script = "generate-recommendations.sh"
    else:
        # fall back to fuzzy matching
        keywords = {
            "budget": "check-budgets.sh",
            "waste": "detect-waste.sh",
            "savings": "generate-recommendations.sh",
        }
        script = None
        for word in text.split():
            match = get_close_matches(word, keywords.keys(), n=1, cutoff=0.8)
            if match:
                script = keywords[match[0]]
                break

    if script:
        return subprocess.call(["bash", script])
    return None

if __name__ == "__main__":
    main()
