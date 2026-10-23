# Maktoob — Design System

Sky blue + navy identity for the Maktoob event/invitation platform.
This file is the source of truth for visual decisions. When code and this
document disagree, fix the code.

---

## Direction

Maktoob is an event and invitation product for the MENA market. The visual
language is **sky and night**: a clear sky blue for every action, a deep
navy for depth and trust, cool cloud-paper surfaces and slate type. The
logo (white QR-"M" on sky blue) is the anchor of the palette. Not a generic
SaaS dashboard: navy carries the ceremony, sky carries the invitation.

**Mood words**: clear, trustworthy, calm, hospitable, ceremonial-without-loud.

**What we are not**: purple-gradient AI app, glassmorphism, neon,
gradient-on-everything, dribbble bento.

---

## Palette

All tokens live in `lib/core/utils/app_colors.dart`. Use the named constants;
do not hardcode hex. The same values are used by the admin dashboard
(`maktoob-backend/public/dashboard/css/maktoob-admin.css`, Sneat via
`scripts/brand-sneat-theme.php`) and the client portal
(`resources/views/client/layouts/css.blade.php`).

### Brand

| Role | Token | Hex | Notes |
|---|---|---|---|
| Primary | `primaryColor` | `#3AA4DB` | Sky blue. CTAs, focus rings, selection, progress, the logo. |
| On-primary | `secondaryColor` / `white` | `#FFFFFF` | Text/icons on `primaryColor` (bold, 16px+). |
| Depth | `tertiaryColor` | `#032855` | Navy. Gradient ends (sky → navy), headers, admin/portal sidebar, info. |
| Sky as text (light) | `primaryDark` | `#1A73A8` | Sky on white is 2.8:1, so links / text buttons / tab labels use this (5.2:1). Also the pressed state. |
| Sky as text (dark) | `primaryLight` | `#7DC4EA` | Links, tabs and accents on the navy night. |

The sky–navy pair is the only color combination that should visually anchor
a screen. Reaching for a third hue means the composition is doing too much.
The signature gradient is `[primaryColor, tertiaryColor]`.

### Surfaces (light)

| Role | Token | Hex | Notes |
|---|---|---|---|
| Scaffold background | `surfaceBg` | `#F5F8FC` | Cloud paper. |
| Card / surface | `white` | `#FFFFFF` | Cards lift off the scaffold with a 1px `gray200` outline. |
| Container highest | `gray100` | `#EEF2F7` | Input fills, chip backgrounds. |
| AppBar | `surfaceBg` | `#F5F8FC` | Same as scaffold — no seam between AppBar and body. |
| Sky wash | `sky50` / `sky100` / `sky200` | `#EAF5FC` / `#D4ECF8` / `#A9D8F0` | Selected chips, primary container, info banners. |
| Navy wash | `navy50` | `#E6ECF4` | Tertiary container, info pills. |

### Slate ramp (named `gray*` for backward compatibility)

```
gray50   #F7F9FC   mist
gray100  #EEF2F7   cloud           (input fill, chips)
gray200  #DFE6EE   line            (borders, outlineVariant)
gray300  #C5D0DC   strong line     (outline)
gray400  #94A3B8   hint / disabled
gray500  #6B7C93   icons secondary
gray600  #4E5F75   body secondary text
gray700  #364558   body
gray800  #1E2B3C
gray900  #0F1B2B   ink             (body primary text)
```

Neutrals carry a hint of navy so they sit with the brand pair instead of
reading as flat grey.

### Dark mode — navy night

Dark mode is not grey: it is the navy brought down to night. Never put navy
`#032855` text on dark surfaces — use `context.brandInk` (navy in light,
`primaryLight` in dark) or `context.primaryText`.

| Role | Token | Hex |
|---|---|---|
| Scaffold / AppBar | `darkBg` | `#07111F` |
| Cards, sheets, dialogs, bottom bar | `darkSurface` | `#0D1B2E` |
| Inputs, chips, raised | `darkSurfaceHigh` | `#13243A` |
| Outline / divider | `darkBorder` | `#1E3350` |
| Strong outline (unselected controls) | `darkBorderStrong` | `#2A4566` |
| Text | `darkText` | `#E6EDF5` |
| Secondary text | `darkTextSecondary` | `#8FA3BC` |
| Hint / disabled | `darkTextMuted` | `#64799A` |
| Primary | `primaryColor` | `#3AA4DB` (6.2:1 on `darkSurface`) |
| Error | `darkError` | `#F87171` |

Web: the admin sidebar is navy `#032855` in light mode and `#050D18` in dark;
"info" is navy in light and steel blue `#8FB4E0` in dark.

### Status colors

| Role | Token | Hex (light / dark) |
|---|---|---|
| Success | `green600` | `#16A34A` / `#4ADE80` |
| Warning | `amber500` / `amber600` | `#F59E0B` / `#FBBF24` |
| Error | `red500` | `#DC2626` / `#F87171` |
| Info | `tertiaryColor` | `#032855` / `#8FB4E0` |

### Containers (Material 3 ColorScheme)

| Slot | Light | Dark |
|---|---|---|
| `primaryContainer` | `sky50` | `tertiaryColor` (navy) |
| `onPrimaryContainer` | `tertiaryColor` | `darkText` |
| `tertiary` | `tertiaryColor` | `primaryLight` (navy would vanish) |
| `tertiaryContainer` | `navy50` | `navy700` |

### Escape hatches

`blue*`, `purple*`, `pink*`, `rose*`, `cyan*`, `indigo*`, `orange*`,
`yellow*` are kept for **non-brand surfaces only** — chart colors,
illustration accents, the `ai_design` feature's color picker. **Do not use
them in product chrome.** If a screen needs decoration, reach for the
slate ramp or the brand pair first.

Invitation artwork palettes (Hermes / `TemplateNormalizer`, e.g.
`emerald_gold`) are the guest's design choice, not the product identity,
and are out of scope for these tokens.

### Hourly banner moods (web)

Hero banners are the one product surface that leaves the sky/navy pair, by
the owner's decision: the client dashboard hero, the admin "Today" banner
and the client sign-in panel take a curated **mood** that changes every hour
(Asia/Gaza; the cycle shifts by a day so the same hour differs tomorrow).
Moods: olive & gold, Maktoob sky, Gaza sunset, Mediterranean, starry night,
damask rose, clay & sand, dawn. Source: `App\Support\BannerMood` (the
palettes), `resources/views/partials/mood.blade.php` (`.mk-mood`), preview
any one with `?mood=<key>`.

- Banners only. Buttons, links, inputs, statuses and cards stay sky/navy.
- Every mood keeps white text at 4.5:1 on its lightest stop.
- On a mood, the primary button is white with the mood's `ink` text.

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

- Warm gold / ivory / emerald chrome (the retired 2026 palette).
- Navy text on dark surfaces (use `context.brandInk`).
- Sky `#3AA4DB` as small text on white (use `primaryDark`).
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
| **auth/login** | Editorial display headline + full-bleed photographic backdrop with a sky → navy wash (top 40%), form on a white card lifted off bottom. Single sky CTA. |
| **auth/register** | Same backdrop language as login, multi-step with subtle progress indicator in sky. |
| **home** | Cloud scaffold. Section headers in titleLarge weight. Upcoming events as photo-led cards with date in display weight. No widget grid clutter. |
| **events/list** | List with generous row padding (16+ vertical), photo on leading side, event title and date stacked. |
| **events/detail** | Hero image, gradient-to-cloud mask (navy night in dark), title block, then sectioned information (when/where/host/RSVP) — each section separated by 32px+ gap, no card nesting. |
| **invitation/create** | Wizard with strong step indicator using sky. Sheet-based step entry. Preview on right (or below on phone). |
| **invitation/preview** | Full-bleed preview with the invitation as the hero — chrome reduced to floating actions. |
| **scanner** | Camera fills the screen, sky reticle, minimal chrome. Success state in green. |
| **payment** | Single column, summary card on top, payment method below, single sky CTA. No promotional banners. |
| **settings** | List-led, grouped sections, section titles in `gray700`. No icons-in-colored-tiles pattern next to every row. |
| **venues** | Map + list combo. Map uses cool/desaturated tiles if possible. List items photo-led like events. |
| **ai_design** | Allowed to break visual rules — this is the playground feature. Brand chrome (header/back) stays sky/navy; the canvas is freeform. |

---

## What changes by file

The sky + navy identity (October 2026) replaced the short-lived gold/emerald
palette across the whole platform:
- `lib/core/utils/app_colors.dart` — brand, slate ramp, navy-night dark
  tokens, `context.brandInk` / `primaryText` / `primaryWash`.
- `lib/config/themes/app_theme.dart` — light theme washes, deep-sky text
  buttons; dark theme rebuilt on the navy night.
- Android splash: sky in light, navy in dark (`values-night-v31`).
- Admin: `scripts/brand-sneat-theme.php` (re-run on original Sneat files),
  `public/dashboard/css/maktoob-admin.css`, `public/sneat/js/config.js`.
- Client portal: `resources/views/client/layouts/css.blade.php`
  (follows `body.dark-theme`).
- Emails and billing documents use the same hex values.

Still open:
- Each screen under `lib/features/*/presentation/screens/` reviewed
  against its row in the table above.
- Custom invitation/venue iconography pass.
- Motion pass with `flutter_animate`.

---

## How to verify

1. `flutter analyze` then `flutter run` on a device.
2. Light mode: cloud background `#F5F8FC`, sky primary buttons, sky → navy
   headers, links in deep sky.
3. Dark mode: navy-night background (not grey), cards `#0D1B2E` with a
   `#1E3350` outline, no navy text anywhere.
4. Arabic locale — same palette, RTL still correct.
5. Admin (`/admin`) and portal: toggle dark mode — navy sidebar, navy-night
   pages, steel-blue info.

If anything looks wrong, the most likely culprit is a screen that
hardcoded a hex color instead of using a token. Search `0xFF` under
`lib/features/` and convert hits to tokens.
