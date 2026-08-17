# FIREBASE_SETUP.md — What still has to be done in the console

The app code is wired for Firebase. What remains needs **your** Google
account, billing details and Apple developer account — none of it can be done
from the codebase.

Until these steps are finished, `Firebase.initializeApp()` fails
(`lib/services/firebase_bootstrap.dart`).

## Preview mode — how the reset flow runs before any of this is done

So the screens can be reviewed today, `PasswordResetService` falls back to a
**preview mode** whenever Firebase is unconfigured:

- no code is really sent;
- **any** 6-digit code is accepted;
- the password is **not** really changed.

Every screen in that state shows a yellow `PreviewModeBanner` saying so, so it
can't be mistaken for a working backend.

**It cannot reach production.** `isPreviewMode` is
`kDebugMode && !FirebaseBootstrap.isReady` — a release build always takes the
real path and fails closed if Firebase is missing, rather than accepting any
code. Once `flutterfire configure` has run, preview mode switches itself off
automatically; there is no flag to remember to flip.

Check items off here as you go.

---

## 1. Install the CLIs (one-time, on this machine) — ✅ DONE 2026-08-17

All four are installed and verified working:

| Tool | Version | Location |
|---|---|---|
| Node.js | v24.19.0 (LTS) | `%LOCALAPPDATA%\Programs\node-v24.19.0-win-x64` |
| npm | 11.17.0 | same |
| Firebase CLI | 15.27.0 | global npm |
| FlutterFire CLI | 1.4.1 | `%LOCALAPPDATA%\Pub\Cache\bin` |

Installed from the **official portable zip**, not the MSI: this account is not
a local administrator, and the MSI needs elevation. Extracted to
`%LOCALAPPDATA%\Programs` and added to the **user** `Path` — no admin was
needed and nothing machine-wide was touched.

> ⚠️ The `Path` edit is permanent, but an **already-open terminal will not see
> it**. Open a new terminal if `node` is "not recognized".

`functions/npm install` has also been run (189 packages); `firebase-admin` and
`firebase-functions` both load. All seven scripts in `tool/` and
`functions/index.js` now pass `node --check` — previously unverifiable.

> `functions/package.json` pins the deploy runtime to **Node 20**, which is
> correct and should stay: it is the Cloud Functions runtime, not the local
> one. Node 24 locally is only used to run the CLI and the seed scripts.

**What is still not done, and cannot be done for you:**

```bash
firebase login    # opens a browser; needs YOUR Google account
```

That sign-in, creating the project, choosing the billing plan, and downloading
a service-account key all require console access under your own account.

## 2. Create the Firebase project

- [ ] Create the project at <https://console.firebase.google.com>
- [ ] Create **two** projects if you want a real dev/prod split (`ROADMAP.md`
      Phase 0 asks for this) — e.g. `kurdistan-paradise-dev` and
      `kurdistan-paradise-prod`
- [ ] Enable **Firestore**, **Authentication**, **Storage**, **Functions**
- [ ] Set Firestore to **production mode** (deny-by-default), *not* test mode

## 3. Generate the app config

From the repo root:

```bash
flutterfire configure
```

This writes `lib/firebase_options.dart`, `android/app/google-services.json`
and `ios/Runner/GoogleService-Info.plist`.

- [ ] Run `flutterfire configure`
- [ ] Switch `FirebaseBootstrap` to pass
      `options: DefaultFirebaseOptions.currentPlatform` once
      `firebase_options.dart` exists (currently it calls the no-arg
      `initializeApp()`, which reads the native config files)

> `google-services.json` / `GoogleService-Info.plist` are **safe to commit** —
> they are public project identifiers, not secrets (`SECURITY.md` section 4).

**Why the `com.google.gms.google-services` Gradle plugin isn't in
`android/app/build.gradle.kts` yet:** that plugin fails the Android build
outright if `google-services.json` is absent. Adding it before you've run
`flutterfire configure` would break `flutter run` for no benefit.
`flutterfire configure` adds the plugin *and* the JSON file together, so the
build only ever sees a consistent pair. If for some reason it doesn't, add it
manually afterwards.

## 4. ⚠️ Billing — this flow is not free

Three separate things here cost money. Decide before enabling.

- [ ] **Blaze (pay-as-you-go) plan** — required for Cloud Functions at all.
      Functions cannot be deployed on the free Spark plan.
- [ ] **Firebase Auth with Identity Platform** — required for SMS/phone
      verification and later for TOTP MFA (`SECURITY.md` 6.1). This is an
      upgrade from base Firebase Auth and has its own pricing tier.
- [ ] **SMS charges** — phone verification is billed per message sent, and
      Iraqi destination numbers are not in the cheapest tier. Set a budget
      alert before going live; SMS-pumping fraud is a real cost risk.

## 5. Enable the sign-in providers

- [ ] Authentication → Sign-in method → enable **Email/Password**
- [ ] Authentication → Sign-in method → enable **Phone**
- [ ] Add your own test phone number under Phone → *Phone numbers for
      testing*, so you can develop without burning real SMS

## 6. Android setup (phone verification fails silently without this)

- [ ] Get the debug SHA-256:
      `cd android && ./gradlew signingReport`
- [ ] Add both the **SHA-1 and SHA-256** to Firebase Console → Project
      Settings → your Android app
- [ ] Re-download `google-services.json` after adding them
- [ ] Repeat with the **release** keystore's hashes before shipping

## 7. iOS setup (needs a paid Apple Developer account)

- [ ] Xcode → Signing & Capabilities → add **Push Notifications**
- [ ] Xcode → Signing & Capabilities → **Background Modes** → tick
      *Remote notifications*
- [ ] Create an **APNs authentication key** (.p8) in the Apple Developer
      portal and upload it to Firebase → Project Settings → Cloud Messaging
- [ ] Confirm the `REVERSED_CLIENT_ID` URL scheme is in `Info.plist`

> iOS phone auth uses a silent push to prove the request came from a real
> device. Without APNs it falls back to a reCAPTCHA web view — it still
> works, but it is a visibly worse experience.

## 8. Email delivery for the email-code branch

The `sendPasswordResetCode` function writes to a `mail` collection; an
extension picks it up and actually sends it.

- [ ] Install the **"Trigger Email from Firestore"** extension
      (Firebase Console → Extensions)
- [ ] Point it at the **`mail`** collection
- [ ] Give it SMTP credentials (SendGrid, Mailgun, Gmail SMTP, …). These live
      in the extension's own config — **never in this repo**
      (`SECURITY.md` section 4)
- [ ] Verify the sender domain, or the codes will land in spam

## 9. Deploy the rules and functions

```bash
cd functions && npm install && cd ..
firebase deploy --only firestore:rules,functions
```

- [ ] `npm install` inside `functions/`
- [ ] Deploy `firestore.rules`
- [ ] Deploy `firestore.indexes.json`
      (`firebase deploy --only firestore:indexes`) — the home carousel's
      `where('active').orderBy('order')` query fails without its composite
      index
- [ ] Seed the home screen's data: `node tool/seed_home_screen.js`, then
      upload the four slide photos to Storage and set each `imageUrl`
- [ ] Deploy `storage.rules`
      (`firebase deploy --only storage`) — profile-picture uploads fail
      without it
- [ ] Deploy all four functions: `sendPasswordResetCode`,
      `verifyPasswordResetCode`, `confirmPasswordResetWithCode`,
      `recordPasswordChange`
- [ ] Authentication → Settings → **Password policy**: set the same rule the
      Reset Password screen shows (8+ chars, uppercase, lowercase, special
      character) so it also applies to registration, not just reset
      (`SECURITY.md` 6.1b)

## 10. Test the security rules actually deny access

`CLAUDE.md` requires this before a screen counts as approved — confirm the
denial is real, not just hidden in the UI.

```bash
firebase emulators:start --only firestore
```

- [ ] As an **unauthenticated** client, try to read
      `password_reset_codes/{anyId}` → must be **denied**
- [ ] As a **signed-in non-admin** user, same read → must be **denied**
- [ ] As a signed-in user, try to read or write
      `email_change_codes/{theirUid}` → both must be **denied**
- [ ] As a signed-in user, try to write to `mail` → must be **denied**
      (otherwise anyone can send mail from your verified sender)
- [ ] **Home screen collections:**
  - [ ] Unauthenticated read of `featured` and `nature_spots` → must be
        **allowed** (a guest browses the dashboard)
  - [ ] Signed-in non-admin **write** to `featured` → must be **denied**
        (otherwise anyone can put content on the app's front page)
  - [ ] Signed-in user reading **another** user's `favorites` → must be
        **denied**, including an unfiltered `list` of the whole collection
  - [ ] Creating a `favorites` document with someone else's `userId` → must
        be **denied**
  - [ ] `update` on any `favorites` document → must be **denied**
- [ ] Confirm the Cloud Functions still work — the Admin SDK bypasses rules,
      so they should be unaffected

## 11. Still outstanding (tracked elsewhere, not part of this screen)

- [ ] **Firebase App Check** — `SECURITY.md` 6.3. Without it, anyone can call
      `sendPasswordResetCode` directly and burn your SMS/email quota. Both
      functions currently set `enforceAppCheck: false`; flip them to `true`
      once App Check is enabled and verified on both platforms.
- [ ] **Crashlytics** — `SECURITY.md` section 10
- [ ] **`flutter_secure_storage`** for cached auth tokens — `SECURITY.md` 6.4
- [ ] A scheduled function to purge expired `password_reset_codes` documents
