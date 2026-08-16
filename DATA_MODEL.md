# DATA_MODEL.md — Firestore Schema (draft, refine with your agent in Phase 0)

Every document includes: `id`, `createdAt`, `updatedAt`, `source`
(`"manual"` | `"api"`), `createdBy`. Omitted below for brevity — assume
they're on every collection.

## `users`
| field | type | notes |
|---|---|---|
| name | string | The user's display name, and — with `email` — the whole of their identity in this app |
| email | string | matches Firebase Auth |
| emailVerified | boolean | mirrors Firebase Auth's own verification state. Written only by `confirmRegistrationEmailCode` / `confirmEmailChangeCode` under the Admin SDK; never client-writable (a client that could set it would be claiming a verification it never passed) |
| phone | string | |
| phoneVerified | boolean | |
| mfaEnrolled | boolean | true once at least one second factor is set up |
| mfaMethods | array<string> | which second factors are enrolled, e.g. `["sms"]`, `["totp"]`, or both |
| profileImageUrl | string | Firebase Storage download URL. The file lives at `profile_images/{uid}/avatar.jpg` — a fixed name per user, so re-uploading replaces the old picture rather than orphaning files. Set by the Account Setup screen |
| dateOfBirth | timestamp | set at registration. Stored as a **date**, not an age, so it never goes stale and an 18+ check stays correct over time |
| gender | string | `"male"` \| `"female"` \| `"other"`. **Optional** — absent when the user skips it (`SECURITY.md` 9: don't collect more than needed) |
| termsAcceptedAt | timestamp | when the user accepted on the Terms of Service screen. Required evidence for App Store / Play review |
| termsVersion | number | **which version** of the terms they accepted, from `legal_documents/terms_of_service.version`. A timestamp alone can't tell you whether someone agreed to the current wording or last year's — this is what lets you re-prompt only the users who haven't seen the latest text |
| preferredLanguage | string | `en` / `ku` / `ar` |
| preferredCurrency | string | `"USD"` \| `"IQD"` \| `"EUR"`. Defaults to `USD` client-side when absent — no migration needed for existing accounts |
| hasPaymentMethod | boolean | **Server-owned**, optional, defaults to `false`. Set only after the payment processor confirms that at least one reusable method exists; controls whether the Billing/Payment empty state applies. This is a summary flag only—never store a card number, CVC, or raw payment token in `users` |
| role | string | `"user"` \| `"admin"` |
| passwordChangedAt | timestamp | *when* the password last changed — never the password itself. Written only by Cloud Functions (`confirmPasswordResetWithCode` / `recordPasswordChange`); lets Settings show "last changed" and lets tokens issued before a reset be rejected |

Note: `emailVerified`/`phoneVerified`/MFA enrollment state ultimately
lives in Firebase Auth itself (the source of truth) — these Firestore
fields are a convenience mirror for querying/display, not a replacement
for checking the real Firebase Auth state before granting access to
anything sensitive.

Settings that affect only this installation — notification opt-in, theme, and
units until cross-device sync is explicitly required — belong in device-local
`SharedPreferences`, not in `users`. The current Settings implementation adds
no Firestore fields, rules, indexes, or migration. Language already uses the
existing app locale preference; currency remains the existing
`users.preferredCurrency` account preference.

### Saved payment methods

The Billing & Payments saved-card carousel does **not** introduce card fields
on `users` and needs no Firestore migration. When a payment provider is wired
in, a callable Cloud Function must list that provider customer's reusable
methods and return only presentation-safe metadata (`providerMethodId`, brand,
bank label when available, last four digits, expiry month/year, and default
status). PAN and CVC never enter Firestore. Add/change/delete operations must go
through the provider and then update the server-owned `hasPaymentMethod`
summary. The current carousel is design-only fixture data until that endpoint
exists.

**Which fields the client may write.** The Register screen creates this
document from the app, so `firestore.rules` restricts both create and update
to an explicit allow-list: `name`, `email`, `phone`, `dateOfBirth`, `gender`,
`profileImageUrl`, `preferredLanguage`, `termsAcceptedAt`, `createdAt`,
`updatedAt`, `source`. Everything else — **`role`, `emailVerified`,
`phoneVerified`, `mfaEnrolled`, `mfaMethods`, `passwordChangedAt`** — is
writable only by Cloud Functions via the Admin SDK. Without that restriction
a modified client could simply write `role: "admin"` to its own document and
grant itself the admin panel.

## `password_reset_codes` *(server-only — added for the Verification Code screen)*

Backs the **email** branch of the password-reset code flow. Firebase Auth's
built-in `sendPasswordResetEmail()` sends a *link*, not a code, so a 6-digit
email code has to be issued and checked by our own Cloud Functions.
The **phone/SMS** branch needs no collection at all — Firebase Auth generates
and verifies that code itself.

Document id = SHA-256 of the lowercased email (non-reversible, non-enumerable).
**No client access in either direction** — only the Admin SDK inside Cloud
Functions touches it (see `firestore.rules`).

| field | type | notes |
|---|---|---|
| codeHash | string | salted SHA-256 of the 6-digit code. The plaintext code is never stored |
| salt | string | random per-code salt |
| expiresAt | timestamp | 10 minutes after issue |
| attempts | number | failed verify attempts; 5 max, then locked out |
| lastSentAt | timestamp | enforces the 60s resend cooldown server-side |
| resetTokenHash | string | set only after a correct code; hash of the short-lived token the Set New Password screen will exchange |
| resetTokenExpiresAt | timestamp | 10 minutes after issue |

Note: this collection deliberately does **not** carry the standard
`id`/`createdBy`/`source` envelope — it holds no user-authored content, is
never listed or queried, and is deleted/overwritten per reset attempt.

## `email_change_codes` *(server-only)*

Backs the authenticated change-email flow. Document id = the signed-in user's
UID. The user must reauthenticate before requesting a code, and the callable
functions reject sessions whose `auth_time` is more than 10 minutes old.
Clients have **no direct read or write access**.

| field | type | notes |
|---|---|---|
| newEmail | string | normalized proposed address; never copied to the profile before verification |
| codeHash | string | salted SHA-256 of the six-digit code; plaintext is never stored |
| salt | string | random per-code salt |
| expiresAt | timestamp | 10 minutes after issue |
| attempts | number | failed verify attempts; 5 max |
| lastSentAt | timestamp | enforces the 60-second resend cooldown |
| verifying | boolean | transaction lock preventing concurrent code consumption |
| createdAt | timestamp | issue time |

## `email_verify_codes` *(server-only — added for the registration email step)*

Backs the six-digit email verification that now gates registration. Document
id = the signed-in user's UID. Clients have **no direct read or write access** —
note that because the id *is* the uid, allowing read would let a signed-in user
simply fetch their own pending code instead of receiving it by email, which
defeats the entire verification.

Same shape and the same guarantees as `email_change_codes`, with one important
difference: **the destination address is read server-side from Firebase Auth**,
never taken from the request, so a client cannot aim a registration code at an
address it does not own.

| field | type | notes |
|---|---|---|
| email | string | the account's own address, read from Firebase Auth — not client-supplied |
| codeHash | string | salted SHA-256 of the six-digit code; plaintext is never stored |
| salt | string | random per-code salt |
| expiresAt | timestamp | 10 minutes after issue |
| attempts | number | failed verify attempts; 5 max |
| lastSentAt | timestamp | enforces the 60-second resend cooldown |
| verifying | boolean | transaction lock preventing concurrent code consumption |
| createdAt | timestamp | issue time |

Written by `sendRegistrationEmailCode`; consumed and deleted by
`confirmRegistrationEmailCode`, which then sets `emailVerified` on both
Firebase Auth and `users/{uid}`.

## ~~`usernames`~~ — removed

The app no longer has usernames. A user is identified by their **display name
and email** alone, so there is no globally unique handle left to reserve.

Removed together:

- the `usernames/{normalizedUsername}` collection
- `users.username` and `users.usernameNormalized`
- the `claimUsername` Cloud Function
- the Change User Name row in Settings and its screen

The collection has no rule in `firestore.rules` any more; deny-by-default
(`SECURITY.md` 1) covers it. **If a deployment already ran the old function**,
drop the `usernames` collection and delete both fields from existing `users`
documents — nothing reads them.

## `mail` *(server-only — added for the Verification Code screen)*

Outbound email queue consumed by the **"Trigger Email from Firestore"**
Firebase Extension, which holds the SMTP credentials in extension config so
no secret lands in this repo (`SECURITY.md` section 4). Written only by
Cloud Functions; **no client access** — client write access would let anyone
send mail from the project's verified sender address.

| field | type | notes |
|---|---|---|
| to | array<string> | recipient address |
| message | map | `{subject, text, html}` — the extension's own schema |

## `legal_documents` *(added for the Terms of Service screen)*

Versioned legal text — **seven documents**, one per row on the Policy hub
(see the table further down). Held in Firestore rather than bundled in the app
so the wording can be updated from the admin panel without an App Store / Play
release, which is exactly what the Terms text itself promises ("we reserve the
right… to change… at any time"). A store release can take days; a legal
correction shouldn't wait.

**Single source of truth for the wording:**
`assets/legal/legal_documents.json`. The app bundles it (preview mode serves
it before Firebase exists) and `tool/seed_legal_documents.js` reads the same
file off disk to write Firestore. Nothing is retyped, so the two cannot drift;
a test asserts every document has all three languages with identical structure.
**Edit that file, never a Dart or JS copy.**

**Public read (including unauthenticated), admin-only write.** A user must be
able to read the terms before they have an account. If the client could write
here, it could rewrite the agreement it is about to accept.

| field | type | notes |
|---|---|---|
| version | number | bump on every wording change; consent is recorded against it in `users.termsVersion` |
| updatedAt | timestamp | shown as "Last updated" at the top — the body text refers to this date, so it has to exist |
| legalReviewed | boolean | false until a qualified translator/lawyer signs off. While false the app shows a visible warning banner |
| content | map | keyed by locale: `{ en: {sections: [...]}, ku: {...}, ar: {...} }` |
| content.{locale}.sections | array | ordered sections — **two accepted shapes**, see below |

### Section shapes — `{heading, body}` and `{heading?, blocks}`

`terms_of_service` was written as `{heading, body}`, two plain strings. The
Privacy Policy needs an untitled lead-in paragraph, bullet lists, and bold
lead-ins inside a bullet, none of which two strings can express — so a second
shape was added. **Both parse**; the old documents did not have to be
migrated, and `LegalSection.body` still returns the same string for them.

| field | type | notes |
|---|---|---|
| heading | string | **Optional** in the block shape — omit it for a lead-in paragraph that precedes the first titled section. Required in the legacy shape |
| body | string | Legacy shape only. Becomes a single paragraph block |
| blocks | array | Block shape. An empty/unparseable block is dropped, never drawn as a blank line |
| blocks[].type | string | `"paragraph"` \| `"bullet"`. Anything else is treated as a paragraph |
| blocks[].lead | string | **Optional.** The bold run at the start of a bullet, e.g. `"Account & contact details:"`. A separate field rather than a `**marker**` inside `text`, so nothing is parsed at render time — a typo can't silently break the formatting, and RTL bullets don't depend on a parser knowing which end of the string the bold run is on |
| blocks[].text | string | Required and non-empty. Drawn after `lead`, with a space between |

**The admin panel needs a block editor for this**, not a plain textarea: a
repeatable list of sections, each with an optional heading and a repeatable
list of paragraph/bullet rows (bullets having an optional lead field).

One read serves all three languages. A missing locale falls back to `en` so
the legal page is never blank.

### One document per Policy screen row

The Policy hub lists seven categories. Every one is the same shape —
versioned, localized, ordered sections — so they all live in **this
collection**, not a new one and not as fields on anything else. All seven are
written and all seven rows open.

| doc id | Policy screen row | version |
|---|---|---|
| `terms_of_service` | Terms & Conditions | **2** |
| `privacy_policy` | Privacy Policy | 1 |
| `cancellation_refunds` | Cancellation & Refunds | 1 |
| `payment_policy` | Payment Policy | 1 |
| `liability_disclaimer` | Liability & Disclaimer | 1 |
| `contact_complaints` | Contact & Complaints | 1 |
| `account_data_deletion` | Account & Data Deletion | 1 |

The ids are fixed in code, in `lib/models/policy_topic.dart`
(`PolicyTopic.docId`), so the app, the seed script and the admin panel cannot
drift on the naming. A test asserts the bundled asset covers exactly these
seven — no missing id, no orphan.

> **`terms_of_service` is at version 2, and that matters.** The Policy hub's
> "Terms & Conditions" row and the registration consent gate read the **same
> document** — deliberately, so a user can never accept one wording and read
> another. Its text was replaced wholesale at v2, so **anyone who accepted v1
> has not accepted the current wording** and must be re-prompted. Nothing is
> live yet, so there is no migration to run; the rule matters from first
> release onward.

**The admin panel needs a document picker rather than a hardcoded "Terms"
form**, plus a block editor (see the section shapes above) rather than a plain
textarea.

Two rows are more than text and still need their own decisions:

- **Contact & Complaints** is currently contact details only, so it stays a
  plain document. If it becomes a complaint *form*, it needs a `complaints`
  collection with owner-only read and create — see `SECURITY.md` section 1.
- **Account & Data Deletion** currently *describes* deletion; it does not
  perform it. The document promises an "in-app: Menu → Delete Account" route
  that **does not exist yet**. Building it cannot be a client-side delete:
  erasing a user has to cascade through `users`, `bookings`, `favorites` and
  Storage avatars, which a client must never be allowed to do. It belongs in a
  **Cloud Function**, with the screen only requesting it.

Both app stores require a working in-app deletion route for any app with
sign-up, so the second one is a release blocker, not a nice-to-have — the page
describing it is not the same as the page doing it.

## `help_topics` *(approved live source; bundled fallback is implemented)*

The ten categories on the Help & Support screen. **Confirmed to live in
Firestore**, for the same reason as `legal_documents` and more urgently:
support answers change far more often than legal text, and fixing a wrong
answer should not wait for an App Store release.

The screen currently expands bundled English fallback Q&A in place. The tenth
contact row intentionally says “Coming soon.” This collection remains the live
source planned for admin-managed updates and translated content; when seeded,
missing locales fall back to the same bundled English copy.

**Public read (including unauthenticated), admin-only write.** A user who
cannot sign in is exactly the person who needs the help centre, so it cannot
require auth. Rules will match the `legal_documents` pattern.

| field | type | notes |
|---|---|---|
| order | number | ascending display order, so the admin panel can reorder rows without a release |
| active | boolean | false hides a topic without deleting it |
| content | map | keyed by locale: `{ en: {...}, ku: {...}, ar: {...} }`. Missing locale falls back to `en`, same rule as `legal_documents` |
| content.{locale}.questions | array<{question, answer}> | the Q&A pairs shown when the row expands |

Document ids are fixed in `lib/models/help_topic.dart` (`HelpTopic.docId`):
`account_signin`, `bookings_confirmation`, `payments_refunds`,
`cancellation_changes`, `flights`, `stays_hotels`, `car_rental`,
`tours_nature`, `safety_travel_info`, `contact_support`.

Open questions, to settle when the content arrives:

- **The row titles and preview lines are currently app strings**, not
  Firestore — they are in `app_localizations.dart` like every other piece of
  UI copy. If the admin panel should rename a topic without a release, they
  have to move into this collection too. Decide before seeding.
- **`contact_support` is not a Q&A topic** — it is a route to a human (email,
  phone/WhatsApp, hours). It may need a different shape from the other nine,
  or may be better served by reading the contact details already in
  `legal_documents/contact_complaints` so the two cannot disagree.
- **Answers that restate policy** (refund timing, baggage, cancellation) risk
  drifting from `legal_documents`. Prefer linking to the policy page over
  duplicating its wording.

## `featured` *(added for the Home screen)*

The home screen's carousel — the four slides at the top of the dashboard.
A **curated collection** rather than a query across `nature_spots` / `cars` /
`tours` / `flights`, for three reasons: one read instead of four, the admin
panel controls exactly what appears and in what order, and a single slide can
point at any entity type without the client knowing which collections exist.

**Public read (including unauthenticated), admin-only write.** The dashboard
is fully browsable by a guest, so the carousel cannot require auth; a client
that could write here could put anything on the app's front page.

| field | type | notes |
|---|---|---|
| type | string | `"nature_spot"` \| `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` — which collection `referenceId` points into |
| referenceId | string | id of the document in that collection, so Explore can open the right detail screen |
| title | map | keyed by locale: `{ en, ku, ar }`. A **map, not a string** — the app is trilingual and switching language must not cost a second read. Missing locale falls back to `en` |
| subtitle | map | same shape; the location/context line, e.g. "Erbil • Nature escape" |
| imageUrl | string | Firebase Storage download URL for the slide photo |
| rating | number | 0–5, shown as a star pill. **Optional** — absent hides the pill rather than drawing a zero, since an unrated item is not a badly rated one |
| order | number | ascending display order |
| active | boolean | false pulls a slide off the front page without deleting it |

Query: `.where('active', == true).orderBy('order').limit(8)`. That
combination needs a **composite index** — already declared in
`firestore.indexes.json`.

## `nature_spots`

**Revised for the Explore Nature list screen (Phase 3).** Three fields changed
shape and five were added; nothing had been seeded yet, so there is no
migration to run — but the admin panel's nature-spot form must match this.

| field | type | notes |
|---|---|---|
| name | map | keyed by locale: `{ en, ku, ar }`. **Changed from a plain string** — the app is trilingual and switching language must not cost a second read, the same rule `featured` and `legal_documents` already follow. Missing locale falls back to `en` |
| description | map | same shape. Shown clipped on the card, in full on the detail screen |
| locationLabel | map | same shape. The readable place line, e.g. "Erbil, Iraq". **New** — a geopoint cannot be shown to a user, and a label cannot be measured against, so the collection needs both |
| imageUrls | array<string> | Storage download URLs. The first is the list-card thumbnail |
| location | geopoint | used to compute the live distance; never displayed directly |
| reviewScore | number | 0–10, Booking.com-style. **Replaces `rating` (0–5)** for this collection. The 5-star row on the card is **derived** (`round(score / 2)`), never stored — one number to enter, and the two can never disagree. Optional: absent hides the score/star badges rather than drawing a zero. **Server-owned since the Reviews & Ratings screen** — see below |
| ratingCount | number | how many reviews `reviewScore` averages — an 8.7 from one review is not an 8.7 from two hundred. **Server-owned**; it is the "N reviews" figure printed on the Reviews & Ratings screen |
| ratingBreakdown | map | **Added for the Reviews & Ratings screen.** `{ "1": n, "2": n, "3": n, "4": n, "5": n }` — the 5★→1★ bars beside the average. **Server-owned.** A rating falls in `round(rating)`, so a 3.5 counts in the 4-star bar |
| categories | array<string> | **New.** The quick chips on the list screen — *what you do there*: `"hiking"`, `"beach"`, `"sunset_view"` |
| placeTypes | array<string> | **Added for the Customize Filters screen.** *What the place is*: `"forest"`, `"mountain"`, `"canyon"`, `"park"`, `"lake"`, `"waterfall"`, `"river"`, `"museum"`. A separate array from `categories` because it answers a different question — a waterfall you can hike to is tagged in both |
| amenities | array<string> | **Added for the Customize Filters screen.** `"parking"`, `"restrooms"`, `"restaurants"`, `"cafes"`, `"mobile_signal"`, `"lodging_nearby"`, `"atm_nearby"` |
| nearbyStays | array<map> | Up to three curated accommodation previews: `{ id, name: {en,ku,ar}, imageUrl, distanceKm, reviewScore }`. Price and availability belong to the live hotel flow |
| highlighted | boolean | **New.** True puts the spot in the screen's top carousel |
| highlightOrder | number | **New.** Ascending order within that carousel |
| active | boolean | **New.** False pulls a spot off the list without deleting it — same flag, same purpose as `featured.active` |

> `distanceLabel` is **removed**. The card says "from current location", so the
> distance is computed client-side from `location` and the device's GPS fix
> (`DeviceLocationService`). When location is off, denied, or unavailable, the
> Distance row is **hidden** — a stored label would have made that line a lie.

Only two queries are ever run, both with a composite index declared in
`firestore.indexes.json`:

```
carousel:  .where('active', == true).where('highlighted', == true)
             .orderBy('highlightOrder').limit(8)
catalog:   .where('active', == true)
             .orderBy('reviewScore', desc).limit(200)
```

### Why every filter is applied in Dart, not in the query

**Revised when the Customize Filters screen was added.** The list screen now
has *three* independent multi-select dimensions — `categories`, `placeTypes`,
`amenities` — and **Firestore permits only one array clause per query**
(`array-contains`, `array-contains-any` and `in` all share that limit). A
single query cannot express "any of these place types AND any of these
facilities" at all.

On top of that, the Customize screen's apply button reads "Show 32 Places" and
has to be exact and update on every chip tap. A server-side count would mean a
`count()` aggregation per tap.

So the catalog is read **once**, and `NatureFilters.matches` applies all three
dimensions in memory. One read serves the list, the filters and the counter,
and toggling a chip costs nothing.

**Semantics: OR within a group, AND across groups.** Selecting Forest and
Waterfall widens the results to places that are either; adding Restrooms then
narrows to those that also have restrooms. An empty group means "no filter",
not "match nothing".

> **When this stops being right.** The catalog is capped at
> `NatureSpotsService.catalogFetchLimit` (200 documents), which is both the read
> cost and the ceiling on what the filters can search. That is comfortable for a
> regional guide. If `nature_spots` heads toward four figures, move `placeTypes`
> to a server-side `array-contains-any` and keep only `amenities` client-side,
> and accept an approximate count on the button — or move filtering to a search
> service. This is a deliberate trade recorded here, not an accident.

> The Home screen runs a `count()` **aggregation** against this collection for
> the "N+ places" button. That needs `list` permission in the rules (granted:
> catalog data is public read), and is billed at one read per 1000 documents
> rather than one per document. The count is **unfiltered**, so it still works
> unchanged against the revised schema.

### The three aggregates are server-owned — the admin panel must not edit them

**Revised for the Reviews & Ratings screen.** `reviewScore`, `ratingCount` and
`ratingBreakdown` are no longer values anyone types. The
`syncNatureReviewAggregates` Cloud Function (`functions/index.js`) recomputes
all three from the `reviews` subcollection whenever a review is written.

Why it has to be the server: `nature_spots` is **admin-only write**
(`SECURITY.md` 1), and it must stay that way — a client that could write the
average score of a place could give a competitor a 2.0 without leaving a
review. So the client writes only its own review document, and the aggregates
are derived from it.

Why it **recomputes** rather than incrementing: Cloud Functions triggers are
*at-least-once*, so a duplicate delivery is a documented guarantee rather than
a rare fault. An `increment(1)` applied twice corrupts the count permanently
with nothing in the data to show it happened; a recompute applied twice gives
the same answer and repairs any earlier drift. It also makes seeding work —
`tool/seed_explore_nature.js` writes reviews and no aggregates at all, and
whatever order the writes land in, the last trigger leaves the right totals.

> **When this stops being right.** Each review write costs one read per
> existing review on that place. Comfortable into the low thousands. Past
> that, move to a sharded counter keyed by the event id for idempotency, and
> keep the recompute as a scheduled repair job.

**Consequences for the admin panel:** show these three **read-only**. A
hand-typed average is overwritten by the next review posted, so an editable
field there is a bug that looks like a feature.

### `nature_spots/{spotId}/reviews/{reviewId}`

Public visitor feedback. The detail page reads the two newest published
reviews; the Reviews & Ratings page reads them a page of 10 at a time, in one
of four orders.

**The document id is the author's uid.** That is what makes "one review per
person per place" a rule rather than a hope: without it a client could post the
same review a hundred times and drag the average wherever it liked, and no rule
could tell that apart from a hundred honest visitors. It also means a returning
author *edits* their review instead of stacking a second one on the same place.

| field | type | notes |
|---|---|---|
| userId | string | immutable owner UID; equals the document id |
| userName | string | denormalized display name, max 80 characters. Copied, not joined — a review must keep showing who wrote it after that account is renamed or deleted, the same rule `bookings.display` follows |
| avatarUrl | string | optional presentation-only URL |
| rating | number | **0.5–5.0 in half-star steps.** Changed from an integer 1–5: the design draws half stars, and an integer cannot hold a 3.5. Shown as `rating × 2` out of 10, so 4.5 reads as 9.0 / 10. Rules reject anything off the half-step grid, because it is a value no UI in this app can produce |
| comment | string | 3–1000 characters |
| helpfulCount | number | **Added for the Reviews & Ratings screen. Server-owned** — the heart count, recomputed by `syncReviewHelpfulCount` from the `votes` subcollection. On no client allow-list: a client that could write it would be declaring its own review the most helpful on the page |
| status | string | `published`; retained for moderation visibility |
| createdAt / updatedAt | timestamp | `createdAt` is pinned by the rules on update, so an author cannot re-date an old review to push it back to the top of "Most recent" |

Four query orders, each with its own composite index in
`firestore.indexes.json` — `createdAt`, `rating` (both directions) and
`helpfulCount`, all after `status == 'published'`, all with `createdAt` as the
tie-break. **Ordering is done in the query, not in Dart**, because the list is
paginated: sorting a downloaded page would rank the newest ten reviews and
present them as the highest rated of all 128.

#### `nature_spots/{spotId}/reviews/{reviewId}/votes/{voterId}`

"I found this review helpful", one document per person, keyed by their uid.

| field | type | notes |
|---|---|---|
| userId | string | equals the document id and `request.auth.uid` |
| createdAt | timestamp | |

A **document** rather than a counter the client increments, for the same reason
the review id is the uid: a document keyed by the voter physically cannot be
cast twice, whereas an increment can be sent in a loop. `list` is denied — the
screen reads only the viewer's own vote, by known id, and enumerating votes
would turn "helpful" into a public record of who read what.

> The viewer's votes for a page cost one small read per review shown (10).
> That is the price of not granting `list`; it is the right trade.

Weather is not stored in Firestore. It is fetched from Open-Meteo using the
place geopoint so the detail card cannot show stale catalog temperatures.

## `hotels`
| field | type | notes |
|---|---|---|
| name | string | |
| address | string | |
| city | string | |
| location | geopoint | |
| imageUrls | array<string> | |
| starRating | number | 0-5 |
| reviewScore | number | 0-10 |
| pricePerNightFrom | number | for list-card display |
| amenities | array<string> | e.g. Pool, Bar, Restaurant, Parking |

### `hotels/{hotelId}/rooms` (subcollection)
| field | type | notes |
|---|---|---|
| name | string | e.g. "Ocean View Suite" |
| bedConfiguration | array<{type, count}> | |
| sizeSqm | number | |
| facilities | array<string> | |
| pricingOptions | array<{title, infoLines, pricePerNight}> | |
| availableCount | number | |

### `hotels/{hotelId}/reviews` (subcollection)
| field | type | notes |
|---|---|---|
| userId | string | |
| name | string | |
| comment | string | |
| stars | number | |

## `cars`
| field | type | notes |
|---|---|---|
| name | string | |
| year | number | |
| rentalCompany | string | |
| companyTag | string | |
| imageUrls | array<string> | |
| capacity | number | |
| fuelType | string | |
| bags | number | |
| hasAC | boolean | |
| paymentInfo | string | |
| location | geopoint | |
| pricePerDay | number | |

## `tours`
| field | type | notes |
|---|---|---|
| name | string | |
| duration | string | e.g. "3 days travel" |
| description | string | |
| imageUrls | array<string> | |
| companyTag | string | |
| features | array<string> | e.g. Camping, Food, Transport |
| location | geopoint | |
| pricePerPerson | number | |

## `flights`
| field | type | notes |
|---|---|---|
| airline | string | |
| fromAirportCode | string | |
| toAirportCode | string | |
| departTime | timestamp | |
| arriveTime | timestamp | |
| durationMinutes | number | |
| price | number | |
| cabinClass | string | Economy / Premium Economy / Business / First |

## `bookings`

**Substantially expanded for the My Bookings screen (Phase 8).** The original
eight-field draft could not render a single card: it had no title, no image, no
dates, no guest count and no human-readable reference. Nothing has been seeded
yet, so there is no migration — but the admin panel and the future checkout
Cloud Function must both write this shape.

### Rule: a booking is a historical record, so it is denormalized

The card's title, photo, location and dates are **copied onto the booking
document** at purchase time rather than read from `hotels` / `cars` / `tours` /
`flights` at display time. Three reasons, in order of importance:

1. **Correctness.** A booking must always show *what was actually booked*. If a
   hotel is renamed, re-photographed, re-priced or delisted, a joined card would
   silently rewrite the user's own history — and a delisted document would blank
   the card entirely. Booking.com and Agoda both denormalize for exactly this.
2. **Cost.** One `where('userId')` query renders the whole list. Joining means
   1 + N reads fanned out across four different collections, and the client
   cannot batch across collections.
3. **Rules.** A user can read their own bookings without also needing read
   access to every catalog document a booking might point at.

`referenceId` is retained so a card can still deep-link into the live hotel/car/
tour/flight detail screen when one exists — the link is a *navigation* target,
never the source of what the card displays.

### Top-level fields

| field | type | notes |
|---|---|---|
| userId | string | must equal `request.auth.uid`; enforced in rules |
| type | string | `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` — selects the card layout and the type filter chip |
| referenceId | string | id of the hotel/car/tour/flight document. **Navigation only** — never the source of displayed text |
| bookingReference | string | **New.** The human-readable code shown on the card and quoted to support, e.g. `HTL-7845123`. Prefix is `HTL` / `CR` / `FL` / `TO` by type. **Generated server-side** in the checkout Cloud Function, never client-side — a client could otherwise forge or collide one. Indexed, because support looks bookings up by it |
| status | string | `"pending"` \| `"confirmed"` \| `"cancelled"` \| `"completed"`. **`completed` is new** — see the note on the time axis below |
| startAt | timestamp | **New.** Check-in / departure / pickup / tour start. Drives sorting **and** the Upcoming-vs-Past split |
| endAt | timestamp | **New.** Check-out / arrival / drop-off / tour end. Optional for a one-way flight, where it equals arrival |
| totalPrice | number | |
| currency | string | `"USD"` \| `"IQD"`. Rendered per `users.preferredCurrency` only when the two agree; otherwise the **booked** currency wins — a price is a fact about the transaction, not a display preference |
| paymentProvider | string | `"stripe"` \| `"fib"` \| `"nasswallet"` — see `SECURITY.md` section 5.3 |
| paymentStatus | string | **New. Server-owned.** `"pending"` \| `"paid"` \| `"refunded"` \| `"failed"`; written from the provider's verified callback/webhook, not inferred by the client from booking status |
| receiptUrl | string | **New, optional and server-owned.** Short-lived/provider-hosted receipt URL or a backend receipt endpoint. Never a client-uploaded URL. Absent hides “View Receipt” |
| cancellable | boolean | whether the Cancel action is offered. Server-owned; derived from the provider's fare/cancellation rules at purchase time |
| display | map | the denormalized card content — see below |
| bookingDetails | map | anything not shown on the card: add-ons, special requests, provider payload. Deliberately unstructured |

### `display` — what the card actually draws

Keyed by nothing; a flat map, because it is written once and read whole.

| field | type | notes |
|---|---|---|
| title | map | keyed by locale `{ en, ku, ar }` — the hotel/car/tour name, or the airline for a flight. A **map, not a string**, for the same reason as `featured.title`: switching language must not cost a second read. Missing locale falls back to `en` |
| locationLabel | map | same shape. "Erbil, Iraq" / "Erbil International Airport" |
| imageUrl | string | Storage download URL for the card thumbnail. **Copied, not referenced** — same reasoning as above. Flights have no thumbnail and omit it |
| guestCount | number | guests (hotel) / travelers (tour) / drivers (car) / passengers (flight). One field, four labels — the label comes from `type`, so the schema does not need four near-identical fields |
| guestLabel | string | `"adults"` \| `"children"` \| `"mixed"` — which noun the count is rendered with |

### Type-specific fields, all under `display`

Only the block matching `type` is present. A card never reads a field belonging
to another type.

| type | field | notes |
|---|---|---|
| hotel | `roomName` | optional, e.g. "Deluxe Twin" |
| flight | `fromCode` / `toCode` | IATA codes, e.g. `EBL` / `IST`. Always rendered left-to-right, even in Kurdish/Arabic — a route is not a sentence |
| flight | `fromCity` / `toCity` | maps keyed by locale, drawn under the codes |
| flight | `durationMinutes` | number; formatted as "2h 45m" in the active language |
| flight | `seat` | optional string, e.g. `16A`. Absent before check-in, and the row is **hidden rather than faked** — same rule as Explore Nature's Distance row |
| flight | `cabinClass` | `"economy"` \| `"premium_economy"` \| `"business"` \| `"first"`. Drawn as the info-coloured pill. Stored as a **key, not a display string**, so it can be translated |
| car | `pickupLocation` | map keyed by locale |
| car | `carClass` | optional, e.g. "SUV – Premium" |
| tour | `durationHours` | number; the tour's own length, distinct from `startAt`/`endAt` |

### Queries and indexes

```
list:   .where('userId', == uid).orderBy('startAt', desc).limit(50)
```

One query serves the whole screen. **Type and time filtering are applied in
Dart**, not in the query — the same decision, for the same reasons, as
`nature_spots` above: two independent filter dimensions (type chip × time
segment) would need a separate composite index per combination, and a user's own
booking list is small enough that one read is cheaper than five indexes. A
`userId` + `startAt` composite index is declared in `firestore.indexes.json`.

> **When this stops being right.** At 50+ bookings per user the list should
> paginate on `startAt` rather than raising the limit. Recorded as a deliberate
> trade, not an oversight.

### Who may write

**No client writes, in either direction.** A booking is created only by the
checkout Cloud Function, after the payment provider confirms the charge
(`SECURITY.md` section 5). Cancellation is likewise a Cloud Function — it must
call the provider's cancel API and compute the refund, neither of which a client
can be trusted to do. The rules therefore grant the client **owner-read only**;
`create`, `update` and `delete` are all denied.

If the client could write here, a modified app could mint itself a confirmed
booking it never paid for. That is the entire reason this collection is
read-only from the app.

> **There is no such thing as a guest booking.** The rules require an auth uid,
> so a signed-out user sees a sign-in prompt rather than an empty list — the
> same precedent as favorites and the drawer's Currency row (`SECURITY.md` 6.1f:
> no anonymous mirror of signed-in data).

## `favorites`

Document id is **deterministic**: `{uid}_{itemType}_{itemId}`. That makes
favoriting a plain set/delete on a known document instead of a
query-then-write, and makes a double-tap idempotent rather than creating two
rows for the same place. The id is *not* what the rules trust — they check
the `userId` field, so a forged id gains nothing.

| field | type | notes |
|---|---|---|
| userId | string | must equal `request.auth.uid`; enforced in rules |
| itemType | string | `"nature_spot"` \| `"hotel"` \| `"car"` \| `"tour"` \| `"flight"` — `flight` added for the Home screen, whose carousel can feature one |
| itemId | string | |

There is no such thing as a guest favorite: the rules require an auth uid, so
the Home screen prompts an unsigned-in user to log in rather than writing
anything locally.

---

**Notes for the agent:**
- Keep subcollections (like `hotels/{id}/rooms`) instead of separate
  top-level collections with a foreign key, when the child data is always
  fetched alongside the parent (cheaper reads, simpler security rules).
- Use top-level collections with a reference field when the child data
  needs to be queried independently of its parent (e.g. `bookings` needs
  to be queried by `userId` across all hotels/cars/tours, so it can't live
  nested under `hotels/{id}`).
- Revisit this file after Phase 0 planning — this is a starting draft, not
  final.
