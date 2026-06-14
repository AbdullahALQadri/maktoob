# Maktoob — Design System

Warm, cultural, event-festive direction for the Maktoob event/invitation app.
This file is the source of truth for visual decisions. When code and this
document disagree, fix the code.

---

## Direction

Maktoob is an event and invitation product for the MENA market. The visual
language should feel **like an opened envelope on warm paper**: ivory
surfaces, refined gold for celebration, deep emerald for grounding, warm
charcoal type. Not a generic SaaS dashboard. Not a wedding-cliché palette.

**Mood words**: warm, considered, ceremonial-without-loud, premium-paper,
hospitable.

**What we are not**: sky-blue startup, purple-gradient AI app,
glassmorphism, neon, gradient-on-everything, dribbble bento.

---

## Palette

All tokens live in `lib/core/utils/app_colors.dart`. Use the named constants;
do not hardcode hex.

### Brand

| Role | Token | Hex | Notes |
|---|---|---|---|
| Primary accent | `primaryColor` | `#C2884A` | Saffron-gold. CTAs, focus rings, key actions. |
| On-primary | `secondaryColor` / `white` | `#FFFFFF` | Text/icons sitting on `primaryColor`. |
| Secondary accent | `tertiaryColor` | `#0E5E4A` | Deep emerald. Success, complementary highlights, secondary CTAs. |

The primary–tertiary pair is the only color combination that should
visually anchor a screen. Reaching for a third hue means the composition
is doing too much.

### Surfaces

| Role | Token | Hex | Notes |
|---|---|---|---|
| Scaffold background | `surfaceBg` | `#FBF7F1` | Warm ivory. The defining "paper" surface. |
| Card / surface | `white` | `#FFFFFF` | Cards lift off the ivory scaffold — a subtle but important hierarchy cue. |
| Container highest | `gray100` | `#F1ECDF` | Warm parchment. Input fills, chip backgrounds. |
| AppBar | `surfaceBg` | `#FBF7F1` | Same as scaffold — no visual seam between AppBar and body. |

### Warm neutral ramp (named `gray*` for backward compatibility)

```
gray50   #FAF6EE   warm white
gray100  #F1ECDF   parchment
gray200  #E5DDCB   sand            (borders, outlineVariant)
gray300  #CFC1A8   dune            (outline, dividers when stronger)
gray400  #A8997B   taupe light     (hint text, disabled)
gray500  #867860   taupe mid       (icons secondary)
gray600  #6B5C45   taupe dark      (body secondary text)
gray700  #4C3F2E   bistre          (body)
gray800  #332921   coffee
gray900  #1F1B16   warm charcoal   (body primary text)
```

Everywhere the previous code reached for "gray," it now resolves to warm
taupe. This is intentional — neutrals carry palette temperature, not just
brightness.

### Status colors

| Role | Token | Hex |
|---|---|---|
| Success | `tertiaryColor` / `green600` | `#0E5E4A` / `#1B7F4A` |
| Warning | `amber500` | `#D4A24A` |
| Error | `red500` | `#C4523A` (warm rust, not cool red) |
| Info | `amber700` | `#8E6422` |

### Containers (Material 3 ColorScheme)

| Slot | Token | Why |
|---|---|---|
| `primaryContainer` | `amber50` `#FBF1E0` | Light cream that supports gold without competing. |
| `onPrimaryContainer` | `tertiaryColor` | Deep emerald text on light cream — high-contrast editorial look. |
| `tertiaryContainer` | `emerald50` `#E8F1EC` | Soft emerald wash. |
| `onTertiaryContainer` | `tertiaryColor` | Same emerald, darker tone, on the light wash. |

### Escape hatches

`blue*`, `purple*`, `pink*`, `rose*`, `cyan*`, `indigo*`, `orange*`,
`yellow*` are kept for **non-brand surfaces only** — chart colors,
illustration accents, the `ai_design` feature's color picker. **Do not use
them in product chrome.** If a screen needs decoration, reach for the
warm-neutral ramp or the brand pair first.

---

## Typography

Font: **Tajawal** (already in `pubspec.yaml`). Excellent for Arabic + Latin.
Weights available: Light 300, Regular 400, Medium 500, Bold 700, Black 900.

The scale already lives in `app_theme.dart` `_buildTextTheme`. It is sound
— do not reinvent it. Refinement rules:

- **Use weight to create hierarchy, not size alone.** A 16/600 title and a
  16/400 body sit better than a 20/400 title and 14/400 body.
- **Display/Headline weights**: prefer `w700` over `w800/w900`. Tajawal Bold
  is dense enough; heavier weights muddy at small sizes.
- **Headlines**: use sentence case, not Title Case Like This. Arabic has no
  case but the latin pairing reads softer in sentence case.
- **Line-height**: keep current values. They are correct for Tajawal.
- **No all-caps** anywhere. Reads as enterprise software and breaks Arabic.

### When to break the scale

For invitation previews, event hero headers, and the AI design studio, an
**editorial display moment** is allowed: 40–56px Tajawal Black, tight
line-height (1.05–1.1), large breathing room. Use sparingly — once per
screen at most.

---

## Spacing

Spacing tokens live in `lib/core/utils/app_spacing.dart`. They are correct.
Do not invent new values inline.

Defaults that translate the warm/cultural mood into layout:

- **Screen padding**: 20–24px horizontal. Do not pinch to 16.
- **Section gaps**: 32–48px between unrelated content groups.
- **Card internal padding**: 16–20px.
- **List row vertical padding**: 12–16px (touch comfort).
- **Tap targets**: minimum 48×48dp (Material) / 44×44pt (iOS) — already
  honored by `elevatedButtonTheme` paddings; do not shrink for "minimal"
  looks.

The single biggest visual gain from this redesign is **more whitespace.**
If a screen feels cramped after the palette change, the fix is spacing,
not a smaller font.

---

## Radii

Already defined in `AppSpacing` (`radiusSm`, `radiusMd`, `radiusXl`).
Convention:

- Buttons, inputs, chips: `radiusMd` (existing).
- Cards: `radiusMd`. **Do not use `radiusXl` on cards** — feels balloon-y
  and AI-defaulted.
- Bottom sheets, dialogs: `radiusXl` (existing).
- Avatars, status dots: full / `radiusFull`.

---

## Elevation & shadows

Material 3 elevation tints are disabled across the theme
(`surfaceTintColor: transparent`) — keep this. The visual hierarchy comes
from **palette contrast** (white cards on ivory scaffold), not from
shadows.

Allowed shadows:
- Floating Action Button: default Material elevation (4).
- Bottom sheets and dialogs: default Material elevation (8/16).
- Cards: **none.** Use 1px `outline` border via the existing `cardTheme`.

Forbidden: drop shadows on inline cards, glassmorphism, neumorphic insets.

---

## Motion language

Implementation will use Flutter implicits + `flutter_animate` when needed.
The vocabulary:

- **Springy lift** on tap-active cards (`scale: 1.0 → 0.98 → 1.0`, 180ms).
- **Fade-up reveal** for list items entering view (8–16px translate, 220ms
  ease-out, 40ms stagger).
- **Hero transitions** for event card → event detail (existing Hero widget
  is fine, just ensure `tag` is consistent).
- **Sheet rise** for create flows — Material default, do not customize.
- **Reduced motion**: respect `MediaQuery.disableAnimations` — wrap motion
  in a check.

Forbidden: parallax that distorts on slow scroll, particle effects,
auto-playing video backgrounds, infinite shimmer that never resolves.

---

## Iconography

Currently using `cupertino_icons` + Material Icons. **Do not introduce a
third icon set.** Custom icons for product-specific concepts (invitation,
ceremony types) should be SVGs in `assets/icons/` matching the warm
charcoal weight — **2px stroke, rounded caps, no filled.**

---

## Imagery

For the invitation and venue features specifically:
- Photography-led: real venues, real ceremony imagery. No flat illustration
  fallbacks.
- Image radius: same as cards.
- Image-behind-text: use `LinearGradient` from `transparent` to
  `surfaceBg.withValues(alpha: 0.96)` over the bottom 40% before placing
  copy. Never raw text on photography.

For the AI design studio: it can range wider visually (it's the playground).
Other screens should stay in the brand palette.

---

## Localization & RTL

The app already supports Arabic, Turkish, English with proper RTL via
`flutter_localizations`. Visual rules:

- Always use `EdgeInsetsDirectional` over `EdgeInsets` for asymmetric
  padding.
- Always use `Alignment*` directional variants (`AlignmentDirectional.centerStart`).
- Icons that imply direction (arrows, chevrons) must use
  `Directionality`-aware variants — `Icons.arrow_back_ios` flips correctly,
  but custom SVGs need manual handling.
- Audit each redesigned screen in both LTR (English) and RTL (Arabic) before
  considering it done.

---

## Anti-patterns explicitly banned

Pulled from the design skills installed globally. Any of these in code is a
regression:

- Cool sky-blue accents (the old `#3AA4DB`).
- Purple-to-pink gradients on CTAs.
- Card-in-card-in-card nesting.
- Bottom nav with 5+ items.
- Lucide-default icon look with no product character.
- Tiny 11–12px body text outside captions.
- Inter font for the Latin script (we have Tajawal — use it).
- "Powered by AI" badges anywhere in the standard product flow.
- Skeleton shimmers that take longer than the actual load.

---

## Per-screen direction (high level)

For when we redesign screens one by one. Each gets a single visual move.

| Feature | Primary move |
|---|---|
| **auth/login** | Editorial display headline + warm full-bleed photographic backdrop (top 40%), form on ivory card lifted off bottom. Single CTA gold. |
| **auth/register** | Same backdrop language as login, multi-step with subtle progress indicator in gold. |
| **home** | Ivory scaffold. Section headers in titleLarge weight. Upcoming events as photo-led cards with date in display weight. No widget grid clutter. |
| **events/list** | List with generous row padding (16+ vertical), photo on leading side, event title and date stacked. |
| **events/detail** | Hero image, gradient-to-ivory mask, title block, then sectioned information (when/where/host/RSVP) — each section separated by 32px+ gap, no card nesting. |
| **invitation/create** | Wizard with strong step indicator using gold. Sheet-based step entry. Preview on right (or below on phone). |
| **invitation/preview** | Full-bleed preview with the invitation as the hero — chrome reduced to floating actions. |
| **scanner** | Camera fills the screen, gold reticle, minimal chrome. Success state in emerald. |
| **payment** | Single column, summary card on top, payment method below, single gold CTA. No promotional banners. |
| **settings** | List-led, grouped sections, section titles in `gray700`. No icons-in-colored-tiles pattern next to every row. |
| **venues** | Map + list combo. Map uses warm/desaturated tiles if possible. List items photo-led like events. |
| **ai_design** | Allowed to break visual rules — this is the playground feature. Brand chrome (header/back) stays warm; the canvas is freeform. |

---

## What changes by file

Phase 1 (this redesign — done):
- `lib/core/utils/app_colors.dart` — full token swap to warm palette
- `lib/config/themes/app_theme.dart` — scaffold/appbar background, primary
  & tertiary container slots

Phase 2 (per-screen):
- Each screen under `lib/features/*/presentation/screens/` reviewed
  against its row in the table above. Structural changes allowed since
  the user opted in.
- Shared widgets under `lib/core/widgets/` upgraded when a pattern
  repeats across 3+ screens.

Phase 3 (polish):
- Dark theme palette refinement (currently still uses cool dark
  surfaces — needs a warm-shifted dark like `#18130F`).
- Custom invitation/venue iconography pass.
- Motion pass with `flutter_animate`.

---

## How to verify the Phase 1 redesign

1. `flutter pub get` (no new deps but safe to run).
2. `flutter run` on a device or emulator.
3. Open these screens and confirm:
   - Background is warm ivory, not white.
   - Primary buttons are gold, not blue.
   - Text on white cards has warm charcoal color (not the old cool charcoal).
   - Borders and dividers have a subtle warm tint.
4. Check Arabic locale — same warm palette, RTL still correct.
5. Check the `ai_design` feature — its custom color pickers still work
   (the purple/pink/cyan tokens were preserved as escape hatches).

If anything looks wrong, the most likely culprit is a screen that
hardcoded a hex color instead of using a token. Search `0xFF` under
`lib/features/` and convert hits to tokens.
