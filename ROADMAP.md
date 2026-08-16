# ROADMAP.md — Page-by-Page Build Order (Mobile App)

Rule: build only the page marked "IN PROGRESS." Do not start the next page
until the current one is marked "APPROVED" in `PROGRESS.md`.

Every page below that reads from Firestore also requires one seeded
example document, confirmed rendering live, and matching security rules
tested — see `CLAUDE.md`, `SECURITY.md`, and `SEED_DATA.md`.

Status legend: `NOT STARTED` / `IN PROGRESS` / `APPROVED`

## Phase 0 — Foundation (do this before any real page)
- [ ] Firebase project created (dev + prod environments)
- [ ] Firestore, Auth, Storage, Functions enabled
- [ ] Firestore/Storage set to deny-by-default (not left in test mode)
- [ ] Design finalized externally, handed over as `DESIGN_SYSTEM.md`
      (both light and dark values)
- [ ] `DATA_MODEL.md` first draft written and approved (copy to admin
      panel repo too)
- [ ] `SECURITY.md` reviewed — confirm the admin custom-claim setup will
      exist before the admin panel needs it (built in the other project)
- [ ] Base Flutter project scaffolded (folder structure, theming
      boilerplate supporting light+dark via ColorScheme, Firebase config
      wired up, no real screens yet)

## Phase 1 — Onboarding & Auth flow

Order matters here — build and approve in this exact sequence:
1. **Splash screen** (logo) — same as the earlier prototype version
2. **Language selection screen** — same as the earlier prototype version
3. **Onboarding screen** — one screen containing an internal 3-slide
   swiper (confirmed: not 3 separate pages)
4. **Login/Auth screen** — a new design, different from the earlier
   prototype's version. Do not reuse that layout; wait for the uploaded
   reference screenshot + info for this screen specifically. Must
   include: full registration info capture, email verification, phone/
   SMS verification, and authenticator app (TOTP) enrollment — see
   `SECURITY.md` section 6 for the full spec, and build/test both
   Android and iOS platform-specific setup (they are not automatically
   equivalent).
5. **Welcome/tagline transition screen** — shown after login, before the
   dashboard (as in the earlier prototype)

- [ ] Splash screen
- [ ] Language selection screen
- [ ] Onboarding screen (3-slide swiper) — IN PROGRESS. All three slides
      have localized copy, entry/exit motion, the shared panning panorama,
      and scroll-linked aircraft motion. Awaiting final review/approval.
- [ ] Auth screen (Firebase Auth: sign up / log in, new design, full
      registration info + email + SMS + TOTP verification, tested on
      both Android and iOS)
- [ ] Welcome/tagline transition screen

## Phase 2 — Core navigation shell
- [ ] Main dashboard (home tab) — IN PROGRESS. Built from the `main screen`
      reference: top bar, time-based greeting, featured carousel reading
      `featured`, five "plan your journey" cards, floating glass bottom nav.
      Light + dark, all three languages. Awaiting review/approval; still
      needs the five per-card photos and a live Firebase project.
- [ ] Side drawer (profile header, services menu, settings, logout) — the
      hamburger is in place; Currency writes `users.preferredCurrency`,
      **Billing/Payments** opens its secure no-card empty state, and Policy / Help
      open their hubs. **Settings** now opens its localized account/preferences/
      security hub, and **My Bookings** opens its ticket list. About Us and
      Contact Way remain inert
- [x] Bottom navigation (Home / Trips / Map / Saved) — built as part of the
      dashboard. Home is the only destination with a screen; Map opens the
      platform maps app; Trips and Saved say "coming soon" until Phase 8

## Phase 3 — Explore Nature
- [ ] Explore Nature list screen (reads from Firestore `nature_spots`) —
      IN PROGRESS. Built from the `explore nature.jpg` reference: back button,
      a carousel of highlighted places, multi-select filter chips (Hiking /
      Beach / Sunset View / Customize) and a card per place with score, stars,
      location, live distance and description. Light + dark, all three
      languages. Awaiting review/approval; still needs the place photographs
      and a live Firebase project.
- [ ] Customize Filters screen — IN PROGRESS. Built from the
      `explore nature-filters.jpeg` reference: title row, live selection
      counter with Reset All, a Place Type group (8 chips) and a Facilities &
      Amenities group (7 chips), and an apply button carrying the live match
      count. Light + dark, all three languages. Awaiting review/approval.
- [ ] Spot detail screen — IN PROGRESS. Selected-place cover background and
      gallery, rating badges, localized overview, nearby stays, map, live
      coordinate weather, and two newest visitor reviews are implemented in
      light/dark mode. A reference-match pass (2026-08-15) added the `Name:` /
      `Distance:` labels, headed the weather card with the place name, and made
      the map preview actually open the shared `MapScreen` on this place — it
      was previously announced as a button while doing nothing. Awaiting review,
      real Storage photos, Firebase deployment, and device verification.
- [ ] Reviews & Ratings screen — IN PROGRESS. Built from the
      `explore nature - comment.png` reference, opened by the detail screen's
      review card (previously "coming soon"). Hero with the back button and
      title on one line and the place name/location at its foot; an Average
      Rating card with the server-derived score, the real review count and the
      5★→1★ bars; a sortable, paginated review list with helpful-vote hearts;
      and a composer with half-star input. Light + dark, all three languages.
      Reviews became **half-star (0.5–5)**, and `reviewScore` / `ratingCount` /
      the new `ratingBreakdown` became **server-owned**, derived by two new
      Cloud Function triggers. Awaiting review/approval; still needs a live
      Firebase project, the functions deployed, the seeded reviews confirmed
      rendering, and the rules denial-tested.

## Phase 4 — Where to Stay
- [ ] Where to Stay search/filter screen (reads from Firestore `hotels`)
- [ ] Hotel detail screen
- [ ] Room selection screen

## Phase 5 — Car Rental
- [ ] Car Rental search/filter screen (reads from Firestore `cars`)
- [ ] Car search results screen
- [ ] Car booking/options screen

## Phase 6 — Explore Tours
- [ ] Explore Tours screen (reads from Firestore `tours`)
- [ ] Tour detail/booking screen

## Phase 7 — Flight Ticketing
- [ ] Flight Ticketing search screen
- [ ] Flight results screen

## Phase 8 — Account features
- [ ] My Bookings (real data — bookings made across hotels/cars/tours/flights)
      — IN PROGRESS. Built from the `my bookings.jpg` reference: back button,
      title, an Upcoming/Past/Cancelled segmented control, the reference's five
      type chips, and a per-product ticket card (photo + wavy seam for hotel/
      car/tour; boarding pass with a real Code128 barcode for flights). Reads
      `bookings` with owner-only rules; loading/error/empty/guest states all
      handled. Light + dark, all three languages. Awaiting review/approval;
      still needs a live Firebase project, the seeded documents confirmed
      rendering, the rules denial-tested, and the card photographs.
      **Note:** nothing in the app can *create* a booking until Phases 4–7
      exist, so `tool/seed_bookings.js` is the only writer for now.
- [ ] Favorites
- [ ] Settings (Billing/Payment, Policy, Help/Support, About Us,
      Contact Way — build out one at a time)
  - [x] **Settings hub** — Profile, Account, Preferences, and Security & legal
        groups built from the supplied reference in light/dark and all three
        languages. Notification and theme preferences work and persist locally;
        logout works. Editing, language/currency/units, privacy, and deletion
        rows remain explicit placeholders until their dedicated flows exist
  - [ ] **Policy hub** — IN PROGRESS. Built from the `Policy of App`
        reference: title + hint and seven glass rows (the six drawn, plus
        Account & Data Deletion, which both app stores require). Light +
        dark, all three languages. Every row is inert ("coming soon") because
        the documents behind them have not been written. Awaiting approval.
  - [ ] **All seven policy documents** — IN PROGRESS. One screen
        (`PolicyDocumentScreen`) parameterised by `PolicyTopic`: title,
        "Last updated", and one glass card holding the document (optional
        lead-in paragraph, headings, bullets with bold lead-ins). Each reads
        `legal_documents/{docId}` from one bundled/seeded JSON source of
        truth. Light + dark, all three languages. Awaiting approval; still
        needs a live Firebase project, legal sign-off, and the
        [square-bracket placeholders] filled in
  - [ ] **Account deletion backend** — the Settings menu item now exists, but
        its destructive backend does not.
        Must be a **Cloud Function** (cascades through `users`, `bookings`,
        `favorites`, Storage avatars), never a client-side delete. **Both app
        stores require this**, so it is a release blocker
  - [x] **Help & Support screen** — Built from the
        `Help & Support` reference: back button and title on one line, then
        ten glass rows with a stroke-only circled icon, a title, a truncated
        question preview and an animated accordion chevron. The supplied
        English Q&A is bundled for the first nine rows; the tenth says "Coming
        soon." Kurdish/Arabic retain localized row chrome and use the English
        body fallback until translated Q&A is supplied. A future
        `help_topics` collection remains approved for live/admin-managed copy
- [ ] Profile picture upload (Firebase Storage)

## Phase 9 — Polish & hardening
- [ ] Work through the full pre-launch checklist in `SECURITY.md` section 10
- [ ] Firestore security rules review, end to end
- [ ] Loading/error/empty states audit across all screens
- [ ] Performance pass (pagination on long lists, image caching)
- [ ] Verify both light and dark mode across every screen, not just the
      first few built
- [ ] App icon, splash branding, store listing assets
- [ ] Privacy policy page live (required for both app stores)

---

Note: the admin/data-entry web panel has its own project, its own
`CLAUDE.md`, and its own roadmap — see the companion `admin-panel/` doc
set, not this file.
