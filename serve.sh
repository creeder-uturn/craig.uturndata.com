#!/bin/bash

# Serve the entire website or a specific slide deck with auto-reload
# Usage: ./serve.sh [deck-name]
# Examples:
#   ./serve.sh          # Serve entire website
#   ./serve.sh deputy   # Serve specific presentation

if [ -z "$1" ]; then
    # No argument provided - serve entire website with livereload
    echo "Starting development server for entire website with auto-reload..."
    echo "Server will be available at http://localhost:8000"
    echo "Watching for changes in presentations/, site/, and scripts/"
    echo ""

    # Initial build
    ./build.sh

    # Start livereload server
    uvx --with livereload python scripts/serve_with_livereload.py
else
    # Argument provided - serve specific presentation
    DECK_NAME="$1"
    DECK_PATH="presentations/$DECK_NAME"

    if [ ! -d "$DECK_PATH" ]; then
        echo "Error: Deck '$DECK_NAME' not found in presentations/"
        echo ""
        echo "Available decks:"
        ls -1 presentations/ | sed 's/^/  - /'
        exit 1
    fi

    # Build with config file if it exists
    CONFIG_ARGS=()
    if [ -f "$DECK_PATH/mkslides.yml" ]; then
        CONFIG_ARGS=(-f "$DECK_PATH/mkslides.yml")
        echo "Loading config from $DECK_PATH/mkslides.yml"
    fi

    echo "Starting development server for '$DECK_NAME'..."
    echo "Server will auto-reload on file changes"
    echo ""

    uvx mkslides serve "$DECK_PATH" "${CONFIG_ARGS[@]}"
fi
