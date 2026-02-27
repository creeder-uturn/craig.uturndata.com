#!/usr/bin/env python3
"""List presentations in the same order as the website."""
import sys
from pathlib import Path
import yaml

EXTERNAL_FILE = "site/external.yml"


def load_metadata(presentation_dir):
    """Load metadata from metadata.yml."""
    metadata_file = presentation_dir / "metadata.yml"
    if not metadata_file.exists():
        return {}

    with open(metadata_file) as f:
        return yaml.safe_load(f) or {}


def load_external_presentations():
    """Load external presentations from external.yml."""
    external_file = Path(EXTERNAL_FILE)
    if not external_file.exists():
        return []

    with open(external_file) as f:
        external = yaml.safe_load(f) or []

    result = []
    for item in external:
        result.append({
            "title": item.get("title", "Untitled"),
            "date": item.get("date", ""),
            "order": item.get("order"),
            "is_legacy": False,
            "is_external": True,
            "external_badge": item.get("badge", "external"),
            "is_draft": False,
        })

    return result


def get_all_presentations(slides_source, legacy_source):
    """Collect all presentation data including drafts."""
    presentations = []

    # Process mkslides presentations
    slides_path = Path(slides_source)
    if slides_path.exists():
        for deck_dir in sorted(slides_path.iterdir()):
            if not deck_dir.is_dir():
                continue

            metadata = load_metadata(deck_dir)
            is_draft = metadata.get("draft", False)

            presentations.append({
                "name": deck_dir.name,
                "title": metadata.get("title", deck_dir.name),
                "date": metadata.get("date", ""),
                "order": metadata.get("order"),
                "is_legacy": False,
                "is_external": False,
                "is_draft": is_draft,
            })

    # Process legacy presentations
    legacy_path = Path(legacy_source)
    if legacy_path.exists():
        for legacy_dir in sorted(legacy_path.iterdir()):
            if not legacy_dir.is_dir():
                continue

            metadata = load_metadata(legacy_dir)
            is_draft = metadata.get("draft", False)

            presentations.append({
                "name": legacy_dir.name,
                "title": metadata.get("title", legacy_dir.name),
                "date": metadata.get("date", ""),
                "order": metadata.get("order"),
                "is_legacy": True,
                "is_external": False,
                "is_draft": is_draft,
            })

    # Process external presentations
    presentations.extend(load_external_presentations())

    return presentations


def sort_presentations(presentations):
    """Sort presentations using the same logic as the website."""
    return sorted(presentations, key=lambda p: (
        p["order"] is None,  # False (has order) before True (no order)
        p["order"] if p["order"] is not None else 0,  # Ascending order value
        p["is_legacy"],      # False (modern/external) before True (legacy)
        p["is_external"],    # False (modern) before True (external)
        p["date"] == "",     # False (has date) before True (no date)
        p["date"],           # Alphabetical date sort (newer last if string dates)
        p["title"]           # Alphabetical title sort
    ))


def main():
    slides_source = sys.argv[1] if len(sys.argv) > 1 else "presentations"
    legacy_source = sys.argv[2] if len(sys.argv) > 2 else "legacy"

    all_presentations = get_all_presentations(slides_source, legacy_source)

    # Separate published and drafts
    published = [p for p in all_presentations if not p["is_draft"]]
    drafts = [p for p in all_presentations if p["is_draft"]]

    # Sort both lists
    published = sort_presentations(published)
    drafts = sort_presentations(drafts)

    # Print published presentations
    print("\033[36mPresentations:\033[0m")
    if published:
        for p in published:
            if p["is_external"]:
                badge = p.get("external_badge", "external")
                print(f"  - \033[1m{p['title']}\033[0m ({badge})")
            else:
                name = p.get("name", p["title"])
                print(f"  - \033[1m{name}\033[0m")
    else:
        print("  (none)")

    # Print drafts
    if drafts:
        print()
        print("\033[36mDrafts:\033[0m")
        for p in drafts:
            name = p.get("name", p["title"])
            print(f"  - {name}")


if __name__ == "__main__":
    main()
