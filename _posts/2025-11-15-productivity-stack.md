---
layout: post
section-type: post
has-comments: true
title: What's Your Productivity Stack?
category: tech
tags: ["productivity"]
---

## Table of Contents

- [What's a productivity stack?](#whats-a-productivity-stack)
- [Software](#software-stack)
  - [Status Bar](#status-bar)
  - [Keyboard Keymap](#keyboard-keymap)
  - [Terminal Emulator](#terminal-emulator)
  - [Shell Aliases](#shell-aliases)
  - [Window Manager](#window-manager)
  - [IDE](#ide)
  - [Browser Shortcuts](#browser-shortcuts)
- [Hardware](#hardware)
  - [Keyboard](#keyboard)
  - [Mouse](#mouse)

## What's a productivity stack?

Definitions will vary depending on context, so let's define it in the context of
a tech worker:

> A productivity stack is the collection of tools, and workflows that form the
> backbone of how you interact with your computer. It's more than just software,
> it's a cohesive ecosystem where each component is chosen to complement the
> others, creating an environment that minimizes friction and maximizes
> efficiency. Whether you're a developer, designer, or knowledge worker, **your
> productivity stack becomes an extension of your thinking process, automating
> repetitive tasks and keeping you in a state of flow**. From the terminal you
> live in, to the window manager that organizes your workspace, to the browser
> extensions that streamline your web interactions, every element plays a role
> in shaping your digital experience.

In this post, I'll walk you through my own productivity stack, sharing the tools
that have fundamentally changed how I work and why I've chosen each one of them.
**A stack is a matter of taste** and this is not a "This is how you should do
it" guide. Instead, it should serve as an inspiration for finding your own
productivity stack that works for you.

## Software Stack

### Keyboard Keymap

Let's start with the keyboard keymap, which capitalizes on vim shortcuts, for
arrow, navigation and media keys, while it has the `Esc` button in an easily
reachable position (where the `Caps Lock` would normally be), since it's being
used heavily in vim's keybindings philosophy:

![base-layer](/img/posts/choosing-the-right-keyboard/base.png)

![lower-layer](/img/posts/choosing-the-right-keyboard/lower.png)

I have also replaced the `Caps Lock` key with the `Esc` in my Mackbook's
keyboard as well, for when I'm not working from my home office.

### Status Bar

When it comes to the status bar, I want something minimal and informational
only, that won't be distracting me away from my tasks, while providing my the
information that I need. From the time and date up to the battery level of my
AirPods. I've been using [Sketchybar](https://github.com/FelixKratz/SketchyBar),
with [this](https://github.com/le4ker/dotfiles/tree/main/sketchybar)
configuration that is tracked with git and the result is the following:

![rotate](/img/posts/productivity/statusbar.png)

No frills, right? Just the information I need.

### Terminal Emulator

The terminal is where I spend a significant part of my time and I've chosen
[Kitty](https://sw.kovidgoyal.net/kitty/) since it's highly configurable using a
config file that I can track on git. I have designed it with minimal as the
driver for my design decisions, while focusing on readability.

```config
font_family Hack Nerd Font
font_size 19.0
background_opacity 0.9
hide_window_decorations yes
```

I prefer the Hack Nerd Font at a comfortable 19pt size with 90% background
opacity. This gives a modern, clean look while maintaining strong readability.
Hiding window decorations maximizes screen real estate.

The [Everforest](https://github.com/sainnhe/everforest) colorscheme, provides a
warm, forest-green aesthetic that's easy on the eyes during long coding
sessions. The medium contrast variant strikes a great balance between
readability and comfort.

The shortcust are essential here as well, and follow the same vim aesthetic,
like my keyboard keymap does:

```config
# Tab navigation
map cmd+] next_tab
map cmd+[ previous_tab

# Tab management
map shift+cmd+l move_tab_forward
map shift+cmd+h move_tab_backward

# Font size controls
map cmd+k change_font_size all +1.0
map cmd+j change_font_size all -1.0
map cmd+0 change_font_size all 0
```

Now notice now how the status bar blends with the terminal emulator:

![status-bar-terminal](/img/posts/productivity/statusbar-terminal.png)

### Shell Aliases

While I keep my custom aliases minimal, the secret sauce is no other than the
good old [Oh My Zsh](https://ohmyz.sh/) and a couple of its plugins that provide
dozens of useful shortcuts. Here's which I use:

```bash
plugins=(
  zsh-autosuggestions  # Suggests commands as you type
  autojump            # Jump to frequently used directories
  git                 # Dozens of git shortcuts
  docker-compose      # Docker compose shortcuts
  sudo                # Add sudo with ESC ESC
)
```

The `zsh-autosuggestions` plugin is the most powerful, since it learns from your
command history and suggests completions as you type. Combined with `autojump`,
I rarely type full paths anymore. Just `j project` takes me to
`/path/to/my/project`.

The `git` plugin provides shortcuts that speed up common operations:

```bash
# Instead of typing these:
git status
git add .
git commit -m "message"
git push

# I use these:
gst    # git status
ga .   # git add .
gcmsg "message"  # git commit -m "message"
gp     # git push
```

### Window Manager

A window manager shines when it offloads you from arraning your windows. I did a
thorough walkthrough of my setup in [Your Windows on
Autopilot]({% post_url 2024-07-04-yabai %}), but the gist of it is that you can
rely on workspaces and
[Binary Space Partitioning](https://en.wikipedia.org/wiki/Binary_space_partitioning)
in order to let the window manager to automatically organize your windows as the
open and close.

![rotate](/img/posts/yabai/rotate.gif)

You'll need some shortcuts in order to control some aspects, like rearranging
windows in a workspace when needed, and it's key to use different key
combinations for managing the windows in your workspace, or the focus of the
windows. Trying to conform with vim shortcuts guideance will make changes
feeling natural:

```config
# Window Tree Manipulation
shift + alt - r : yabai -m space --rotate 270
shift + alt - y : yabai -m space --mirror y-axis
shift + alt - x : yabai -m space --mirror x-axis

# Window Manipulation
shift + alt - f : yabai -m window --toggle zoom-fullscreen

# Focus Window
alt - h : yabai -m window --focus west
alt - l : yabai -m window --focus east
alt - j : yabai -m window --focus south
alt - k : yabai -m window --focus north
```

### IDE

For code editing, I use Neovim with the [NvChad](https://nvchad.com/)
distribution. NvChad provides a well-configured, modern Neovim setup out of the
box, but the real power comes from the additional plugins and customizations. To
be honest, my whole obsesion with defining and continuously refining my
productivity stack, started with neovim. Neovim tought me that **you can control
your computer at speed of thought**. It's philosophy was simple, you need to
control everything with your keyboard, while complying with some simple key
binding norms, like `hjkl` for arrrows, `[` and `]` for back and forth, and
remembering the first name of what you want to do, and embedding them in your
key bindings, like using `fmt` as a shortcut of a toggle on the formatting of
your document.

You might think of vim or neovim being simple editors, but the truth is that
when you through at them the right tooling on top, they become an IDE. Setting
up the LSP, Formatters and Debuggers for the langauges you need will take a
while, but it will pay dividends over time. What about AI IDEs? You can bring it
up to par with them, by integrating plugins that essentially will turn your
neovim IDE into an AI IDE, the best of both worlds. The theme of neovim follows
the one of my terminal emulator, but in light mode:

The beauty of this setup is that it combines the modal editing power of Vim with
modern IDE features, creating a fast, distraction-free coding environment that
adapts to different programming languages seamlessly.

![neovim](/img/posts/productivity/nvim.png)

### Browser Shortcuts

The browser is where I spend most of my time, and keyboard-driven navigation is
essential for maintaining flow. I use [Vimium](https://vimium.github.io/), a
Chrome extension that brings Vim-style navigation to web browsing.

I've customized Vimium to align with Vim's navigation philosophy:

```config
# Tab Navigation (matching vim movements)
h           # Previous tab
l           # Next tab
u           # Restore closed tab

# Browser History
[           # Go back
]           # Go forward

# Scrolling
<C-d>       # Scroll page down
<C-u>       # Scroll page up
```

These mappings feel natural when combined with Neovim's key bindings—`h/l` for
horizontal movement translates perfectly to tab navigation, while `[/]` brackets
provide intuitive back/forward navigation. I use a streamlined hint character
set: `asdfghjkl`. This home-row configuration minimizes finger movement and
makes link selection lightning-fast:

```config
# Link Navigation
f           # Show link hints (using asdfghjkl)
F           # Open link in new tab
```

The beauty of this setup is how it creates a consistent navigation experience
across your entire system—from window management with `h/j/k/l`, to text editing
in Neovim, to web browsing with Vimium. Your muscle memory works everywhere.

You can find all the configs [here](https://github.com/le4ker/dotfiles), and for
neovim [here](https://github.com/le4ker/NvMegaChad).

## Hardware

### Keyboard

Keyboards are an entire rabbit hole by themselves, you can read more about them
in [Choosing the right keyboard for
you]({% post_url 2024-05-11-choosing-the-right-keyboard %}) where I documented
my journey of learning everything about them in order to built my daily driver:

![split-keyboard](/img/posts/choosing-the-right-keyboard/split.jpg)

### Mouse

The mouse is a matter of personal preference, but since I switched to
[trackball one](https://www.logitech.com/en-us/shop/p/mx-ergo-s-wireless-trackball-mouse),
I can't go back.
