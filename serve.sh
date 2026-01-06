#!/bin/bash

# Serve a specific slide deck with auto-reload
# Usage: ./serve.sh <deck-name>
# Example: ./serve.sh deputy

if [ -z "$1" ]; then
    echo "Usage: ./serve.sh <deck-name>"
    echo ""
    echo "Available decks:"
    ls -1 presentations/ | sed 's/^/  - /'
    exit 1
fi

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
