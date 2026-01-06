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

# Step 4: Generate landing page index
echo "Generating landing page..."
cat > "$OUTPUT_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Presentations - Craig Reeder</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 { color: #333; }
        ul { list-style: none; padding: 0; }
        li { margin: 15px 0; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Presentations</h1>
    <ul>
EOF

for deck_dir in "$SLIDES_SOURCE"/*; do
    if [ ! -d "$deck_dir" ]; then
        continue
    fi
    deck_name=$(basename "$deck_dir")

    # Skip drafts (presentations with a .draft file)
    if [ -f "$deck_dir/.draft" ]; then
        continue
    fi

    echo "        <li><a href=\"$deck_name/\">$deck_name</a></li>" >> "$OUTPUT_DIR/index.html"
done

# Add legacy presentations to landing page if they exist
if [ -d "$LEGACY_SOURCE" ]; then
    for legacy_dir in "$LEGACY_SOURCE"/*; do
        if [ ! -d "$legacy_dir" ]; then
            continue
        fi
        legacy_name=$(basename "$legacy_dir")
        echo "        <li><a href=\"legacy/$legacy_name/\">$legacy_name</a> <span style=\"color: #999; font-size: 0.9em;\">(legacy)</span></li>" >> "$OUTPUT_DIR/index.html"
    done
fi

cat >> "$OUTPUT_DIR/index.html" << 'EOF'
    </ul>
    <footer>
        <p style="font-size: small; color: #666; margin-top: 3em;">
            Built with <a href="https://martenbe.github.io/mkslides/" target="_blank">MkSlides</a>
        </p>
    </footer>
</body>
</html>
EOF

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
echo "🎤 Presentations built:"
for deck_dir in "$SLIDES_SOURCE"/*; do
    if [ ! -d "$deck_dir" ]; then
        continue
    fi
    deck_name=$(basename "$deck_dir")
    if [ -f "$deck_dir/.draft" ]; then
        echo "  - $deck_name (draft)"
    else
        echo "  - $deck_name"
    fi
done
echo ""
echo "🌐 Preview locally:"
echo "   python3 -m http.server -d $OUTPUT_DIR"
