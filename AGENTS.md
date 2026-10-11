# Developer Guide

## Stack

- **Jekyll 4.2.2** static site generator (Ruby 3.2)
- **Plugins:** `jekyll-paginate`, `jekyll-spaceship` (Mermaid diagrams, enhanced
  Markdown)
- **Themes:** light (grayscale) / dark (everforest) — toggled via localStorage,
  defined in `_sass/_themes.scss`
- **Comments:** Cusdis | **Analytics:** Google Analytics G-7FXE996VCB

## Local Development

```bash
# With Docker (recommended — no Ruby install needed)
docker compose up --build
# → http://localhost:4000 with live reload

# Without Docker
bundle install
ruby bin/generate_tags.rb
ruby bin/generate_categories.rb
bundle exec jekyll serve --livereload
```

## Creating a New Post

```bash
ruby bin/new_post.rb <slug>   # creates _posts/YYYY-MM-DD-<slug>.md with today's date
```

After adding or changing tags/categories in any post's frontmatter, regenerate
the index pages:

```bash
ruby bin/generate_tags.rb
ruby bin/generate_categories.rb
```

These are also run automatically during CI build and in the Dockerfile.

## Project Layout

| Path                    | Purpose                                                    |
| ----------------------- | ---------------------------------------------------------- |
| `_posts/`               | Blog posts (`YYYY-MM-DD-slug.md`)                          |
| `_layouts/`             | Page templates                                             |
| `_includes/`            | Reusable HTML partials                                     |
| `_sass/`                | SCSS source (themes, variables, syntax)                    |
| `css/`                  | Compiled CSS entry points                                  |
| `img/posts/<slug>/`     | Per-post images                                            |
| `bin/`                  | Helper scripts (new post, tag/category generation, deploy) |
| `tags/` / `categories/` | Auto-generated index pages — do not edit manually          |
| `_config.yml`           | Site config (URL, pagination, social sharing, plugins)     |

## Deploy

CI (`.github/workflows/deploy.yml`) triggers on push to `main`:

1. `bundle install` → `generate_categories.rb` → `generate_tags.rb`
2. `JEKYLL_ENV=production bundle exec jekyll build`
3. `rsync _site/* ec2-user@<ec2-host>:/usr/share/nginx/html`

Manual deploy: `bash bin/deploy.sh` (requires `~/keys/memoryleaks.pem`).

## Linting

```bash
markdownlint **/*.md   # config in .markdownlint.yaml (100-char line limit)
prettier --write **/*.md  # config in .prettierrc.yaml
```

---

# Writing Style Guide — Panos's Blog

This file captures the writing conventions and style patterns from existing blog
posts. Use it when drafting or editing new posts to maintain a consistent voice.

---

## Frontmatter

Every post must use exactly these YAML fields — no additions, no omissions:

```yaml
layout: post
section-type: post
has-comments: true
title: <Title>
category: tech
tags: ["tag1", "tag2"]
```

- `category` is always `tech`
- `has-comments` is always `true`
- No `date`, `description`, `author`, `image`, or `permalink` fields
- 1–3 lowercase tags; common values: `"security"`, `"productivity"`,
  `"opensource"`, `"leadership"`, `"redteam"`, `"siem"`
- Date is encoded in the filename: `YYYY-MM-DD-slug.md`

---

## Voice & Tone

- **Semi-formal to conversational.** Write like a knowledgeable peer explaining
  something over coffee — never academic, never sloppy.
- **First person, confident.** Use "I" freely. Don't hide behind passive voice
  or hedge excessively.
- **Direct.** State opinions as facts when confident. Use "period" to signal
  conviction: _"I can't live without Neovim, period."_
- **Use "we" in tutorials** to create a sense of joint exploration with the
  reader: _"Now let's build a heuristic..."_
- **Dry, understated humor.** Deadpan asides and brief escalating jokes: _"Enter
  weirdo zone."_ / _"Enter a bit deeper into the weirdo zone."_
- **No filler.** Don't pad with summaries of what you just said. Make the point
  and move on.
- **Em-dashes for conviction and separation.** Use `—` to attach a sharp
  follow-up or reframe: _"think of it as the LSP of AI agents — a standard
  protocol, not a specific tool."_
- **Sentence fragments as full stops.** A one-sentence paragraph ending in a
  period signals a conclusion or punchline: _"Nowhere to be seen."_
- **Parenthetical deepening.** Use inline asides for technical nuance without
  derailing: _"Keep in mind that..."_ / _"A few things worth noting here."_

---

## Post Structure

### Intro

Always establish **personal context and stakes first**, then pivot to the
technical problem. Don't start with a definition.

Three accepted opening patterns:

1. **Rhetorical question hook:** _"Have you ever wondered..."_ / _"Have you
   thought how much time you spend..."_
2. **Personal context → problem:** Explain why you personally care, then
   introduce the topic.
3. **Broad problem → personal response:** State a general issue (e.g., OSS
   funding, team dynamics), then narrow to your own experience/solution.

For **series posts**, use this exact callback structure: _"[Timeframe] ago I
[wrote/built/explored] [link to previous post]. Back then, [recap]. But then
[new context], and I realized [gap or evolution]."_

### Body

- Divide with `##` or `###` headers as needed. Go two levels deep max (`###` +
  `####`).
- Always add a `#### Table of Contents` with anchor links at the top of every
  post, followed by `---`.
- Use a horizontal rule (`---`) only after a Table of Contents, not elsewhere.
- Always explain the "why" and historical/conceptual context before the "how."
- Code blocks are never dropped in isolation — precede them with a plain-English
  explanation, follow with interpretation if needed.
- **Exception — config/reference content:** It's fine to show the code block
  first, then explain its shape. _"Here's what the config looks like. Let's walk
  through what each part does."_
- **Open sections with a problem statement.** Establish what's broken or missing
  before presenting the fix: _"That works, but it means you end up with... which
  is ugly. Here's a cleaner approach."_
- **Scope escalators are structural, not just flavor.** _"Enter weirdo zone."_
  signals to the reader that we're going deeper into niche territory. Use them
  at the boundary where the audience narrows.
- **Diagrams as roadmap.** For long or complex posts, place a Mermaid flowchart
  early to show the full system before diving into parts.
- **Pacing: alternate long and short.** Follow a long explanatory paragraph with
  a short declarative: _"Simple enough."_ / _"That's it."_ This creates rhythm
  and lets the reader breathe.

### Conclusion

Keep it brief. Choose one pattern:

- **Forward teaser** (series): _"In the next post, we'll..."_ + bullet list of
  upcoming topics.
- **Community question:** _"I'd love to hear about your approach!"_ — genuine,
  not boilerplate.
- **Practical encouragement:** _"Feel free to fork it or cherry-pick the parts
  that work for you. Happy editing!"_
- **Credit the maintainers:** If the post covers an OSS tool, close by
  encouraging readers to support the author.
- **Cross-post stub:** Bold redirect — `**Continue reading [here](url)**` — for
  content originally published elsewhere.

---

## Formatting

### Headers

- `##` for top-level sections in longer/formal posts
- `###` for subsections; `####` for sub-subsections (rare)
- No trailing punctuation on headers

### Code

- Always annotate fenced code blocks with a language: ` ```python `,
  ` ```bash `, ` ```yaml `, ` ```lua `, ` ```javascript `, etc.
- Use `mermaid` (or `mermaid!` per site config) for flowcharts and architecture
  diagrams — prefer diagrams-as-code over image files.
- Use backtick inline code for: command names, file paths, field names, keyboard
  shortcuts, config keys.

### Lists

- **Bullet lists** for unordered items; list items are complete sentences in
  conceptual posts, shorter in reference posts.
- **Numbered lists** for steps or ranked priorities.
- **Bold lead-ins** for tiered categories within prose: _"**I can't live
  without**"_, _"**Hard to imagine my day-to-day**"_.

### Emphasis

- **Bold** for key terms, important conclusions, or lead-ins within paragraphs.
  Not overused.
- _Italic_ for image captions and occasional UI element names. Used sparingly.
- No callout boxes or blockquote admonitions. Notes go inline as parenthetical
  text or italic.

### Images

- Paths: `/img/posts/<post-slug>/filename.ext`
- Use **GIFs** for interactive/dynamic behavior, **SVG** for architecture
  diagrams, screenshots for UI state.
- Captions: inline italic directly below the image (`_Caption text_`). Only add
  a caption when the image is ambiguous without one.
- No hero/banner images. Content starts immediately with text.
- No "Figure N:" numbering.

---

## Technical Depth

- Target: intermediate to advanced readers who are technically literate but may
  not know this specific tool.
- **Define acronyms on first use** with the full form + parenthetical
  abbreviation: _"a Security Information and Event Management (SIEM) system"_.
- **Explain concepts in plain English** before going technical. Provide brief
  historical or conceptual background when it adds value.
- **Don't assume jargon is obvious** — brief one-sentence definitions keep posts
  accessible without being condescending.

---

## Recurring Phrases (use naturally, don't force)

| Phrase                                          | Context                                                   |
| ----------------------------------------------- | --------------------------------------------------------- |
| `"I'd love to hear about..."`                   | Closing community engagement                              |
| `"Again, it comes down to personal preference"` | When presenting options without wanting to over-prescribe |
| `"in my opinion"`                               | Softening a strong recommendation while still making it   |
| `"...and that's fine"`                          | Dismissing reader anxiety about a tradeoff                |
| `"Don't get lost in the details"`               | Advising readers not to over-optimize                     |
| `"How about..."`                                | Transitioning to a new idea or next step                  |
| `"Why not..."`                                  | Introducing an optional extension                         |
| `"Less than a minute later..."`                 | Highlighting tool responsiveness in demos                 |
| `"Happy X!"`                                    | Signoff in the final line (e.g., _"Happy editing!"_)      |
| `"Keep in mind that..."`                        | Parenthetical technical caveat, mid-explanation           |
| `"In practice you should expect..."`            | Setting realistic expectations after a demo or claim      |
| `"There will be times that you'll want..."`     | Introducing an edge case or advanced option               |
| `"A few things worth noting here."`             | Preceding a numbered list of technical asides             |

---

## Links & References

- **Always inline hyperlinks on natural anchor text.** Never "click here" or
  bare URLs.
- **Internal post links** use Jekyll liquid tags:
  `[Last time]({% post_url 2023-04-17-panther %})`
- **Documentation links** go to the specific anchor, not just the homepage.
- **Wikipedia** is acceptable for conceptual background links (not as factual
  citation).
- No footnotes, numbered references, or bibliography sections.

---

## Topics & Worldview

The blog covers security (both offensive and defensive), developer tooling and
productivity, open-source philosophy, and engineering leadership/team dynamics.
Posts reflect these values:

- **Security is practical, not paranoid.** Infrastructure decisions are made
  thoughtfully, not out of fear.
- **Tools should be owned and deeply customized.** Keyboards, editors, window
  managers — these are serious investments, not off-the-shelf choices.
- **Open source deserves financial support.** Credit and support maintainers
  explicitly.
- **Share what you build.** Every post links to the author's GitHub configs,
  repos, or reference projects.
- **Ergonomics and craft matter.** Quality of daily tools affects long-term
  wellbeing.

---

## Multi-Part Series

- Link back to previous posts in the opening, using the `{% post_url %}` tag.
- Close each part with a teaser of what comes next.
- Number series parts in post titles when relevant: _"Part 1"_, _"Part 2"_.
- Tags should be consistent across all posts in a series.
