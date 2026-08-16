# DESIGN_SYSTEM.md
## Authoritative Cross-Theme Design Specification

**Status:** Approved design foundation for implementation.  
**Scope:** Entire application, including screens that already exist and screens created later.  
**Theme rule:** Light and Dark are the **same design system**. Geometry, component structure, blur logic, glass behavior, opacity logic, depth, spacing, interaction states, icon rules, touch targets, and responsive behavior must remain the same. Theme files change **colors/tints only** unless this document explicitly defines an exception.

---

## 1. Source-of-truth hierarchy

When implementing or reviewing UI, use this order:

1. `DESIGN_SYSTEM.md` — structure, behavior, geometry, glass, depth, component rules.
2. Active theme file:
   - `DESIGN_LIGHT.md`
   - `DESIGN_DARK.md`
3. Approved reference screenshots for visual comparison.
4. Existing implementation only when it does not conflict with the files above.

Do **not** preserve an old implementation merely because it already exists.

Do **not** invent a new component appearance for a new screen. Reuse this system. A genuine exception must be explicitly documented in this file before it becomes part of the design language.

---

## 2. Design philosophy

The application uses a premium nature/travel visual language built around full-screen photography, theme-specific gradient overlays, highly translucent iOS-inspired liquid glass, clear depth through sheen/refraction-like edge lighting/blur/soft shadows, rounded organic geometry, consistent semantic typography, and calm spacing.

The target is **liquid glass**, not flat frosted cards and not opaque translucent panels.

A glass surface should feel transparent, glossy, light-catching, layered, softly refractive, and visually separated from the background without becoming heavy. The background must remain recognizable through glass while text stays readable.

---

## 3. Light / Dark parity — mandatory

The following values and behaviors are shared across Light and Dark:

- background-photo blur
- background-gradient opacity
- glass blur
- glass fill-opacity structure
- glass edge thickness
- glass sheen structure
- glass shadow geometry
- component radii
- component heights
- spacing
- touch targets
- selected/unselected behavior
- recessed input behavior
- stacked-glass progression
- toolbar structure
- card structure
- icon-container structure
- responsive breakpoints
- RTL behavior

Only theme tokens such as colors, tints, text colors, accent colors, and semantic state colors change.

**A Dark-mode component must not become more blurred, more opaque, more rounded, deeper, or structurally different simply because the theme is Dark.**

---

## 4. Background system — mandatory

### 4.1 Every screen uses a photo

Every screen must have a background photograph supplied as a bundled local asset.

- Do not replace the photo with a flat color or gradient.
- The developer supplies/assigns each screen's image asset in the project.
- Do not load required screen backgrounds from the network.
- Different screens may use different images.

### 4.2 Layer order

Bottom to top:

1. background photo
2. theme gradient overlay
3. page content and liquid-glass surfaces

This order is the same in Light and Dark.

### 4.3 Background-photo blur

Use a **minimal global background blur**:

- `backgroundPhotoBlurSigma: 2`
- same value in Light and Dark
- do not add a stronger Dark-only blur
- do not stack an additional full-screen blur unless explicitly required by a future approved design

The goal is to keep the image softly integrated while making it slightly more visible than the previous Light reference.

If a source photo is already artistically blurred, do not pre-blur the asset again; the runtime background treatment must still remain structurally identical between themes.

### 4.4 Gradient overlay

Use the theme's own gradient colors with:

- `backgroundGradientOpacity: 0.45`
- acceptable implementation-tuning range: `0.42–0.46`
- the chosen production value must be the same in both themes
- default direction: top → bottom
- uniform across the entire screen
- no Dark-only vignette
- no region that reverts to a flat background
- safe areas use the same continuous background treatment

Do not increase overlay opacity to solve readability. Improve the local glass surface behind the content instead.

---

## 5. Base liquid-glass material — mandatory

There is one default liquid-glass material for the application. It is reused for glass cards, informational cards, secondary buttons, social buttons, language options, filter containers, filter controls, popup menus, bottom sheets, floating toolbar / bottom navigation, selectable glass surfaces, glass back buttons, auxiliary glass controls, and future components intended to be glass.

### 5.1 Approved visual target

The approved target is the **bright, polished, highly transparent iOS-style Liquid Glass appearance shown in the reference images**.

A compliant surface must look like a piece of polished optical glass floating over the background — **not** like a translucent rectangle with blur.

The material must visibly combine all of these cues:

1. **High transparency** — the background remains recognizable through the surface.
2. **Moderate optical softening** — blur softens the background but does not erase it.
3. **Refraction / lens feeling** — content behind the glass appears very slightly bent, magnified, or optically displaced near curved edges.
4. **Bright light-catching rim** — the perimeter catches light, especially along the upper/light-facing edge.
5. **Corner highlights** — rounded corners receive soft concentrated highlights, never hard white dots.
6. **Directional sheen** — a soft glossy highlight passes across the upper portion of the surface rather than using a uniform white fill.
7. **Subtle inner glow** — a faint luminous layer just inside the rim gives the glass visible thickness.
8. **Soft floating shadow** — separates glass from the layer behind without creating a Material-card shadow.
9. **Very subtle theme tint** — enough to belong to the theme, never enough to become a colored panel.

**Blur + translucent fill + uniform border alone is NOT an acceptable Liquid Glass implementation.**

### 5.2 Base glass recipe

Use these values as the implementation starting point:

| Property | Rule |
|---|---|
| Backdrop blur | `σ = 14` baseline |
| Clear/transparency bias | keep the background clearly recognizable |
| Base sheen | neutral white, directional, approximately `16% → 3%` rather than a flat fill |
| Theme tint | approximately `4–6%` |
| Light-catching rim | `1.0–1.2px`; brightness varies around the perimeter |
| Corner highlight | soft white highlight at approximately `20–30%`, concentrated at rounded corners |
| Inner glow | soft white/neutral glow at approximately `6–10%` immediately inside the rim |
| Refraction/lens strength | subtle only; approximately `1–2.5%` local displacement/magnification near edges |
| Shadow | low-opacity, wide, fully faded, small offset |
| Saturation | preserve or slightly lift local color (`~1.05–1.10`) if renderer supports it |
| Hard opaque fill | prohibited for ordinary glass |

These are **visual target values**, not permission to recreate the material as a stack of flat opaque gradients. The resulting surface must be judged by appearance.

### 5.3 Directional lighting

Glass lighting must not be uniform.

Default light direction is from the **upper-left / upper edge** unless the screen composition clearly requires another direction.

- upper/light-facing rim = brighter
- opposite/lower rim = quieter
- top corners = softly highlighted
- center of glass = clearer than the rim
- do not draw a constant full-opacity white outline around the entire shape

The material should feel rounded and optically thick even when the component itself is geometrically flat.

### 5.4 Refraction / lens requirement

For custom Flutter surfaces, `BackdropFilter` by itself is insufficient.

Where technically feasible, the shared glass implementation should add a subtle optical approximation such as:

- small edge-localized magnification
- shader-based displacement
- refractive sampling
- curved highlight/distortion masks
- another performant technique that creates the impression that the background bends through the glass

The effect must remain subtle. Text and icons inside the component must never distort.

If the platform/rendering path cannot implement real distortion, preserve the illusion using the directional rim, corner highlights, inner glow, clear center, and asymmetric sheen. Do not compensate with heavier blur.

### 5.5 Glass edge vs selection stroke

These are two different things.

**Neutral liquid-glass rim**
- belongs to the material itself
- softly luminous and directionally lit
- visible on selected and unselected glass
- must not communicate selection

**Selection/focus stroke**
- semantic state indicator
- theme accent color
- appears only when selected/active/focused
- sits cleanly outside or over the neutral rim
- visibly stronger than the ordinary rim

Never use the ordinary glass rim as the selected-state indicator.

### 5.6 Soft floating shadow

Default floating-glass shadow:

- small vertical offset
- wide blur
- low opacity
- no hard edge
- no tight Material-style elevation shadow
- must fully fade into the background

Suggested starting geometry:

- `offsetY: 5`
- `blurRadius: 24`
- `spreadRadius: 0`
- alpha approximately `0.10–0.14`

The shadow supports the glass effect; it never replaces transparency, sheen, rim light, corner highlights, inner glow, or refraction.

### 5.7 Visual acceptance test

A shared glass component fails review if it can reasonably be described as a **“blurry box.”**

Before approving a glass component, verify:

- background is still visibly present through it
- center is not covered by a heavy white/green/dark wash
- at least one light-facing edge is visibly brighter
- rounded corners catch soft light
- sheen is directional rather than uniform
- the surface has visible optical depth
- shadow is soft and fully faded
- Light and Dark use the same optical structure

Cards, filters, toolbars, popup surfaces, language controls, secondary buttons, and other glass elements must all inherit this same material rather than implementing their own simplified blur recipe.

## 6. Stacked liquid glass

When glass surfaces overlap, depth is created by **progressive optical softening + inter-layer shadow**, not by increasing fill opacity.

Every layer must still look like the approved bright Liquid Glass material from Section 5.

### 6.1 Blur progression

| Layer | Typical use | Blur |
|---|---|---|
| L1 — base | outer card / main glass surface | `σ = 14` |
| L2 — middle | group card / sheet on L1 | `σ = 18` |
| L3 — top | glass control / chip / floating sub-surface on L2 | `σ = 22` |

Rules:

- blur rises gently with depth
- do **not** make higher layers more opaque
- keep the same clear-center, rim-light, sheen, corner-highlight, and refraction logic at every level
- tint strength remains subtle
- do not exceed L3 for ordinary UI
- if four visual glass layers appear necessary, flatten the hierarchy instead
- never turn L2/L3 into a white or colored frost wall

### 6.2 Inter-layer shadows

- L2 casts a soft shadow onto L1
- L3 casts a soft shadow onto L2
- shadow is fully faded
- low opacity
- small offset
- wide blur
- no visible boundary line

The upper layer should feel physically closer to the viewer because it is slightly more optically softened and casts a gentle shadow — **not** because it has a heavier fill.

### 6.3 Layer lighting

When glass layers overlap:

- keep highlights readable on each layer
- do not stack multiple bright rims into a thick white border
- reduce overlapping highlight intensity where necessary
- preserve the perception of separate glass sheets
- retain background color/detail through the entire stack as far as readability allows

## 7. Selection, focus, and control states — global

This rule applies to language options, filters, category choices, selectable cards, option tiles, multi-select chips, focusable glass fields, and future selectable glass controls.

### 7.1 Unselected / inactive

- use normal base liquid glass
- apply a very subtle theme tint
- **no accent selection stroke**
- neutral glass edge may remain because it belongs to the material
- no strong fill inversion

### 7.2 Selected / active

- keep the surface translucent and liquid-glass
- strengthen the theme tint/fill while preserving background visibility
- add the theme-specific accent stroke
- recommended stroke width: `1.5px`
- recommended selected tint strength: approximately `14–18%`
- optional extremely soft accent glow is allowed if it remains subtle
- selected state must be obvious at a glance

Selected does **not** mean turning ordinary selectable glass into a fully opaque block.

### 7.3 Focused text field

Focused field = selected-state treatment for inputs:

- keep recessed glass
- add theme accent stroke
- preserve inner depth
- do not replace the glass with a solid fill

### 7.4 Error

- keep the same geometry and glass material
- error color replaces the focus/selection stroke
- helper/error message uses the theme error color
- do not remove the field's recessed depth

### 7.5 Disabled

- retain component structure
- reduce emphasis to approximately 40% overall interactive strength
- no accent selection stroke
- no active glow
- maintain readable disabled text contrast

### 7.6 Success / warning / information

Semantic states use the theme's semantic color token while preserving the component's existing material and geometry.

Do not invent a separate card language for success, warning, error, or info.

---

## 8. Input fields — recessed liquid glass

All standard form/search/text inputs use the same **recessed / inset Liquid Glass** style in both themes.

Examples: Login, Register, Search, Booking forms, Profile forms, and future data-entry screens.

The approved depth reference is the **current Dark Register field treatment**: fields look visually deeper than the surrounding card. Light mode must use the same depth construction with Light-theme colors.

### 8.1 Mandatory visual relationship

- outer card/panel = floating polished Liquid Glass
- field inside it = recessed/inset Liquid Glass
- both remain translucent
- the field must appear to sit **inside** the parent surface rather than being a gradient rectangle placed on top

The Light theme must not use a left-to-right brand-gradient fill to create the field body.

### 8.2 Input recipe

- control height: `56dp`
- radius: `14px`
- retain the approved Liquid Glass material
- use a subtle theme tint only
- add a clearly perceptible but soft inset/inner shadow
- add a quiet inner highlight on the opposite edge so the field still reads as glass
- keep the center transparent enough for environmental color to remain visible
- neutral liquid-glass rim when inactive
- accent selection/focus stroke when focused
- error stroke on validation error
- text and hint colors come from semantic typography tokens

### 8.3 Recessed depth recipe

Use this as the starting target:

- inset shadow: `0, 2`
- inset blur: approximately `10–12`
- inset opacity: approximately `0.16–0.20`
- optional second very soft inset shadow from the upper edge to reinforce depth
- opposite inner highlight: approximately `6–10%`
- no hard inner line
- no opaque dark cavity
- no horizontal brand-gradient fill

The recessed effect must be visible in **both Light and Dark**.

The two themes change the tint/shadow colors only; the depth amount, geometry, blur, and construction stay the same.

### 8.4 Focus and selection

When focused:

- keep the inset depth
- keep the Liquid Glass rim/highlight
- add the theme accent stroke
- slightly strengthen the theme tint if needed
- do not flatten or brighten the field into a solid control

When unfocused:

- no accent selection stroke
- preserve inset depth
- preserve subtle neutral rim

### 8.5 Multi-line inputs

Added with the Reviews & Ratings composer. A multi-line field is the **same
recessed-glass input**, with `minLines`/`maxLines` set — not a second control.
Section 22 lists "different input families on different screens" as prohibited,
and a review box is a text input like any other.

- the recessed depth, radius and rim are unchanged; only the height grows
- the character counter is **not** drawn inside the field — it would sit
  outside the glass and break the recessed shape. A screen that needs a count
  draws its own, beside the label
- `maxLength` caps typing for UX; the real limit is re-validated in the
  security rules (section 7 of `SECURITY.md`)

### 8.6 Implementation note

If the framework has no native inset-shadow primitive, reproduce the depth using layered decoration, custom painting, clipping, shader/mask techniques, or another performant method.

Do **not** drop the inset depth merely because a standard `Container` cannot render an inner shadow.

### 8.7 Visual acceptance test

A standard input fails review if:

- Light looks like a gradient overlay while Dark looks recessed
- the field appears raised above its parent card
- the inner shadow is absent
- the field becomes opaque
- focus removes the recessed appearance
- Light and Dark use different depth geometry

## 9. Buttons

### 9.1 Primary page actions

Examples: Log In, Register, Send Code, Create Account, Continue.

Rules:

- solid theme action color
- theme on-action text color
- height: `56dp`
- radius: `14px`
- no heavy elevation
- subtle soft shadow allowed
- full-width where the page layout calls for a primary action
- 48dp minimum touch target always satisfied

### 9.2 Secondary / auxiliary buttons

Examples: Apple, Gmail, alternative actions, secondary confirmation surfaces.

Use liquid glass, not a second opaque button language.

When a secondary button sits on another glass surface, apply the stacked-layer rule.

### 9.3 Small card CTAs

Small CTAs embedded in cards remain pill-shaped.

Keep the existing compact proportions:

- visual height around `40dp`
- minimum tap target `48dp`
- pill radius
- label + directional arrow when applicable

The small card CTA is a compact action style and does not redefine the large primary button.

---

## 10. Cards

### 10.1 Standard cards

- radius: `28px`
- same radius in Light and Dark
- use liquid glass when the design calls for a glass card
- preserve generous internal spacing
- do not use theme-specific radius variants

### 10.2 Informational cards

Informational cards use the same liquid-glass material.

Do not fill them with the full-screen brand gradient.

### 10.3 Image cards

Where photography is part of the card:

- image remains the visual subject
- use theme-appropriate overlays only as needed for text legibility
- controls on top may use compact glass or semantic badge styles
- do not cover the image with an opaque glass wall

---

## 11. Icons

### 11.1 Feature/category icons

For feature/category icons such as Explore Nature, Where to Stay, Policy categories, facilities, and similar destinations:

- circular container
- **stroke only**
- no solid fill
- theme accent color for circle and icon
- icon centered
- use consistent size across equivalent card types

Recommended default:

- circle: `44–46dp`
- icon: `22–24dp`
- stroke: `1.5px`

### 11.2 Utility icons

Menu, globe, eye, chevrons, and other utility icons do not require a circle unless their component explicitly uses one.

### 11.3 Back button

- circular liquid-glass control
- visible circle approximately `36dp`
- minimum tap target `48dp`
- left chevron
- physically placed top-left even in RTL, unless a future approved design explicitly changes this
- theme-appropriate icon color

---

## 12. Filters

Filter regions use a liquid-glass container, standard spacing, and selectable controls using the global selected/unselected state.

### 12.1 Filter chips/options

**Unselected**
- lightly theme-tinted liquid glass
- no accent selection stroke

**Selected**
- stronger translucent theme tint/fill
- theme accent stroke (`1.5px`)
- may include a checkmark, but the checkmark is secondary to the visible selected state

- visual height around `38dp`
- minimum tap target `48dp`
- pill geometry when chip-like
- use `Wrap`/responsive flow when labels can vary by language

---

## 13. Rating components

Ratings use one consistent component family throughout the application.

Two forms are approved:

1. numeric score badge (example: `8.2`)
2. star-rating badge/row

Rules:

- keep score and stars visually separate when both are displayed
- compact rounded box
- radius: `12px`
- consistent padding and height across screens
- maintain high contrast
- theme files define the rating fill/stroke/content colors
- rating values and stars remain LTR in every language
- do not redesign rating structure per screen

Rating badges are semantic badges, not ordinary base-glass cards.

### 13.1 Half stars, and where they are allowed

Added with the Reviews & Ratings screen. A single review's rating is stored in
**half-star steps**, so the star row has three states per star — full, half,
empty — and the score beside it is `stars × 2` out of 10.

- **Half stars belong to per-review surfaces only**: the Reviews & Ratings
  list, its Average Rating header, and its composer.
- **The place-level badges keep whole stars.** The Explore Nature card and the
  detail hero were approved with whole stars derived by `round(score / 2)`;
  switching them to halves would restyle two already-built screens as a side
  effect of adding a third. `NatureSpot.halfStarsForScore` exists alongside
  `starsForScore` so the two are an explicit choice, not an accident.
- The `N.N / 10` pairing draws the **number large and the `/ 10` suffix quiet**,
  and the whole run stays LTR in every language, like every other rating.

### 13.2 Interactive star input — an accessibility exception, recorded

The composer's star row is tappable in half-star steps. Section 19 requires a
`48 × 48dp` hit area per control, and half a star cannot be 48dp wide without
the row running off a phone. The exception is taken deliberately, with three
mitigations, rather than dropping half stars (which would make the design's
7.0 and 9.0 scores unreachable):

- the row is **56dp tall**, so the vertical half of the requirement is met;
- it accepts a **horizontal drag**, so a value can be landed without hitting a
  20dp target;
- it exposes **slider semantics** with increase/decrease actions, so assistive
  technology adjusts it in half steps without touching the geometry at all.

This exception applies to the rating input only. Do not use it to justify
narrow targets anywhere else.

### 13.3 Rating distribution bars

The 5★→1★ bars beside an average score are a pill-radius
`LinearProgressIndicator` on a quiet track, in the theme accent — not a new
component family, and not a chart. Each bar carries its own Semantics label
(`"4 ★ 20%"`), because five bare percentages in a column read as noise to a
screen reader. The whole block stays LTR: a star count, a bar and a percentage
are a measurement sequence (section 20).

---

## 14. Bottom navigation / floating toolbar

Keep the existing interaction concept, but execute it with the global liquid-glass system.

### Structure

- floating pill
- height: `74dp`
- side inset: approximately `20dp`
- same geometry in Light and Dark
- base liquid glass
- glossy/light-catching edge
- subtle soft shadow
- background remains visible through the bar

### Active destination

Keep the current filled-circle active destination concept as an explicit navigation exception to the generic selection-stroke rule.

- active circle: `48dp`
- active color from theme
- inactive destinations remain visually quieter
- selected navigation should look polished and intentional, not like a generic chip

---

## 15. Popup menus and bottom sheets

All popup menus, sheets, dropdown surfaces, and floating overlays use the same liquid-glass material.

Their depth level determines whether they use L1, L2, or L3 blur.

- do not invent a separate popup glass recipe
- contents must scroll when space is limited
- bottom sheets should remain usable on short screens and with large system fonts
- stacked sheet content follows inter-layer shadow rules

---

## 16. Typography

Typography geometry is shared across themes. Theme files only define text colors.

### 16.1 Font families

- English UI: **Plus Jakarta Sans**
- Arabic UI: **Dubai**
- Kurdish UI: current system fallback until the intended Kurdish font is bundled
- Approved onboarding/display exception: **Unbounded** may remain where already intentionally used

### 16.2 Semantic type scale

Use the same token names in both themes:

| Token | Size | Weight | Line height | Use |
|---|---:|---:|---:|---|
| `display` | 48 | 700 | 56 | large hero/onboarding display |
| `display-mobile` | 32 | 700 | 40 | compact display |
| `page-title` | 28 | 700 | 36 | main screen title |
| `section-title` | 20 | 600 | 28 | section heading |
| `card-title` | 18 | 600/700 | 24 | card title |
| `body-lg` | 16 | 400 | 24 | primary body |
| `body-sm` | 14 | 400 | 20 | secondary body |
| `label` | 12 | 600 | 16 | labels/metadata |
| `caption` | 12 | 400 | 16 | hints/captions |

Preserve the current visual typography as closely as possible when migrating existing screens. Normalize token names; do not arbitrarily resize every screen.

### 16.3 Text roles

Every text element must use a semantic role:

- heading/title
- body
- secondary/helper
- hint/placeholder
- link/action
- disabled
- error
- text-on-action
- text-on-glass

Theme files define the actual colors/opacity for those roles.

---

## 17. Spacing and layout

Use an `8dp` primary rhythm with `4dp` half-step support.

Recommended spacing tokens:

- `space-1: 4`
- `space-2: 8`
- `space-3: 12`
- `space-4: 16`
- `space-5: 20`
- `space-6: 24`
- `space-8: 32`
- `space-12: 48`

Do not invent arbitrary spacing values when an existing token works.

---

## 18. Responsive behavior

The same design system must work across phones, tablets, and wider layouts.

### Breakpoints

- Compact: `< 600dp`
- Medium: `600–839dp`
- Expanded: `>= 840dp`

### Compact

- 4-column layout logic where a grid is needed
- 16dp page side margin
- components stack vertically when necessary
- horizontal filters may scroll or wrap
- preserve 48dp minimum touch targets

### Medium

- 24dp page side margin
- use additional columns where content benefits
- maintain readable maximum card widths

### Expanded

- 12-column layout logic where appropriate
- centered content region
- recommended content max width: approximately `1200dp`
- do not scale every component proportionally; preserve ergonomic control sizes

Text may wrap or reflow. Do not solve responsiveness by shrinking text below the defined hierarchy.

---

## 19. Accessibility

### Minimum touch target

Every tappable control must provide at least `48 × 48dp` of hit area even when the visible control is smaller.

### Contrast

- body/important text should target at least 4.5:1
- do not darken text to compensate for a busy photo
- strengthen the local glass surface or local text scrim instead
- selected state must not rely on color alone when an additional check/icon can improve clarity, but the primary visual state must remain visible without the check

### Large text

- avoid fixed-height containers that clip text
- use wrapping and flexible layout
- modal content must scroll
- labels beside icons/actions must have room to shrink/wrap safely

---

## 20. RTL and directionality

The app supports LTR and RTL.

- leading/trailing layout mirrors automatically
- content order mirrors where language direction requires it
- forward chevrons mirror with direction
- rating values, star progress, OTP codes, phone/dial codes, and similar measurement/data sequences remain LTR
- back button remains physically top-left with a left chevron as an explicit approved exception
- avoid manually hard-coding left/right where `start/end` semantics are appropriate

---

## 21. Theme-specific values

This file must not duplicate Light/Dark color values.

Use:

- `DESIGN_LIGHT.md` for Light colors/tints
- `DESIGN_DARK.md` for Dark colors/tints

The theme files must expose the same token names one-for-one.

If a token exists in one theme but not the other, the design system is incomplete.

---

## 22. Prohibited legacy patterns

Do not reintroduce:

- Dark-only stronger background blur
- Dark-only stronger glass blur
- per-theme component radii
- green/emerald brand gradients as ordinary card/input fills
- fully opaque ordinary glass surfaces
- unselected accent strokes
- selection communicated only by a checkmark
- different input families on different screens
- flat frosted panels pretending to be liquid glass
- `BackdropFilter` + translucent fill + uniform border used as the complete glass implementation
- uniform bright borders with no directional rim/corner lighting
- ordinary glass surfaces with no visible sheen, inner glow, or optical depth
- Light input fields rendered as horizontal brand-gradient overlays instead of recessed glass
- fill-opacity ramps for stacked glass
- per-screen random glass recipes
- separate typography token names between themes
- old 50/80% overlay conflicts
- old 20/40 glass-blur conflicts
- screen-specific structural differences between Light and Dark

---

## 23. Implementation order for a redesign pass

When applying these files to an existing codebase:

1. update theme tokens
2. update background component
3. update base liquid-glass component
4. update stacked glass support
5. update input component
6. update button components
7. update selection/focus state handling
8. update shared cards
9. update filters
10. update icon containers
11. update bottom navigation
12. update popup/bottom-sheet surfaces
13. migrate existing screens to shared components
14. audit Light/Dark parity
15. visually compare against approved screenshots

Do not rewrite backend logic, navigation logic, validation logic, localization, or data behavior unless a UI requirement directly requires a presentation-layer change.
