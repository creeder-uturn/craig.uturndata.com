# craig.uturndata.com

A personal website hosting technical presentation decks, built with [mkslides](https://github.com/mrfriendly/mkslides) and deployed to GitHub Pages.

**Live Site**: [craig.uturndata.com](https://craig.uturndata.com)

## What's This?

This repository contains markdown-based presentation slides that are converted into interactive HTML presentations using Reveal.js. Write your slides in simple markdown, and they become beautiful, navigable presentations.

## Installation

Install the required dependencies using Homebrew:

```bash
brew install uv
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
   ```bash
   rm presentations/my-presentation/.draft
   ```

6. **Deploy**: Commit and push to main - GitHub Actions deploys automatically

## Project Structure

```
presentations/    # Your presentation sources (markdown)
├── git-101/      # Example presentation
└── ...

template/         # Template for new presentations
legacy/           # Legacy presentations (not mkslides)
public/           # Build output (auto-generated, not in git)
```

## Draft vs Published

New presentations are **drafts** by default:
- They build and are accessible by direct URL
- They **don't** appear on the landing page
- Remove the `.draft` file when ready to publish

## Customization

Each presentation can have:
- `mkslides.yml` - Configure theme, transitions, plugins
- `custom.css` - Custom styling
- `assets/` - Images and media files

See the `template/` folder for examples.

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
7. **Copies** the CNAME file for custom domain support

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

```bash
# Create new presentation
./new.sh my-talk

# Edit slides
$EDITOR presentations/my-talk/slides.md

# Preview with auto-reload
./serve.sh my-talk

# Build all presentations
./build.sh

# Publish (remove draft status)
rm presentations/my-talk/.draft

# Commit and push to deploy
```
