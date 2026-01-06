#!/bin/bash
set -euo pipefail

# Create a new presentation from template
# Usage: ./new.sh <presentation-name>

if [ -z "${1:-}" ]; then
    echo "Usage: ./new.sh <presentation-name>"
    echo ""
    echo "Example:"
    echo "  ./new.sh my-presentation"
    echo ""
    echo "This will create a new presentation in presentations/my-presentation/"
    echo "from the template/ directory, marked as a draft by default."
    exit 1
fi

PRESENTATION_NAME="$1"
PRESENTATIONS_DIR="presentations"
TEMPLATE_DIR="template"
TARGET_DIR="$PRESENTATIONS_DIR/$PRESENTATION_NAME"

# Validate presentation name (only allow alphanumeric, hyphens, underscores)
if ! [[ "$PRESENTATION_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Presentation name can only contain letters, numbers, hyphens, and underscores"
    exit 1
fi

# Check if presentation already exists
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Presentation '$PRESENTATION_NAME' already exists at $TARGET_DIR"
    exit 1
fi

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

# Create the new presentation
echo "Creating new presentation '$PRESENTATION_NAME'..."
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"

echo "✅ Presentation created at $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $TARGET_DIR/slides.md"
echo "  2. Customize $TARGET_DIR/custom.css (optional)"
echo "  3. Test with: ./serve.sh $PRESENTATION_NAME"
echo "  4. Build with: ./build.sh"
echo "  5. When ready to publish: rm $TARGET_DIR/.draft"
echo ""
echo "📝 Note: New presentations are created as drafts by default"
