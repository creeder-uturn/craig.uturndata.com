#!/usr/bin/env python3
"""Serve the website with livereload for automatic rebuilds"""
from livereload import Server
import subprocess


def rebuild():
    """Rebuild the site when changes are detected"""
    print("\n🔄 Changes detected, rebuilding...")
    try:
        subprocess.run(["./build.sh"], check=True)
        print("✅ Rebuild complete\n")
    except subprocess.CalledProcessError:
        print("❌ Build failed\n")


def main():
    server = Server()
    server.watch("presentations/", rebuild)
    server.watch("site/", rebuild)
    server.watch("scripts/", rebuild)
    server.serve(root="public", port=8000, open_url_delay=1)


if __name__ == "__main__":
    main()
