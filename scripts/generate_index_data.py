#!/usr/bin/env python3
"""Generate JSON data for the landing page index."""
import json
import sys
from pathlib import Path
import yaml

def load_metadata(presentation_dir):
    """Load metadata from metadata.yml."""
    metadata_file = presentation_dir / "metadata.yml"
    if not metadata_file.exists():
        return {}

    with open(metadata_file) as f:
        return yaml.safe_load(f) or {}

def get_presentations(slides_source, legacy_source):
    """Collect presentation data from presentations and legacy folders."""
    presentations = []

    # Process mkslides presentations
    slides_path = Path(slides_source)
    if slides_path.exists():
        for deck_dir in sorted(slides_path.iterdir()):
            if not deck_dir.is_dir():
                continue

            metadata = load_metadata(deck_dir)

            # Skip drafts
            if metadata.get("draft", False):
                continue

            presentations.append({
                "path": deck_dir.name,
                "title": metadata.get("title", deck_dir.name),
                "description": metadata.get("description", ""),
                "date": metadata.get("date", ""),
                "is_legacy": False
            })

    # Process legacy presentations
    legacy_path = Path(legacy_source)
    if legacy_path.exists():
        for legacy_dir in sorted(legacy_path.iterdir()):
            if not legacy_dir.is_dir():
                continue

            metadata = load_metadata(legacy_dir)

            # Skip drafts
            if metadata.get("draft", False):
                continue

            presentations.append({
                "path": f"legacy/{legacy_dir.name}",
                "title": metadata.get("title", legacy_dir.name),
                "description": metadata.get("description", ""),
                "date": metadata.get("date", ""),
                "is_legacy": True
            })

    # Sort: modern presentations first, then legacy (by is_legacy)
    # Within each: dated first, then by date, then by title
    presentations.sort(key=lambda p: (
        p["is_legacy"],      # False (modern) before True (legacy)
        p["date"] == "",     # False (has date) before True (no date)
        p["date"],           # Alphabetical date sort
        p["title"]           # Alphabetical title sort
    ))

    return presentations

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: generate_index_data.py <slides_source> <legacy_source>", file=sys.stderr)
        sys.exit(1)

    slides_source = sys.argv[1]
    legacy_source = sys.argv[2]

    data = {
        "presentations": get_presentations(slides_source, legacy_source)
    }

    print(json.dumps(data, indent=2))
