# craig.uturndata.com

A personal website hosting technical presentation decks, built with [mkslides](https://github.com/mrfriendly/mkslides) and deployed to GitHub Pages.

**Live Site**: [craig.uturndata.com](https://craig.uturndata.com)

## What's This?

This repository contains markdown-based presentation slides that are converted into interactive HTML presentations using Reveal.js. Write your slides in simple markdown, and they become beautiful, navigable presentations.

## Installation

Install the required dependencies using Homebrew:

```bash
brew install uv go-task
```

> mkslides is run via uvx, so is not needed to be installed independently

## Quick Start

### View Presentations

Visit [craig.uturndata.com](https://craig.uturndata.com) to see all available presentations.

### Create a New Presentation

1. **Generate from template**:
   ```bash
   ./new.sh my-presentation
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
   ./serve.sh my-presentation
   ```
   Opens at http://localhost:8000 with auto-reload

4. **Build and test**:
   ```bash
   ./build.sh
   ```

5. **Publish** (remove draft status):
   Edit `presentations/my-presentation/metadata.yml` and change:
   ```yaml
   draft: false
   ```

6. **Deploy**: Commit and push to main - GitHub Actions deploys automatically

## Project Structure

```
presentations/    # Your presentation sources (markdown)
├── git-101/      # Example presentation
└── ...

template/         # Template for new presentations
site/             # Site-level templates, assets, and static files
legacy/           # Legacy presentations (not mkslides)
public/           # Build output (auto-generated, not in git)
```

## Draft vs Published

New presentations are **drafts** by default (`draft: true` in metadata.yml):
- They build and are accessible by direct URL
- They **don't** appear on the landing page
- Set `draft: false` in metadata.yml when ready to publish

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

External presentations appear on the landing page alongside local presentations, sorted with modern presentations first.

## Customization

Each presentation can have:
- `metadata.yml` - Presentation metadata (title, description, date)
- `mkslides.yml` - Configure theme, transitions, plugins
- `custom.css` - Custom styling
- `assets/` - Images and media files

See the `template/` folder for examples.

### Presentation Metadata

Each presentation should have a `metadata.yml` file for the landing page:

```yaml
title: "Your Presentation Title"
description: "A brief description of what this presentation covers"
date: "January 2024"
```

**Fields:**
- `title`: Human-friendly title (displayed on landing page)
- `description`: Brief summary of the presentation content
- `date`: Month and year (e.g., "January 2024")
- `draft`: Set to `true` to hide from landing page, `false` to publish
- `order`: Optional integer for custom sort order (lower numbers appear first)

**Sorting**: Presentations with an `order` value appear first (ascending by order number), followed by presentations without order (sorted by date). Gaps in order values are acceptable (e.g., 1, 5, 10, 100).

Presentations without metadata will use the folder name as the title and be treated as published (draft: false).

### Configuring Themes

Each presentation can customize its appearance using the `mkslides.yml` configuration file:

```yaml
slides:
  theme: moon                    # Reveal.js presentation theme
  highlight_theme: monokai       # Code syntax highlighting theme
  separator_notes: '^Note:'      # Pattern for speaker notes

revealjs:
  slideNumber: false             # Show/hide slide numbers
  transition: slide              # Transition effect between slides
  hash: true                     # URL hash navigation
  controls: true                 # Show navigation controls
```

**Available Presentation Themes:**

Dark themes:
- `black` - Black background
- `blood` - Dark with blood red accents
- `league` - Gray with blue accents
- `moon` - Dark blue/purple (default in this project)
- `night` - Black with orange accents
- `solarized` - Solarized dark

Light themes:
- `beige` - Beige with brown text
- `serif` - Cappuccino with serif fonts
- `simple` - White, minimal styling
- `sky` - Blue sky gradient
- `white` - White with black text

**Code Highlighting Themes:**
- `monokai` - Dark with bright colors (commonly used)
- `vs2015` - Visual Studio dark
- `github` - GitHub light
- `atom-one-dark` - Atom editor dark
- `zenburn` - Low-contrast dark
- And many others supported by highlight.js

### Using Custom CSS Classes

**For slides**, use the `.slide` HTML comment:

```markdown
<!-- .slide: class="compact" -->
# Slide with Compact Layout

Smaller text and tighter spacing
```

**For images**, use the `.element` HTML comment:

```markdown
![My Image](assets/image.png) <!-- .element: class="fullscreen" -->
```

**Built-in classes:**
- `.compact` - Reduces font sizes and spacing for content-heavy slides
- `.fullscreen` - Makes images larger

Add your own classes in `custom.css` for each presentation.

## How It Works

### Build Process

Running `./build.sh` does the following:

1. **Cleans** the `public/` directory
2. **Builds** each presentation individually with its custom configuration
3. **Shares assets** - Creates a single `mkslides-assets/` folder for Reveal.js resources (saves space)
4. **Renames** `slides.html` to `index.html` for clean URLs
5. **Generates** the landing page index listing all non-draft presentations
6. **Copies** legacy presentations from `legacy/`
7. **Copies** static files from `site/static/` to the site root
8. **Copies** the CNAME file for custom domain support

The `public/` directory is excluded from git - it's regenerated on every build.

### Deployment

The site uses **GitHub Actions** for automatic deployment:

1. You push changes to the `main` branch
2. GitHub Actions runs `./build.sh` automatically
3. The `public/` folder is uploaded as an artifact
4. GitHub Pages deploys the artifact
5. Site goes live at craig.uturndata.com

No manual deployment needed - just push your changes.

**Custom Domain**: The CNAME file is stored at `.github/CNAME` and automatically copied to `public/` during build.

### Technology

- **mkslides** - Converts markdown to Reveal.js presentations
- **Reveal.js** - JavaScript presentation framework
- **GitHub Pages** - Hosting platform

## Development Workflow

Using Task (recommended):

```bash
# List all presentations with status
task list

# Create new presentation
task new my-talk

# Edit slides
$EDITOR presentations/my-talk/slides.md

# Serve entire site with auto-reload
task serve

# Serve specific presentation with auto-reload
task serve my-talk

# Build without serving
task build

# Clean build directory
task clean
```

Or using shell scripts directly:

```bash
# Create new presentation
./new.sh my-talk

# Serve specific presentation
./serve.sh my-talk

# Serve entire website with auto-reload
./serve.sh

# Build only
./build.sh
```

To publish, edit `presentations/my-talk/metadata.yml` and set `draft: false`.
