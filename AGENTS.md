# AGENTS.md

This file provides guidance to AI Assistants when working with code in this repository.

## Project Overview

This is a GitHub Pages site (craig.uturndata.com) hosting technical presentation decks. Presentations are created using mkslides (a Reveal.js-based presentation generator) that converts markdown files into interactive HTML presentations. PDF versions are generated asynchronously via decktape.

## Build and Development Commands

Development commands use [Task](https://taskfile.dev/) as a task runner. All tasks are defined in `Taskfile.yml`.

### Task commands

```bash
task                        # List available tasks
task build                  # Build the entire website
task serve                  # Serve entire website with auto-reload
task serve -- git-101       # Serve specific presentation with auto-reload
task new -- my-talk         # Create a new presentation from template
task pdf                    # Export all presentations to PDF
task pdf -- git-101         # Export a specific presentation to PDF
task list                   # List all presentations
task clean                  # Clean the output directory
```

Note: Tasks that accept arguments require `--` before the argument (Taskfile convention for `CLI_ARGS`).

### Direct script usage

Scripts can also be run directly without Task:

```bash
./build.sh                              # Build the site
./serve.sh git-101                      # Serve a specific presentation
./new.sh my-talk                        # Create a new presentation
python3 scripts/export_pdf.py           # Export all PDFs
python3 scripts/export_pdf.py git-101   # Export a specific PDF
```

### PDF Export

PDF export uses [decktape](https://github.com/astefanutti/decktape) (Puppeteer/headless Chromium) to capture Reveal.js presentations as PDFs.

- `scripts/export_pdf.py` starts an in-process HTTP server, then runs decktape against each deck
- PDFs are written to `public/<deck-name>.pdf` (e.g., `public/git-101.pdf`)
- When exporting all decks, exports run in parallel via `ThreadPoolExecutor`
- Requires Node.js 20+ (for Puppeteer compatibility)
- The site must be built first (`public/` must contain the HTML decks)

### Creating a new presentation

```bash
task new -- my-presentation
```

This creates a new presentation with:
- Basic slide structure in `slides.md`
- Standard configuration in `mkslides.yml`
- Custom CSS template
- Marked as draft by default (`draft: true` in metadata.yml)

Then:
1. Edit `presentations/my-presentation/slides.md` with your content
2. Customize `custom.css` if needed
3. Test with: `task serve -- my-presentation`
4. Build with: `task build`
5. When ready to publish: set `draft: false` in `metadata.yml`
6. Commit and push - GitHub Actions will deploy automatically

### Draft presentations

Mark a presentation as a draft to build it but exclude it from the landing page by setting `draft: true` in metadata.yml:

```yaml
title: "My Presentation"
description: "Work in progress"
date: "January 2024"
draft: true  # Set to false to publish
```

**Draft presentations:**
- Are still built and included in `public/`
- Are accessible by direct URL (e.g., `/my-presentation/`)
- Work with `task serve -- my-presentation`
- Do NOT appear on the landing page index

**To publish**: Change `draft: false` in metadata.yml

### External presentations

Add links to presentations hosted elsewhere (YouTube, SlideShare, etc.) by editing `site/external.yml`:

```yaml
- title: "Talk at CloudConf 2023"
  description: "Discussing serverless architecture patterns"
  date: "March 2023"
  url: "https://youtube.com/watch?v=..."
  badge: "video"  # Optional: custom badge text (default: "external")
  order: 1  # Optional: control display order
```

### Custom Sort Order

Use the `order` field to control the display order of presentations:

```yaml
# In metadata.yml or external.yml
order: 5  # Lower numbers appear first
```

- Presentations with an `order` value sort first (ascending)
- Presentations without `order` sort after those with order
- Works for all presentation types (local, external, legacy)

## Project Architecture

### Folder Structure

```
presentations/             # Source presentations (committed to git)
  ├── git-101/             # Individual presentation
  │   ├── slides.md        # Markdown slides
  │   ├── metadata.yml     # Presentation metadata
  │   ├── mkslides.yml     # Configuration
  │   ├── custom.css       # Custom styling
  │   └── assets/          # Optional images/media
  └── ...

template/                  # Template for new presentations
  ├── slides.md
  ├── metadata.yml         # draft: true by default
  ├── mkslides.yml
  └── custom.css

site/                      # Site-level templates and configuration
  ├── index.html.j2        # Landing page Jinja2 template
  ├── external.yml         # External presentation links
  └── static/              # Static files (copied to public/ root)
      └── style.css        # Landing page styles (dark mode)

scripts/                   # Build and utility scripts
  ├── generate_index_data.py    # Collects metadata for landing page
  ├── export_pdf.py             # PDF export via decktape
  ├── list_presentations.py     # List all presentations
  ├── serve_with_livereload.py  # Dev server with auto-reload
  └── present-w-big.sh          # Legacy script for "big" presentations

public/                    # Build output (gitignored, not committed)
  ├── index.html           # Landing page
  ├── git-101/
  │   └── index.html
  ├── git-101.pdf          # PDF version (generated by task pdf)
  ├── legacy/              # Copied from legacy/
  └── mkslides-assets/     # Shared Reveal.js assets

legacy/                    # Legacy presentations (not mkslides)
  ├── terraform/           # "big" presentation framework
  └── RocketCubed/         # Custom Reveal.js

.github/
  ├── CNAME                # GitHub Pages custom domain
  └── workflows/
      └── deploy.yml       # Deployment workflow
```

### Presentation Deck Structure

Each presentation in `presentations/` follows this pattern:
```
<deck-name>/
├── slides.md           # Markdown source with slides separated by ---
├── metadata.yml        # Presentation metadata (title, description, date, draft)
├── mkslides.yml        # Configuration (theme, plugins, reveal.js options)
├── custom.css          # Custom styling
└── assets/             # Optional: images and media
```

### Presentation Metadata

Each presentation should have a `metadata.yml` file containing:

```yaml
title: "Human-Friendly Presentation Title"
description: "Brief description of the presentation content"
date: "Month YYYY"  # e.g., "January 2024"
draft: false  # true to hide from landing page, false to publish
order: 1  # Optional: integer for custom sort order (lower numbers first)
```

### Markdown Format (slides.md)

- **Slide separator**: `---` (triple dash on its own line)
- **Speaker notes**: Lines starting with `Note:` (configurable via `separator_notes` in mkslides.yml)
- Supports standard markdown formatting, images, code blocks
- Supports Reveal.js-specific features like fragment animations

### Configuration (mkslides.yml)

Standard configuration pattern used across decks:
```yaml
slides:
  theme: moon                    # Reveal.js theme
  highlight_theme: monokai       # Code syntax highlighting theme
  separator_notes: '^Note:'      # Pattern to identify speaker notes

revealjs:
  slideNumber: false             # Show/hide slide numbers
  transition: slide              # Transition effect
  hash: true                     # URL hash navigation
  controls: true                 # Show navigation controls

plugins:
  - extra_css:
      - custom.css               # Additional CSS files
```

### Available Themes

**Reveal.js Presentation Themes** (for `theme:` field):

Dark Themes:
- `black` - Black background
- `blood` - Dark background with blood red accents
- `league` - Gray background with blue accents
- `moon` - Dark blue/purple (default in this project)
- `night` - Black background with orange accents
- `solarized` - Solarized dark color scheme

Light Themes:
- `beige` - Beige background with brown text
- `serif` - Cappuccino background with serif fonts
- `simple` - White background, minimal styling
- `sky` - Blue sky gradient background
- `white` - White background with black text

**Code Syntax Highlighting Themes** (for `highlight_theme:` field):
- `monokai` - Dark theme with bright colors (commonly used in this project)
- `vs2015` - Visual Studio 2015 dark theme
- `github` - GitHub light theme
- `atom-one-dark` - Atom editor dark theme
- `zenburn` - Low-contrast dark theme
- And many others supported by highlight.js

## Technology Stack

- **mkslides**: Python-based tool (run via uvx) that generates Reveal.js presentations from markdown
- **Reveal.js**: JavaScript presentation framework (outputs are standalone HTML files)
- **decktape**: PDF exporter using Puppeteer/headless Chromium (run via npx)
- **Task**: Task runner for development commands
- **GitHub Pages**: Hosting platform (deployed via GitHub Actions artifacts)

## Build Process

The `build.sh` script performs these steps:

1. **Selective clean**: Remove build artifacts from `public/` while preserving PDF files
2. **Build each deck**: Run mkslides for each presentation in `presentations/`
3. **Share assets**: Move mkslides-assets/ to `public/` root, update HTML paths to `../mkslides-assets/`
4. **Generate landing page**: Python script collects metadata, Jinja2 renders `site/index.html.j2`
5. **Copy legacy**: Copy legacy presentations to `public/legacy/`
6. **Copy static files**: Copy `site/static/` contents to `public/`
7. **Copy CNAME**: Copy `.github/CNAME` to `public/`

### Landing Page Generation

**Script**: `scripts/generate_index_data.py`
- Reads `metadata.yml` from each presentation directory (including legacy/)
- Reads `site/external.yml` for external presentation links
- Excludes draft presentations (`draft: true` in metadata.yml)
- Includes legacy presentations with "legacy format" badge
- Includes external presentations with custom badges
- Sorts: by `order` field (ascending), then by type, then by date (newest first)

**Template**: `site/index.html.j2`
- Each presentation card shows: title link, date, Print link (`?print-pdf`), PDF link (`<deck>.pdf`)
- External presentations open in new tabs with custom badges

## Deployment

**Method**: GitHub Actions artifact-based deployment with async PDF generation

**Workflow** (`.github/workflows/deploy.yml`): On push to main:

1. **build**: Build site with `build.sh`, upload as pages artifact + build artifact
2. **deploy**: Deploy to GitHub Pages (site goes live immediately)
3. **build-pdfs**: Download build artifact, run `export_pdf.py`, upload as pages artifact
4. **deploy-with-pdfs**: Redeploy with PDFs included

The site deploys fast, and PDFs follow asynchronously once generated.

**Key Points**:
- Build output (`public/`) is NOT committed to git
- No gh-pages branch needed
- Automatic deployment on push to main
- Manual trigger available via workflow_dispatch

## Legacy Presentations

- **terraform/**: Uses "big" presentation framework (HTML-based)
- **RocketCubed/**: Custom Reveal.js implementation
- Both are copied as-is to `public/legacy/` during build
- Not converted to mkslides format

## Git Workflow

- Main branch: `main`
- CNAME configured for custom domain: craig.uturndata.com
- Build artifacts (`public/`) are gitignored
