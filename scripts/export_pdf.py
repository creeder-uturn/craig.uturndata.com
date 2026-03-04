#!/usr/bin/env python3
"""Export presentations to PDF using decktape and an in-process HTTP server."""

import concurrent.futures
import http.server
import os
import subprocess
import sys
import threading

PORT = 8765
PRESENTATIONS_DIR = "presentations"
OUTPUT_DIR = "public"


def export_deck(port, deck_name):
    """Export a single deck to PDF."""
    pdf_output = f"{OUTPUT_DIR}/{deck_name}.pdf"
    print(f"Exporting '{deck_name}' to PDF...")
    subprocess.run(
        [
            "npx", "--yes", "decktape", "reveal",
            "--size", "1920x1080",
            f"http://localhost:{port}/{deck_name}/",
            pdf_output,
        ],
        check=True,
    )
    print(f"  -> {pdf_output}")


def main():
    deck_names = []

    if len(sys.argv) > 1:
        deck_names = [sys.argv[1]]
    else:
        # Export all presentations that have been built
        for name in sorted(os.listdir(OUTPUT_DIR)):
            if os.path.isdir(os.path.join(OUTPUT_DIR, name)) and \
               os.path.isfile(os.path.join(OUTPUT_DIR, name, "index.html")) and \
               os.path.isdir(os.path.join(PRESENTATIONS_DIR, name)):
                deck_names.append(name)

    if not deck_names:
        print("No presentations found to export.")
        sys.exit(1)

    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=OUTPUT_DIR, **kwargs)

        def log_message(self, format, *args):
            pass

    server = http.server.HTTPServer(("127.0.0.1", PORT), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()

    try:
        if len(deck_names) == 1:
            export_deck(PORT, deck_names[0])
        else:
            with concurrent.futures.ThreadPoolExecutor() as pool:
                futures = {pool.submit(export_deck, PORT, name): name for name in deck_names}
                for future in concurrent.futures.as_completed(futures):
                    future.result()  # Raise any exceptions
        print(f"\nExported {len(deck_names)} presentation(s) to PDF.")
    finally:
        server.shutdown()


if __name__ == "__main__":
    main()
