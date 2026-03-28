---
layout: post
section-type: post
has-comments: true
title: "QMK Firmware: Taking Keyboard Ownership Further"
category: tech
tags: ["productivity"]
---

#### Table of Contents

- [What Is QMK](#what-is-qmk)
- [The Keyboard: Lily58](#the-keyboard-lily58)
- [Two Layers Are Enough](#two-layers-are-enough)
  - [Base Layer](#base-layer)
  - [Lower Layer](#lower-layer)
- [Performance Tuning](#performance-tuning)
  - [Debounce Algorithm](#debounce-algorithm)
  - [Scan Rate and USB Polling](#scan-rate-and-usb-polling)
  - [N-Key Rollover](#n-key-rollover)
- [Features I Turned Off](#features-i-turned-off)
- [The OLED](#the-oled)

---

Almost two years ago I wrote about [choosing the right
keyboard]({% post_url 2024-05-11-choosing-the-right-keyboard %}). Back then, I
ended with a brief section on QMK firmware tweaks — debounce algorithms, N-Key
Rollover, scan rate. The weirdo zone was introduced, and we moved on. But then I
built a Lily58, spent way too long thinking about keymap design, and realized
firmware deserves a post of its own.

This is that post.

## What Is QMK

[QMK](https://qmk.fm) (Quantum Mechanical Keyboard) is open-source firmware for
programmable keyboards. If your keyboard supports it, the firmware is a C
project you can clone, modify, and flash yourself. You define every layer, every
key binding, every timing parameter. It supports hundreds of keyboards and has a
large ecosystem of features: tap dance, combos, home row mods, macros, OLED
displays, and more.

The interesting thing is that most writing about QMK focuses on enabling
features. This post is mostly about turning them off.

## The Keyboard: Lily58

The Lily58 is a 58-key column-staggered split keyboard. I covered split
keyboards briefly in the previous post — "enter weirdo zone" — and the Lily58
earns that warning. Two halves connected by a TRRS cable, each with its own
microcontroller, communicating over serial. At 58 keys you're in 60% territory,
which means everything needs to be reachable across two layers.

## Two Layers Are Enough

The keymap is called `minimal-code` for a reason. Two layers. No more.

### Base Layer

The base layer is standard QWERTY, with the symbols a developer types most
frequently placed where they're easy to reach. The thumb cluster handles the
heavy lifting: `[` and `]` on the outer thumb keys, `Space` and `Enter` in the
center, `-` and `=` on the right inner thumbs. The layer toggle — `TG(_LOWER)` —
sits on the far right thumb, which means you toggle in and out of the lower
layer rather than holding a key down.

```text
,-----------------------------------------.                    ,-----------------------------------------.
|  `   |   1  |   2  |   3  |   4  |   5  |                    |   6  |   7  |   8  |   9  |   0  |BackSP|
|------+------+------+------+------+------|                    |------+------+------+------+------+------|
| Tab  |   Q  |   W  |   E  |   R  |   T  |                    |   Y  |   U  |   I  |   O  |   P  |  \   |
|------+------+------+------+------+------|                    |------+------+------+------+------+------|
| Esc  |   A  |   S  |   D  |   F  |   G  |-------.    ,-------|   H  |   J  |   K  |   L  |   ;  |   '  |
|------+------+------+------+------+------|   [   |    |    ]  |------+------+------+------+------+------|
|LShift|   Z  |   X  |   C  |   V  |   B  |-------|    |-------|   N  |   M  |   ,  |   .  |   /  |Delete|
`-----------------------------------------/       /     \      \-----------------------------------------'
                  | LCtl | LAlt | LGUI | / Space /       \ Enter\  |  -   |  =   |TG(LO)|
                  |      |      |      |/       /         \      \ |      |      |      |
                  `----------------------------'           '------''--------------------'
```

The left-hand modifiers — `LCtl`, `LAlt`, `LGUI` — are all on the left thumb
cluster. This keeps your right hand free to type while your left thumb handles
modifier chords. It takes a few days to internalize, after which going back to a
standard keyboard feels strange.

### Lower Layer

The lower layer handles everything else. Function keys across the top two rows.
Navigation on the right home row — `H/J/K/L` maps to `Left/Down/Up/Right`, which
is the natural choice if you spend any time in Vim. Media controls on the right:
previous, volume down, volume up, next. Play/Pause and Mute on the thumb keys.
Brightness on the bottom row.

```text
,-----------------------------------------.                    ,-----------------------------------------.
|  F1  |  F2  |  F3  |  F4  |  F5  |  F6  |                    |  F7  |  F8  |  F9  | F10  | F11  | F12  |
|------+------+------+------+------+------|                    |------+------+------+------+------+------|
| Tab  |      |      |      |      |      |                    | Prev | VolDn| VolUp| Next |      |      |
|------+------+------+------+------+------|                    |------+------+------+------+------+------|
| Esc  |      |      |      |      |      |-------.    ,-------| Left | Down |  Up  | Right|      |      |
|------+------+------+------+------+------|       |    |       |------+------+------+------+------+------|
|LShift|      |      |      |      |      |-------|    |-------|      | BriDn| BriUp|      |      |Delete|
`-----------------------------------------/       /     \      \-----------------------------------------'
                  | LCtl | LAlt | LGUI | / Play  /       \ Mute \  |      |      |TO(BA)|
                  |      |      |      |/       /         \      \ |      |      |      |
                  `----------------------------'           '------''--------------------'
```

The left side of the lower layer is mostly empty. That's intentional — there's
no point filling it with rarely used keys you'll forget are there.

## Performance Tuning

### Debounce Algorithm

I mentioned `sym_eager_pk` in the previous post. It's worth going into more
detail here because it's the single most noticeable tuning change.

Every mechanical switch produces contact chatter when pressed or released — a
brief burst of signal noise before the electrical connection stabilizes. The
debounce algorithm is how QMK filters that noise out. The default algorithm
(`sym_defer_g`) waits until the signal has been stable for the debounce period
before registering the keypress. Safe, but it adds latency. `sym_eager_pk` flips
this: it registers the keypress immediately on the first state change, then
ignores further changes for the debounce window. The result is a snappier feel,
especially noticeable during fast typing.

```makefile
DEBOUNCE_TYPE = sym_eager_pk
```

```c
#define DEBOUNCE 5  // debounce time in milliseconds
```

5ms is a comfortable value. Go lower and you risk ghost presses; go higher and
keystrokes start feeling sluggish. Keep in mind that the right value depends on
your switches — tactiles and clickies tend to chatter more than linears, so they
may need a slightly higher value.

### Scan Rate and USB Polling

The matrix scan rate is how frequently QMK polls the switch matrix to check for
state changes. Higher is better. The Lily58's default scan rate is around 1353
Hz. With the optimizations in this firmware, it reaches ~1569 Hz — a 16%
improvement, worth about 0.1ms of additional latency removed.

The USB polling interval is a separate concern: how often the keyboard reports
its state to the host. The default is 10ms. Setting it to 1ms lets you actually
benefit from the improved scan rate:

```c
#define USB_POLLING_INTERVAL_MS 1
```

0.1ms and 9ms of latency saved probably sounds like noise. In practice you
should expect a noticeably crisper feel, especially when typing quickly. Whether
that's worth the effort of tuning is up to you — but if you're already flashing
custom firmware, it's a two-line change.

### N-Key Rollover

N-Key Rollover (NKRO) means every simultaneous keypress is registered correctly,
regardless of how many keys are held at once. Standard USB keyboard mode limits
this to 6 simultaneous keys, which is usually fine but occasionally isn't —
think gaming, or complex modifier chords in Vim. There's no downside to enabling
NKRO. It's on by default in this keymap:

```makefile
NKRO_ENABLE = yes
```

```c
#define NKRO_DEFAULT_ON true
```

## Features I Turned Off

This is the part that goes against most QMK tutorials.

QMK supports tap dance (one key that does different things based on tap count),
home row mods (modifiers that activate when you hold a letter key), one-shot
modifiers, combos, macros, and more. These are genuinely powerful features.
They're also all disabled in this keymap.

The reason is scan rate and latency. Action tapping — required for tap dance and
home row mods — forces QMK to wait before it can decide what you intended. A tap
could be a tap or the start of a hold, and the firmware can't know until the
tapping term expires. That wait is felt. I've tried home row mods on and off for
months and always end up removing them. The misfires during fast typing are too
distracting.

Disabling unused features also reduces firmware size, which lets the compiler
make better optimization decisions. In `rules.mk`:

```makefile
MOUSEKEY_ENABLE = no
LOCKING_SUPPORT_ENABLE = no
LOCKING_RESYNC_ENABLE = no
SPACE_CADET_ENABLE = no
GRAVE_ESC_ENABLE = no
MAGIC_ENABLE = no
COMMAND_ENABLE = no
LTO_ENABLE = yes
```

And in `config.h`:

```c
#define NO_ACTION_TAPPING
#define NO_ACTION_ONESHOT
#define NO_ACTION_MACRO
#define NO_ACTION_FUNCTION
```

`LTO_ENABLE` enables Link Time Optimization, which reduces firmware size by
eliminating dead code at the linking stage. A smaller binary fits better in
flash and enables more aggressive inlining. It's free performance.

The tradeoff is real: you give up flexibility for responsiveness. But two
explicit layers with a toggle key is simpler and more predictable than a keymap
full of hold-tap behavior. And that's fine.

## The OLED

The Lily58 has a small OLED on each half. A lot of QMK OLED implementations
animate constantly — scrolling text, WPM counters, always redrawing. This one
doesn't. The display only updates when the active layer changes:

```c
bool oled_task_user(void) {
    static uint8_t last_layer    = 0xFF;
    uint8_t        current_layer = get_highest_layer(layer_state);

    if (current_layer != last_layer) {
        oled_clear();
        // write layer name ASCII art...
        last_layer = current_layer;
    }

    return false;
}
```

Constant OLED writes are expensive — the display shares the same I²C bus the two
halves use to communicate. Skipping unnecessary redraws keeps that bus free for
what actually matters: key state. The display shows the current layer name in
ASCII art, fades out after 60 seconds, and that's it.

```c
#define OLED_TIMEOUT 60000
#define OLED_FADE_OUT
#define OLED_FADE_OUT_INTERVAL 15  // slowest fade
```

Simple enough.

The full firmware is on [GitHub](https://github.com/le4ker/keyboard-firmware).
If you're building a keymap from scratch, it's worth reading — less as a
template and more as a reference for what you might want to leave out. Happy
typing!
