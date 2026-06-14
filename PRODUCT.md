# Product

## Register

product

## Users

**Primary**: the event host. Usually a family organizer in the MENA market
(Gaza specifically, with expansion across Arabic-speaking and Turkish-speaking
audiences). They are planning a wedding, engagement, henna night, birthday,
graduation, aqiqah, or similar ceremonial event. They often hold a position
of social responsibility for how the celebration is received by extended
family and community.

**Context when using the app**:
- Emotional, often time-pressured. The event is days or weeks away.
- Image-conscious. The invitation is a social statement. A clumsy
  invitation reflects on the host.
- Primarily Arabic-speaking, with Turkish and English locales supported.
- Network conditions vary; the app must remain useful on patchy
  connections.
- Phone-first. Tablets and desktops are rare.

**Job to be done**: take an event idea (date, venue, guest list) and get a
beautiful, culturally specific digital invitation into each guest's
WhatsApp inbox within minutes. Then track who's coming, manage last-minute
changes, and check guests in at the door.

**Secondary roles** (served by separate views, not the focus of
PRODUCT.md): event-day staff using the QR scanner for check-in;
administrators operating the platform. Their needs are real but the
product's centre of gravity is the host.

## Product Purpose

Maktoob (Arabic: مكتوب, "written" / "a letter") is an invitation
management product for MENA-market events. It compresses the work of
hand-crafting an invitation, distributing it across the host's social
graph, and managing RSVPs into a single guided flow.

What it does:
- Creates events from a short, structured wizard (type, date, venue,
  package).
- Generates the visual invitation through an AI design pipeline tuned
  to the MENA aesthetic vocabulary (warm paper, saffron-gold,
  Arabic calligraphy).
- Distributes invitations via WhatsApp, SMS, and email, each
  personalized to the recipient.
- Tracks RSVPs in real time with a live dashboard.
- Supports check-in at the venue through a QR scanner used by event
  staff.
- Handles payment for paid packages and add-on services.

Why it exists: hand-managing an Arabic-context invitation list is
painful — paper invitations are expensive and slow, generic Western
invitation apps don't fit culturally, and group chats lose track of
who confirmed. Maktoob makes the host look prepared, dignified, and
attentive without demanding event-planner-level effort.

Success looks like: a host opens the app on Sunday evening, picks an
event type, fills four fields, accepts an AI-generated invitation, and
by Monday morning every relative on the guest list has a personal
message and a beautiful card in WhatsApp. The host feels celebrated by
the process, not buried by it.

## Brand Personality

Three words: **warm, considered, ceremonial**.

Voice and tone: like a thoughtful family elder who quietly runs a
respected event business. Patient. Dignified. Never patronizing, never
overly familiar. The product addresses the host the way a good host
addresses their own guests: with care.

What this means in practice:
- Copy avoids commands. "Send invitations" beats "Submit." "Let's pick
  your guest list" beats "Add guests."
- Microcopy carries small acts of attention. Empty states feel
  hospitable, not blank.
- Errors apologize for the inconvenience, not for the user. They
  describe what happened in plain language and what to do next.
- Loading states have texture. Static spinners over warm ivory, not
  generic progress bars.
- Numbers are restrained. "246 of 282 guests responded" is a fact, not
  a hero metric in a giant gradient panel.

The product never refers to itself as an "AI tool" or names its model.
The AI is invisible plumbing. The host produces invitations; the
product helps. That framing is non-negotiable.

## Anti-references

Maktoob explicitly should NOT look or feel like:

- **Sky-blue / cool-gray SaaS startup apps.** The old #3AA4DB palette
  and "modern tech app" aesthetic. Already banned in DESIGN.md.
- **AI-product cliches.** Purple-to-pink gradients, neon glows,
  sparkles, "Powered by AI" badges, magic-wand iconography. The
  visible AI tropes signal a different product class.
- **Generic Western wedding apps** (Zola, The Knot, Joy). Pastel
  pinks, cursive scripts, watercolor florals, "say I do" copy.
  Wrong cultural lane.
- **Dribbble bento dashboards.** Hero-metric panel + four identical
  icon+heading+text cards in a grid + a sidebar with "premium"
  badges. The first thing an AI builds by default. Always wrong here.

Adjacent failures to watch:
- Over-the-top wedding ornamentation (glitter, excessive gold flourish,
  fancy script everywhere) is also wrong. Refined beats ornate.
- "Festival of features" home screens. Maktoob has many features but
  shows one or two at a time.

## Design Principles

These are strategic, not visual rules. Visual decisions live in
`DESIGN.md`.

1. **Speed to a sent invitation is the win.** Every flow is measured
   against the time between "I have an event in mind" and "my guests
   have received it." Defaults are generous; the AI removes
   blank-canvas paralysis; the wizard never has dead steps.

2. **The invitation is the artifact, not the dashboard.** Design
   quality of the rendered invitation matters more than analytics
   panels. Hosts are judged socially by what they send, not by what
   the app reports back. Polish the artifact first.

3. **Cultural specificity over generic celebration.** Lean MENA:
   Tajawal type, Arabic-first composition, saffron-gold and deep
   emerald, calligraphy moments, RTL layout discipline. Refuse
   Western-wedding vocabulary. Refuse generic-celebration palette.

4. **AI is invisible plumbing.** The host generates beautiful
   invitations; the product helps. Never expose model names, never
   badge AI-generated content, never make the user feel like they're
   "using an AI app." Magic happens off-screen.

5. **Hospitality, not transaction.** Every copy and motion decision
   sounds like an attentive host, not a SaaS form. Patience over speed
   in the moments that matter (reviewing the invitation, confirming
   the guest list). Speed over patience in the moments that don't
   (logging in, fetching a list).

## Accessibility & Inclusion

Target: **WCAG 2.1 AA** on every shipping surface, with the following
specifics emphasized.

- **RTL discipline** (already supported): every layout uses
  `EdgeInsetsDirectional` and `AlignmentDirectional`. Every screen is
  reviewed in both LTR (English) and RTL (Arabic) before shipping.
- **Reduced motion**: honor `MediaQuery.disableAnimations`. Disable
  parallax, springy lifts, staggered reveals, and any motion that
  could trigger vestibular issues. Replace with instant or fade
  transitions.
- **Large text scaling**: respect the OS font-size preference (Android
  `fontScale`, iOS Dynamic Type). The home dashboard and event detail
  must remain legible at 200% scale. Critical because older relatives
  routinely review invitations with system text scaled up.
- **WCAG AA color contrast**: text/background ratios verified at
  4.5:1 minimum (3:1 for large text). The warm palette in DESIGN.md
  is designed to meet this — confirm per surface as we build.
- **Color-blind safe status semantics**: success, warning, error, and
  info states are communicated by more than color alone — icons,
  positions, and labels carry the meaning so red/green deficiency
  doesn't lose information.
- **Offline resilience**: network connectivity is variable in our
  primary market (Gaza). Drafts persist locally, all writes use
  retry-friendly idempotent patterns where possible, and offline
  states are graceful (the app feels like it's "waiting," not
  "broken").
- **Tap targets**: minimum 48×48dp / 44×44pt per Material/iOS
  guidelines. Already honored by `elevatedButtonTheme` in
  `app_theme.dart`; do not shrink for visual reasons.
