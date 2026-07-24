# BuildAcad — Stitch.ai Redesign Prompt Package

Built from your full screen inventory (35+ screens across student, instructor, and shared flows). Paste **Part 1** into Stitch first as project-level context, then paste each **Part 2** block when you generate that specific screen. Everything is written to fight the generic-"AI made" look: no purple/violet gradients, no glassmorphism-over-blob heroes, no default-Inter-everywhere, no stock Material/emoji icons.

---

## PART 1 — Global Design System (paste this first, once)

```
Design a mobile-first LMS app called BuildAcad ("Learn. Build. Achieve.") — a
Coursera-style learning platform with student, instructor, and live-class
flows. The result must NOT look AI-generated or template-default. Follow this
system exactly across every screen.

BRAND COLOR SYSTEM
- Primary — Electric Blue #3B82F6: primary buttons, active nav icon, links,
  progress bars, selected chips, focus rings.
- Secondary — Burnt Orange #EA580C: high-emphasis CTAs (Enroll, Go Live,
  Publish), live-class badges, streak/achievement accents, notification dots.
- Deep Amber — #D16900: pressed/hover state for orange elements, gradient
  partner for #EA580C (135deg, #EA580C → #D16900) on hero cards and premium
  badges — never used alone as a flat fill.
- Slate — #64748B: secondary text, inactive nav icons, borders, dividers,
  placeholder text, metadata (timestamps, view counts).
- Never combine primary blue and secondary orange as a gradient together —
  keep them as separate semantic signals (blue = navigation/trust, orange =
  action/urgency) so the palette reads as intentional, not decorative.

LIGHT MODE
- Background: #F8FAFC (not pure white — avoids flat/sterile default look)
- Surface/card: #FFFFFF with a 1px #E2E8F0 border, no heavy drop shadow —
  use a soft 0 2px 8px rgba(15,23,42,0.04) instead of default box-shadow
- Primary text: #0F172A · Secondary text: #64748B
- Elevated/sheet surfaces: #FFFFFF with 12–16px radius

DARK MODE
- Background: #0B1220 (near-black navy, not pure #000)
- Surface/card: #151E2E with a 1px #263349 hairline border
- Primary text: #F1F5F9 · Secondary text: #94A3B8
- Blue and orange both shift ~8% brighter in dark mode to stay legible against
  the dark navy without glowing/neon

TYPOGRAPHY — avoid default Inter-only stacks
- Headings/display: "Sora" (600/700) — geometric, confident, distinct from
  generic sans defaults
- Body/UI text: "Plus Jakarta Sans" (400/500) — warm, highly legible at small
  sizes, pairs cleanly with Sora without looking like a template pairing
- Numerals (prices, stats, durations, ratings): tabular figures, medium weight
- Base size 16px, line-height 1.5, minimum body text 13px (never smaller)

ICONOGRAPHY — this is the #1 place templates look AI-made, fix it here
- Commission/generate a single custom line-icon set: 1.5px stroke, rounded
  caps and joins, 24×24 grid, consistent corner radius on all icon shapes
- Give the icon set ONE small brand quirk that repeats across all icons
  (e.g., every icon's terminal stroke ends in a subtle 2px rounded nub, or a
  consistent 15° angle on directional icons) so it reads as a designed
  family, not a mixed default set
- Active/selected state = filled or duotone version of the same icon
  (filled shape at 20% opacity behind the 1.5px outline), never a color
  swap alone
- NO emoji anywhere in the UI. NO default Material/Feather/Font Awesome
  icons used as-is — redraw or restyle them into the custom set
- Category icons (IoT, Robotics, Design, Public Speaking, etc.) get bespoke
  small illustrations, not generic folder/book icons

SHAPE & SURFACE LANGUAGE
- Corner radius scale: 8px (chips/tags) · 12px (buttons/inputs) · 16px
  (cards) · 24px (bottom sheets, modals) — never mix radii within one
  component family
- Cards: flat fill + hairline border, NOT glassmorphism, NOT frosted blur.
  Reserve blur/glass strictly for the video player overlay controls and
  the live-class "on air" chip — nowhere else
- Buttons: solid fill for primary (blue), outlined/hairline for secondary,
  ghost/text for tertiary actions — 12px radius, 48px min height (44×44pt
  minimum touch target everywhere)
- Dividers: 1px hairline, never a heavy 2px+ rule

LAYOUT
- 16px screen margins, 12px gutter between grid items, 24px vertical
  rhythm between major sections
- Bento-style asymmetric grouping on Home (one large featured card + 2-up
  grid below) instead of a uniform list-of-equal-cards look
- Bottom navigation: 4 tabs max (Home, Explore, Search, Profile), active
  tab = filled icon + label in Primary Blue, inactive = outline icon in
  Slate, with a small 3px pill indicator sliding under the active tab

MOTION SYSTEM (declare this once, apply everywhere)
- Page transitions: shared-element/hero transition when a card opens into
  a detail screen (thumbnail morphs into the detail header image, 280ms,
  ease-out) — not a generic slide-in
- Tab switches (bottom nav): 180ms crossfade + 4px vertical settle, icon
  does a quick 1.05x scale bounce on tap
- List/grid entrance: staggered fade+rise (12px), 40ms stagger per item,
  capped at 6 items staggered then the rest appear instantly
  (never animate a full long list)
- Buttons: 100ms scale-to-0.97 on press, spring back on release
- Bottom sheets/modals: slide up 240ms ease-out with a scrim fade
- Respect reduced-motion: fall back to opacity-only 120ms fades
- Loading states: skeleton shimmer (not spinners) for all card/list content

ACCESSIBILITY
- Minimum 4.5:1 text contrast in both modes (validate blue-on-white and
  slate-on-navy pairings specifically)
- Every icon-only button gets a visible label on long-press/tooltip and an
  accessible name
- 44×44pt minimum tap targets, 8px minimum spacing between adjacent
  tappable elements

This is a Flutter application (Android/iOS/web shell) — design components
that map cleanly onto Flutter primitives (Scaffold, Card, BottomNavigationBar
equivalents, TabBar, SliverAppBar-style collapsing headers) rather than
web-only patterns.
```

---

## PART 2 — Per-Screen Prompts

Paste the relevant block after Part 1 is loaded as context. Grouped by flow, matching your `screens/` folder structure.

### 2.1 Splash Screen
```
Design the BuildAcad splash screen. Dark navy (#0B1220) background regardless
of system theme (splash is always dark for brand consistency). Center: the
logo mark animates in with a subtle scale+fade (0.9→1.0, 400ms), followed by
the wordmark "BuildAcad" in Sora 700, then the tagline "Learn. Build.
Achieve." in Plus Jakarta Sans 400, Slate color, fading in 150ms after the
wordmark. Bottom third: a thin animated progress line in Primary Blue that
fills left-to-right, no spinner. No gradient background — flat navy with a
very faint (4% opacity) radial glow of Primary Blue behind the logo only.
```

### 2.2 Auth Flow — Login, Signup, Verify Email, Forgot Password
```
Design the BuildAcad auth flow: Login, Signup, Verify Email (6-digit OTP),
and Forgot Password screens, sharing one visual system.

Layout: top 35% is a compact illustrated header (custom flat-line
illustration, not a photo — students/instructors abstractly represented,
Primary Blue + Slate line art on Background color), bottom 65% is the form
on a rounded-top surface (24px top radius) that overlaps the header slightly.

Form fields: 12px radius, hairline border (#E2E8F0 light / #263349 dark),
16px internal padding, label sits above the field (never placeholder-only),
focus state = 2px Primary Blue border + subtle blue glow (not a harsh
outline). Password field has a Slate eye-toggle icon from the custom set.

Primary CTA (Log In / Sign Up / Verify): full-width, 12px radius, solid
Primary Blue, 48px height. Google sign-in button: outlined, white/dark
surface fill, custom-redrawn Google "G" mark, NOT the default Google button
asset. Secondary link ("Don't have an account? Sign up"): Slate text with
Primary Blue tappable word.

Verify Email screen: 6 individual OTP boxes (12px radius, 44×52px each),
active box gets Primary Blue border + soft glow, auto-advance on input.
Resend code link disabled/greyed with a 60s countdown in Slate, turns
Primary Blue when re-enabled.

Error states: red-orange (#DC2626, distinct from brand orange to avoid
confusion) text directly under the field, 13px, with a small alert icon
from the custom set — never a top-level banner for field errors.

Transition into this flow from splash: fade+rise 240ms. Transition between
Login↔Signup: horizontal slide with the shared header illustration
persisting (shared-element) while only the form swaps.
```

### 2.3 Home Tab (main dashboard)
```
Design the BuildAcad Home tab — the primary student dashboard.

Header: sticky, collapses on scroll (SliverAppBar-style). Expanded state
shows avatar (36px, Primary Blue ring if streak active), greeting
("Good evening, [Name]") in Sora 600, notification bell icon (custom set,
Secondary Orange dot badge if unread) top-right. Collapses to a compact
36px bar with search icon only.

Search bar: below header, 48px height, 12px radius, hairline border,
Slate placeholder "Search courses, instructors...", custom search icon
left-aligned, filter icon right-aligned in Primary Blue.

Section 1 — Continue Learning: single large bento card (full width, 16px
radius), course thumbnail as background with a bottom gradient scrim
(black 0%→60% opacity, NOT a color gradient), progress bar in Primary Blue
overlaid near bottom, "Resume" pill button in Secondary Orange top-right
of the card.

Section 2 — Categories: horizontal scroll of pill chips, each with a
bespoke small icon + label, unselected = hairline border + Slate text,
selected = filled Primary Blue + white text with a spring-scale animation
on tap.

Section 3 — Live Classes: horizontal card carousel, each card has a
pulsing "LIVE" badge in the Orange→Amber gradient (only place this
gradient variant is used besides the enroll CTA), instructor avatar,
countdown or "Join Now" state.

Section 4 — Featured/Popular/Recommended Courses: 2-column bento grid,
each card = thumbnail (12px radius top corners), title (Sora 600, 2-line
clamp), instructor name (Slate, 13px), rating stars (custom filled-star
icon in Amber, not default yellow), price bottom-right in bold.

Section 5 — Top Instructors: horizontal avatar-card scroll, circular
avatar (56px) + name + "Follow" ghost button that fills Primary Blue on tap.

Entrance animation: sections stagger-fade-rise 40ms apart on first load
only, not on every scroll.
```

### 2.4 Explore Tab
```
Design the BuildAcad Explore tab: a denser course-discovery grid.
Top: horizontal category chip row (same style as Home). Below: 2-column
masonry-style grid of course cards (slightly varied heights based on title
length — this is the deliberate "not-templated" touch). Each card: thumbnail,
level badge (Beginner/Intermediate/Advanced) as a small pill in Slate-on-
Background, title, instructor, star rating, price. Sticky filter/sort bar
appears on scroll-up, hides on scroll-down. Empty/loading state uses
skeleton shimmer cards matching the exact card shape, not generic gray boxes.
```

### 2.5 Search Screen
```
Design the BuildAcad Search screen. Top: full-width search input, auto-
focused, custom back-caret icon left, clear "x" icon right when text present.
Below, three states:
1) Empty query — "Recent Searches" (chip row, each with a small Slate "x" to
   remove) above "Trending" (list with a small trending-up icon in Orange).
2) Typing — live suggestions dropdown, grouped by type (Courses /
   Instructors / Categories) with a small section label in Slate caps,
   11px, letter-spacing 0.5px. Each suggestion row has a leading icon
   matching its type from the custom set.
3) Results — reuses the Explore grid card style. No results state: a small
   custom line illustration (magnifying glass + course icon, not a stock
   "empty box" graphic) + "Try a different search" in Slate.
Transition into a result: shared-element thumbnail morph into Course Detail.
```

### 2.6 Categories & Category Detail
```
Design the Categories screen: full grid (not horizontal scroll) of all
categories, each as a bento card with a bespoke icon on a tinted background
(each category gets a unique 8%-opacity tint of either Primary Blue or
Secondary Orange, alternating, never both on one card), category name,
course count in Slate.

Category Detail: collapsing header with the category icon large + tinted
background carrying over from the grid (shared-element continuity), then a
filterable list of courses in that category using the standard course card.
Sort/filter row sticky below header.
```

### 2.7 Course Detail Screen
```
Design the BuildAcad Course Detail screen with Overview / Curriculum /
Reviews tabs.

Header: hero thumbnail (16:9), collapsing on scroll into a compact title
bar. Below hero: title (Sora 700, 2-line), instructor row (avatar + name +
"Follow" ghost button), rating + review count + student count as a single
metadata row with dot separators, level badge pill.

Tab bar: underline-style, Primary Blue underline slides between tabs
(180ms), inactive tabs in Slate text.

Overview tab: description (expandable "Read more" in Primary Blue),
"What you'll learn" as a 2-column checklist with a custom checkmark icon
in Blue, prerequisites list, estimated hours/level as icon+label chips.

Curriculum tab: accordion of sections, each expandable, lesson rows show
type icon (video/text/quiz — three distinct custom icons), duration in
Slate, a lock icon for un-enrolled locked content.

Reviews tab: rating distribution bar chart (Primary Blue bars) at top,
then review cards with avatar, star rating, comment, and instructor-reply
sub-cards (indented, tinted Background, Orange left-border accent).

Sticky bottom bar: price (bold, large) left, "Enroll Now" solid Secondary
Orange button right, 12px radius, elevates slightly (subtle shadow) to
separate from scroll content.

Enroll tap → shared-element transition where the sticky button morphs into
the loading state, then success confirmation (checkmark burst, brief,
non-blocking) before routing to Course Learning.
```

### 2.8 Course Learning Screen
```
Design the BuildAcad Course Learning screen (video player + content).
Top: full-width video player (custom-skinned controls — Primary Blue
scrubber, Orange play button, glass-blur control bar over the video only —
this is the one approved glassmorphism zone). Below player: three-tab
switcher (Lessons / Notes / Study Materials) as a segmented control (pill
container, active segment slides with a Primary Blue fill, 200ms).

Lessons: reuses curriculum accordion style, current lesson highlighted with
a Primary Blue left-border accent + tinted row background (6% opacity blue).

Notes: list of user notes with timestamp chips (tap to seek video), floating
"+" button in Secondary Orange bottom-right to add a note at current
timestamp.

Study Materials: file-type icon (PDF/doc/slide — distinct custom icons) +
filename + download icon, list rows on hairline dividers.

Bottom: "Mark Complete" outlined button that fills solid Blue + shows a
checkmark animation on completion.
```

### 2.9 My Learning Screen
```
Design the My Learning screen: segmented control at top (In Progress /
Completed). Each enrolled course = horizontal card: thumbnail left (80×80,
12px radius), title + instructor + progress bar (Primary Blue) + "% complete"
right-aligned. Completed courses show a small Orange "Certificate" ghost
button instead of the progress bar. Empty state: custom illustration +
"Explore courses" CTA linking to Explore tab.
```

### 2.10 Instructors & Instructor Profile
```
Instructors list: 2-column grid of instructor cards — circular avatar
(72px) centered, name, expertise tag (Slate pill), rating, "Follow" ghost
button. Filter chips for expertise areas at top.

Instructor Profile: header with large avatar, name (Sora 700), expertise,
bio (expandable), stats row (Students / Courses / Rating as three
equal-width stat blocks with big Sora numerals + Slate labels), social
links as small custom icon buttons, Follow button (fills Blue when
followed, outline when not). Below: their published courses in the
standard grid.
```

### 2.11 Instructor Dashboard — Shell + Home
```
Design the Instructor Dashboard shell and home. This is a distinct "work
mode" visual register from the student app — same tokens, denser layout,
side-drawer or bottom-sheet quick-switcher between: Dashboard Home, Courses,
Live Classes, Students, Analytics, Earnings, Reviews, Profile.

Dashboard Home: top stat-card row (horizontal scroll on mobile) — Total
Students, Total Revenue (NPR रु, tabular numerals), Average Rating, Active
Courses — each stat card has a small trend arrow (up = Blue, down = Orange-
red variant) and sparkline. Below: "Recent Activity" feed (enrollments,
reviews, live-class signups) as compact rows with type-specific icons.
Quick-action row: "Create Course" and "Go Live" as two prominent pill
buttons, Blue and Orange respectively.
```

### 2.12 Instructor Courses, Creation, Edit, Course Detail
```
Instructor Courses list: same course-card grid as student side but each
card has a status pill (Draft = Slate outline, Published = Blue fill) and
a "..." overflow menu (edit/unpublish/delete) using a custom kebab icon.

Course Creation / Edit: multi-step form using a stepper header (numbered
circles connected by a line, completed = filled Blue, current = Blue
outline, upcoming = Slate outline) for Basic Info → Curriculum → Pricing →
Review. Curriculum step: drag-to-reorder sections/lessons with a custom
grip-handle icon, add-section as a dashed-border "+" card (not a solid
button, to visually differentiate from content).

Instructor Course Detail (5 tabs: Overview/Content/Reviews/Q&A/Analytics):
same tab-underline system as student Course Detail; Analytics tab shows a
simple line chart (enrollment over time, Primary Blue line, soft blue
area-fill beneath at 8% opacity) and a bar chart (revenue by month, Orange
bars) — both with visible axis labels and no reliance on color alone
(add value labels on hover/tap).
```

### 2.13 Live Classes (List, Create, Room)
```
Live Classes list: upcoming classes as cards with a date/time block
(left, Sora numerals for date), title, instructor/audience info, and a
status pill: Scheduled (Slate outline) / Live Now (pulsing Orange-Amber
gradient fill with a small animated dot) / Ended (Slate fill, reduced
opacity). Create Live Class: form matching the course-creation input style,
date/time pickers with custom calendar/clock icons, participant-limit
stepper.

Live Class Room: full-bleed video area, floating glass-blur control dock
at the bottom (mute, camera, participants, leave — custom icons, leave
button in a red-orange distinct from brand orange to signal a destructive
action), participant thumbnail strip collapsible from the side, chat panel
as a bottom sheet (drag handle, 24px top radius).
```

### 2.14 Notifications & Settings
```
Notifications: grouped by Today/Earlier, each row has a type icon in a
tinted circular background (Blue tint for course updates, Orange tint for
live-class alerts, Slate tint for system), unread rows carry a 6%-opacity
Blue background tint, swipe-to-dismiss with a custom trash icon reveal.

Settings: grouped list sections (Account, Notifications, Appearance,
About) with hairline dividers between rows, each row = icon + label +
chevron/toggle. Appearance section: Light/Dark/System as a 3-segment
control, live-preview thumbnail (small mock screen) updates as the user
switches segments. Sign out as a destructive ghost row at the bottom in
the red-orange destructive color, separated by extra spacing from the rest.
```

### 2.15 Bottom Navigation & Shared Chrome
```
Design the persistent bottom navigation bar: 4 tabs (Home, Explore, Search,
Profile), 64px height, Background-color fill with a 1px top hairline
border, safe-area padding on iOS. Active tab: filled custom icon in Primary
Blue + 11px label in Blue + a 3px rounded pill indicator that slides
smoothly (220ms, ease-out) beneath the active icon. Inactive tabs: outline
icon + label in Slate, no indicator. Center tap targets minimum 56×56px.
On tab switch, apply the crossfade+bounce motion defined in the global
motion system.
```

---

## Notes for using this with Stitch

- Stitch works best with one focused prompt per screen — Part 1 sets the shared vocabulary (colors, type, icon rules, motion), then each Part 2 block references it implicitly since it's in the same project/conversation.
- If Stitch's output drifts toward a generic feel on any screen, the two highest-leverage fixes are almost always: (1) regenerate the icon set instruction with the "one repeating brand quirk" line emphasized, and (2) explicitly reject Inter/system-font fallback and re-specify Sora + Plus Jakarta Sans.
- Since this maps to Flutter, once you like a Stitch screen, translate spacing/radius/color values directly into your `AppColors` and a new shared `theme/` file — I'd recommend consolidating your two existing `AppColors` implementations (`lib/constants/colors.dart` and `lib/theme/app_colors.dart`) into one source of truth as part of this redesign, since you'll be touching every screen's styling anyway.
