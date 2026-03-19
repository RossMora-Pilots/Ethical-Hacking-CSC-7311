import json
from pathlib import Path
from typing import Tuple


def load_config(path: Path) -> dict:
    """Load config from JSON or YAML.

    - If the content parses as JSON, return it.
    - Otherwise, attempt to parse as YAML if PyYAML is available.
    - Raise a helpful error if neither works.
    """
    raw = path.read_text(encoding="utf-8")
    try:
        return json.loads(raw)
    except Exception:
        try:
            import yaml  # type: ignore
        except Exception as e:
            raise RuntimeError(
                f"Unable to parse config '{path}'. Install PyYAML or use JSON (config.json)."
            ) from e
        data = yaml.safe_load(raw)
        if not isinstance(data, dict):
            raise RuntimeError(f"Config '{path}' must be a mapping/object at top level")
        return data


def insert_or_replace_block(text: str, start_marker: str, end_marker: str, body: str) -> Tuple[str, bool]:
    changed = False
    if start_marker in text and end_marker in text:
        pre, rest = text.split(start_marker, 1)
        _, post = rest.split(end_marker, 1)
        new_text = pre + start_marker + "\n" + body.rstrip() + "\n" + end_marker + post
        if new_text != text:
            changed = True
        return new_text, changed
    else:
        new_text = text.rstrip() + "\n\n" + start_marker + "\n" + body.rstrip() + "\n" + end_marker + "\n"
        return new_text, True


def ensure_parent(p: Path):
    p.parent.mkdir(parents=True, exist_ok=True)
