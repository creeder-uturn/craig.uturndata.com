#!/bin/bash
set -euo pipefail

SLIDES_SOURCE="presentations"
OUTPUT_DIR="public"
LEGACY_SOURCE="legacy"

# Step 1: Clean output directory
echo "Cleaning output directory..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Step 2: Build each deck individually with its config
echo "Building presentations with mkslides..."
for deck_dir in "$SLIDES_SOURCE"/*; do
    if [ ! -d "$deck_dir" ]; then
        continue
    fi

    deck_name=$(basename "$deck_dir")
    echo "  Building $deck_name..."

    # Build with config file if it exists
    config_args=()
    if [ -f "$deck_dir/mkslides.yml" ]; then
        config_args=(-f "$deck_dir/mkslides.yml")
    fi

    uvx mkslides build "$deck_dir" -d "$OUTPUT_DIR/$deck_name" "${config_args[@]}"
done

# Step 3: Create shared mkslides-assets directory (copy from first deck)
echo "Setting up shared assets..."
first_deck=$(ls -1 "$OUTPUT_DIR" | head -1)
if [ -d "$OUTPUT_DIR/$first_deck/mkslides-assets" ]; then
    mv "$OUTPUT_DIR/$first_deck/mkslides-assets" "$OUTPUT_DIR/"

    # Update all decks: remove local assets and fix paths in HTML
    for deck_dir in "$OUTPUT_DIR"/*; do
        if [ -d "$deck_dir" ]; then
            # Remove local mkslides-assets if exists
            if [ -d "$deck_dir/mkslides-assets" ]; then
                rm -rf "$deck_dir/mkslides-assets"
            fi

            # Update paths in index.html to point to parent directory
            if [ -f "$deck_dir/index.html" ]; then
                sed -i.bak 's|"mkslides-assets/|"../mkslides-assets/|g' "$deck_dir/index.html"
                rm -f "$deck_dir/index.html.bak"
            fi
        fi
    done
fi

# Step 4: Generate landing page using Jinja2 template
echo "Generating landing page..."
uvx --with pyyaml --from jinja2-cli jinja2 \
    site/index.html.j2 \
    --format=json \
    <(uvx --with pyyaml python scripts/generate_index_data.py "$SLIDES_SOURCE" "$LEGACY_SOURCE") \
    > "$OUTPUT_DIR/index.html"

# Copy site assets (CSS, etc.)
cp site/style.css "$OUTPUT_DIR/"

# Step 5: Copy legacy presentations
if [ -d "$LEGACY_SOURCE" ]; then
    echo "Copying legacy presentations..."
    cp -r "$LEGACY_SOURCE" "$OUTPUT_DIR/"
fi

# Step 6: Copy CNAME for GitHub Pages custom domain
if [ -f ".github/CNAME" ]; then
    echo "Copying CNAME file..."
    cp .github/CNAME "$OUTPUT_DIR/"
fi

echo ""
echo "✅ Build complete!"
echo "📁 Output directory: $OUTPUT_DIR"
echo ""
echo "🎤 Presentations:"
for deck_dir in "$SLIDES_SOURCE"/*; do
    if [ ! -d "$deck_dir" ]; then
        continue
    fi
    deck_name=$(basename "$deck_dir")

    # Check draft status from metadata.yml
    if [ -f "$deck_dir/metadata.yml" ]; then
        if grep -q "^draft: *true" "$deck_dir/metadata.yml"; then
            echo "  - $deck_name (draft)"
        else
            echo "  - $deck_name"
        fi
    else
        echo "  - $deck_name"
    fi
done
echo ""
echo "🌐 Preview locally:"
echo "   python3 -m http.server -d $OUTPUT_DIR"
