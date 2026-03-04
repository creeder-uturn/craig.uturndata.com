# craig.uturndata.com

A personal website hosting technical presentation decks, built with [mkslides](https://github.com/mrfriendly/mkslides) and deployed to GitHub Pages.

**Live Site**: [craig.uturndata.com](https://craig.uturndata.com)

## What's This?

This repository contains markdown-based presentation slides that are converted into interactive HTML presentations using Reveal.js. Write your slides in simple markdown, and they become beautiful, navigable presentations.

## Installation

Install the required dependencies using Homebrew:

```bash
brew install uv go-task nvm

# Install Node.js via nvm
nvm install --lts
nvm alias default lts/*
```

> mkslides is run via uvx and decktape via npx, so neither needs to be installed independently.

## Quick Start

### View Presentations

Visit [craig.uturndata.com](https://craig.uturndata.com) to see all available presentations.

### Create a New Presentation

1. **Generate from template**:
   ```bash
   task new -- my-presentation
   ```

2. **Edit your slides**:
   ```
   presentations/my-presentation/slides.md
   ```
   Use `---` to separate slides:
   ```markdown
   # My First Slide

   ---

   ## My Second Slide

   Content goes here

   Note: This is a speaker note
   ```

3. **Preview locally**:
   ```bash
   task serve -- my-presentation
   ```
   Opens at http://localhost:8000 with auto-reload

4. **Build and test**:
   ```bash
   task build
   ```

5. **Publish** (remove draft status):
   Edit `presentations/my-presentation/metadata.yml` and change:
   ```yaml
   draft: false
   ```

6. **Deploy**: Commit and push to main - GitHub Actions deploys automatically

## Development Workflow

```bash
task                          # List available tasks
task list                     # List all presentations with status
task new -- my-talk           # Create new presentation
task serve                    # Serve entire site with auto-reload
task serve -- my-talk         # Serve specific presentation
task build                    # Build without serving
task pdf                      # Export all presentations to PDF
task pdf -- my-talk           # Export a specific presentation to PDF
task clean                    # Clean build directory
```

Note: Tasks that accept arguments require `--` before the argument.

Or using shell scripts directly:

```bash
./new.sh my-talk              # Create new presentation
./serve.sh my-talk            # Serve specific presentation
./serve.sh                    # Serve entire website
./build.sh                    # Build only
python3 scripts/export_pdf.py # Export all PDFs
```

## Project Structure

```
presentations/    # Your presentation sources (markdown)
├── git-101/      # Example presentation
└── ...

template/         # Template for new presentations
site/             # Site-level templates, assets, and static files
scripts/          # Build and utility scripts
legacy/           # Legacy presentations (not mkslides)
public/           # Build output (auto-generated, not in git)
```

## Draft vs Published

New presentations are **drafts** by default (`draft: true` in metadata.yml):
- They build and are accessible by direct URL
- They **don't** appear on the landing page
- Set `draft: false` in metadata.yml when ready to publish

## PDF Export

PDF versions of presentations are generated using [decktape](https://github.com/astefanutti/decktape), which uses headless Chromium to capture each slide.

```bash
task pdf                    # Export all presentations (parallel)
task pdf -- rocket-the-update  # Export a specific one
```

PDFs are written to `public/<deck-name>.pdf` (e.g., `public/git-101.pdf`).

In CI, PDFs are generated asynchronously after the initial site deploy, then the site is redeployed with PDFs included.

## Static Files

The `site/static/` directory is for files that should be copied to the root of the published site:

```bash
site/static/
├── favicon.ico       # Site favicon
├── robots.txt        # Search engine directives
└── images/           # Static images
    └── logo.png
```

Files in `site/static/` are copied to `public/` during build, accessible at the site root (e.g., `https://craig.uturndata.com/favicon.ico`).

## External Presentations

You can add links to presentations hosted elsewhere by editing `site/external.yml`:

```yaml
- title: "My Conference Talk"
  description: "A talk I gave about cloud architecture"
  date: "March 2023"
  url: "https://youtube.com/watch?v=..."
  badge: "video"  # Optional: custom badge (default: "external")
  order: 1  # Optional: control display order
```

External presentations appear on the landing page alongside local presentations.

## Customization

Each presentation can have:
- `metadata.yml` - Presentation metadata (title, description, date)
- `mkslides.yml` - Configure theme, transitions, plugins
- `custom.css` - Custom styling
- `assets/` - Images and media files

See the `template/` folder for examples.

### Presentation Metadata

```yaml
title: "Your Presentation Title"
description: "A brief description of what this presentation covers"
date: "January 2024"
draft: false    # true to hide from landing page
order: 1        # Optional: lower numbers appear first
```

### Configuring Themes

```yaml
slides:
  theme: moon                    # Reveal.js presentation theme
  highlight_theme: monokai       # Code syntax highlighting theme
  separator_notes: '^Note:'      # Pattern for speaker notes

revealjs:
  slideNumber: false
  transition: slide
  hash: true
  controls: true
```

**Dark themes**: `black`, `blood`, `league`, `moon` (default), `night`, `solarized`

**Light themes**: `beige`, `serif`, `simple`, `sky`, `white`

### Using Custom CSS Classes

**For slides**, use the `.slide` HTML comment:

```markdown
<!-- .slide: class="compact" -->
# Slide with Compact Layout
```

**For images**, use the `.element` HTML comment:

```markdown
![My Image](assets/image.png) <!-- .element: class="fullscreen" -->
```

Add your own classes in `custom.css` for each presentation.

## How It Works

### Build Process

Running `task build` (or `./build.sh`):

1. **Selectively cleans** `public/` (preserves existing PDFs)
2. **Builds** each presentation individually with its custom configuration
3. **Shares assets** - Creates a single `mkslides-assets/` folder for Reveal.js resources
4. **Generates** the landing page listing all non-draft presentations
5. **Copies** legacy presentations from `legacy/`
6. **Copies** static files from `site/static/`
7. **Copies** the CNAME file for custom domain support

### Deployment

The site uses **GitHub Actions** for automatic deployment:

1. **Build** - Runs `build.sh`, uploads site artifact
2. **Deploy** - Site goes live at craig.uturndata.com
3. **Build PDFs** - Downloads build artifact, exports all PDFs via decktape
4. **Deploy with PDFs** - Redeploys site with PDFs included

The site deploys immediately; PDFs follow asynchronously.

### Technology

- **mkslides** - Converts markdown to Reveal.js presentations
- **Reveal.js** - JavaScript presentation framework
- **decktape** - PDF export via headless Chromium
- **Task** - Task runner for development commands
- **GitHub Pages** - Hosting platform
