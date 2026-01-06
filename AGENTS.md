# AGENTS.md

This file provides guidance to AI Assistants when working with code in this repository.

## Project Overview

This is a GitHub Pages site (craig.uturndata.com) hosting technical presentation decks. Presentations are created using mkslides (a Reveal.js-based presentation generator) that converts markdown files into interactive HTML presentations.

## Build and Development Commands

### Building all presentations
```bash
./build.sh
```
This script:
- Processes all presentation decks in the `presentations/` directory
- Generates an index.html landing page listing all non-draft presentations
- Outputs to `public/` directory
- Renames `slides.html` to `index.html` for clean URLs
- Copies legacy presentations from `legacy/` to `public/legacy/`
- Copies CNAME from `.github/` to `public/` for GitHub Pages

### Local development server (single deck)
```bash
./serve.sh <deck-name>
```
Starts a development server with **auto-reload** for a specific deck at http://localhost:8000

Examples:
```bash
./serve.sh example     # Serve the example presentation
./serve.sh git-101     # Serve the git-101 presentation
```

This serves one deck at a time with:
- Live auto-reload when you edit slides.md, custom.css, or assets
- For actively developing a presentation

### Creating a new presentation

Use the `new.sh` script to create a presentation from the template:

```bash
./new.sh my-presentation
```

This creates a new presentation with:
- Basic slide structure in `slides.md`
- Standard configuration in `mkslides.yml`
- Custom CSS template
- `.draft` file (marked as draft by default)

Then:
1. Edit `presentations/my-presentation/slides.md` with your content
2. Customize `custom.css` if needed
3. Test with: `./serve.sh my-presentation`
4. Build with: `./build.sh`
5. When ready to publish: `rm presentations/my-presentation/.draft`
6. Commit and push - GitHub Actions will deploy automatically

**Manual creation (alternative):**
If you prefer to create manually, copy from the template:
```bash
cp -r template/ presentations/my-presentation/
```

### Draft presentations

Mark a presentation as a draft to build it but exclude it from the landing page by setting `draft: true` in metadata.yml:

```yaml
title: "My Presentation"
description: "Work in progress"
date: "January 2024"
draft: true  # Set to false to publish
```

**Draft presentations:**
- ✅ Are still built and included in `public/`
- ✅ Are accessible by direct URL (e.g., `/my-presentation/`)
- ✅ Work with `./serve.sh my-presentation`
- ❌ Do NOT appear on the landing page index

**To publish**: Change `draft: false` in metadata.yml

## Project Architecture

### Folder Structure

```
presentations/             # Source presentations (committed to git)
  ├── example/             # Individual presentation
  │   ├── slides.md        # Markdown slides
  │   ├── metadata.yml     # Presentation metadata
  │   ├── mkslides.yml     # Configuration
  │   ├── custom.css       # Custom styling
  │   ├── .draft           # Optional: marks as draft
  │   └── assets/          # Optional images/media
  └── git-101/
      └── ...

template/                  # Template for new presentations
  ├── slides.md            # Basic slide structure
  ├── metadata.yml         # Metadata template (draft: true by default)
  ├── mkslides.yml         # Standard configuration
  └── custom.css           # Default styles

site/                      # Site-level templates and assets
  ├── index.html.j2        # Landing page Jinja2 template
  └── style.css            # Landing page styles (dark mode)

scripts/                   # Build scripts
  └── generate_index_data.py  # Collects metadata for landing page

public/                    # Build output (gitignored, not committed)
  ├── index.html           # Landing page
  ├── example/
  │   └── index.html       # Renamed from slides.html
  ├── git-101/
  │   └── index.html
  ├── legacy/              # Copied from legacy/
  └── mkslides-assets/     # Shared Reveal.js assets

legacy/                    # Legacy presentations (not mkslides)
  ├── terraform/           # "big" presentation framework
  └── RocketCubed/         # Custom Reveal.js

.github/
  ├── CNAME                # GitHub Pages custom domain
  └── workflows/
      └── deploy.yml       # Deployment workflow

site/                      # Site-level templates and assets
  ├── index.html.j2        # Landing page template
  └── style.css            # Landing page styles (dark mode)

scripts/
  ├── generate_index_data.py  # Collects metadata for landing page
  └── present-w-big.sh     # Legacy script for "big" presentations
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
```

**Purpose**: This metadata is used to generate the landing page with rich presentation information.

**Behavior**:
- If `metadata.yml` is missing, the folder name is used as the title and presentation is treated as published
- Empty or missing fields are handled gracefully
- Draft presentations (`draft: true`) are excluded from the landing page but still built
- Legacy presentations in `legacy/` can also have metadata.yml for custom titles and descriptions

### Markdown Format (slides.md)

- **Slide separator**: `---` (triple dash on its own line)
- **Speaker notes**: Lines starting with `Note:` (configurable via `separator_notes` in mkslides.yml)
- Supports standard markdown formatting, images, code blocks
- Supports Reveal.js-specific features like fragment animations

Example:
```markdown
# Title Slide

---

## Content Slide

Some content here

Note: This is a speaker note that won't appear on the slide

---
```

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

## Technology Stack

- **mkslides**: Python-based tool (run via uvx) that generates Reveal.js presentations from markdown
- **Reveal.js**: JavaScript presentation framework (outputs are standalone HTML files)
- **GitHub Pages**: Hosting platform (deployed via GitHub Actions artifacts)

## Build Process Workflow

The build.sh script performs these steps:

1. **Clean**: Remove existing `public/` directory
2. **Build each deck**: Build presentations from `presentations/` individually with their configs
   - mkslides handles per-deck: custom mkslides.yml, assets/ folders, custom.css files
   - Creates mkslides-assets/ in each deck's output
3. **Share assets**: Move first deck's mkslides-assets/ to `public/` root, remove duplicates from other decks
4. **Fix paths**: Update all deck HTML files to reference shared `../mkslides-assets/`
5. **Rename**: Convert `slides.html` → `index.html` for clean URLs
6. **Generate landing page**: Uses Jinja2 templating
   - Python script (`scripts/generate_index_data.py`) collects metadata from all presentations
   - Reads `metadata.yml` from each presentation directory
   - Generates JSON data with presentation info (title, description, date, path)
   - Jinja2 renders `site/index.html.j2` with this data
   - Copies `site/style.css` to output directory
   - Output: `public/index.html` with styled presentation cards
7. **Copy legacy**: Copy legacy presentations to public/legacy/
8. **Copy CNAME**: Copy .github/CNAME to public/

### Landing Page Generation Details

**Script**: `scripts/generate_index_data.py`
- Reads `metadata.yml` from each presentation directory (including legacy/)
- Collects presentation information (title, description, date, draft status)
- Excludes draft presentations (`draft: true` in metadata.yml)
- Includes legacy presentations with special badge
- Sorts: modern first, then legacy; within each group by date (newest first), then alphabetically

**Template**: `site/index.html.j2`
- Jinja2 template for landing page HTML structure
- References `style.css` for styling

**Stylesheet**: `site/style.css`
- Dark mode color scheme using CSS variables
- Responsive card layout
- Hover effects and transitions
- Easy to customize via CSS variables in `:root`

**Dependencies**:
- `jinja2-cli` (via uvx, no permanent install)
- `pyyaml` (via uvx, for reading YAML metadata)

## Deployment

**Method**: Modern GitHub Actions artifact-based deployment

**Workflow**: On push to main branch:
1. GitHub Actions runs `build.sh`
2. Uploads `public/` as artifact
3. Deploys artifact to GitHub Pages
4. Site live at craig.uturndata.com

**Key Points**:
- Build output (`public/`) is NOT committed to git (it's in .gitignore)
- No gh-pages branch needed
- Automatic deployment on push to main
- Manual trigger available via workflow_dispatch in GitHub Actions UI

**GitHub Pages Settings**:
- Source: "GitHub Actions" (not branch-based)
- CNAME handled automatically by build script

## Legacy Presentations

- **terraform/**: Uses "big" presentation framework (HTML-based)
- **RocketCubed/**: Custom Reveal.js implementation
- Both are copied as-is to `public/legacy/` during build
- Not converted to mkslides format

## Git Workflow

- Main branch: `main`
- CNAME configured for custom domain: craig.uturndata.com
- Build artifacts (`public/`) are gitignored
