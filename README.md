# Memory Leaks Blog

[![Deploy to Production](https://github.com/le4ker/blog/actions/workflows/deploy.yml/badge.svg)](https://github.com/le4ker/blog/actions/workflows/deploy.yml)

Source code and content for [memoryleaks.blog](https://memoryleaks.blog) — a
personal blog about cybersecurity, privacy, leadership, and developer
productivity.

Built with the [{ Personal }](https://github.com/le4ker/personal-jekyll-theme)
Jekyll theme.

### Tech Stack

- **Static Site Generator:** [Jekyll](https://jekyllrb.com/) 4.2.2
- **Language:** Ruby 3.2
- **Containerization:** Docker
- **Deployment:** GitHub Actions → AWS EC2 (nginx)

---

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started) (recommended), or
- Ruby 3.2+ with Bundler

### Local Development with Docker (Recommended)

```bash
# Build and start the development server
docker compose up --build

# The blog will be available at http://localhost:4000
# Live reload is enabled — changes will auto-refresh
```

### Local Development without Docker

```bash
# Install dependencies
bundle install

# Generate tags and categories
ruby bin/generate_tags.rb
ruby bin/generate_categories.rb

# Start the development server
bundle exec jekyll serve --livereload

# The blog will be available at http://localhost:4000
```

---

## Helper Scripts

| Script                       | Description                                   |
| ---------------------------- | --------------------------------------------- |
| `bin/new_post.rb <slug>`     | Create a new blog post with today's date      |
| `bin/generate_tags.rb`       | Generate tag pages from post frontmatter      |
| `bin/generate_categories.rb` | Generate category pages from post frontmatter |

### Creating a New Post

```bash
ruby bin/new_post.rb my-new-post
# Creates: _posts/2026-01-04-my-new-post.md
```

Then edit the generated file to add your content and update the frontmatter.

---

## Project Structure

```
.
├── _posts/           # Blog posts (Markdown)
├── _layouts/         # Page layouts
├── _includes/        # Reusable HTML partials
├── _sass/            # SCSS stylesheets
├── bin/              # Helper scripts
├── css/              # Compiled CSS
├── img/              # Images and assets
├── tags/             # Generated tag pages
├── categories/       # Generated category pages
├── _config.yml       # Jekyll configuration
├── Dockerfile        # Docker image definition
└── docker-compose.yml
```

---

## Deployment

Deployment is automated via GitHub Actions. Pushing to `main` triggers:

1. Ruby setup and dependency installation
2. Tag and category page generation
3. Jekyll production build
4. rsync to AWS EC2 nginx server

---

## Licensing

### Content (Posts, Images, etc.)

The content of this blog is licensed under the  
[Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)](https://creativecommons.org/licenses/by-nc-nd/4.0/).  
You may not redistribute, modify, or use the content for commercial purposes
without my explicit permission.

### Code (Jekyll Theme and Configuration)

The source code for this blog (including the Jekyll theme and configuration) is
**NOT licensed** for reuse or redistribution from this repository.  
If you would like to use or adapt the Jekyll theme, please visit the official
repository:  
[Original Jekyll Theme Repository](https://github.com/le4ker/personal-jekyll-theme).

---

## Terms of Use

This repository is for **personal use only**. Please do not clone, redistribute,
or reuse any part of the code or content without explicit permission.
