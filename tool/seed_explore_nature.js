/**
 * Seeds the `nature_spots` documents the Explore Nature screen reads.
 *
 * Writes three places, matching the reference screenshot:
 *   rawanduz-canyon         — highlighted, so it fills the top carousel
 *   sami-abdulrahman-park   — first list card
 *   erbil-citadel           — second list card
 *
 * See the "one example, seeded to Firestore, per page" rule in CLAUDE.md and
 * the tracking table in SEED_DATA.md.
 *
 * These same three are duplicated as `NatureSpotsService.bundledSpots()` in
 * `lib/services/nature_spots_service.dart`, which is what preview mode serves
 * before Firebase exists. Keep the two in sync.
 *
 * It also seeds the visitor reviews behind each place's score — three for
 * Rawanduz (the ones drawn in the Reviews & Ratings reference) and two each
 * for the other places.
 *
 * ⚠️ `reviewScore`, `ratingCount` and `ratingBreakdown` are deliberately NOT
 * written here. They are **server-owned**: the `syncNatureReviewAggregates`
 * Cloud Function derives them from the review documents below. Writing them by
 * hand would produce a place claiming 1,032 reviews with two review documents
 * behind it — and the next review posted would silently correct it anyway.
 * Deploy the functions before (or with) running this script; until they exist,
 * the spots will show no score, which is the honest state for a catalog with
 * no computed reviews.
 *
 * NOTE this overwrites `nature_spots/rawanduz-canyon`, which
 * `tool/seed_home_screen.js` also writes. That is intentional: this script
 * carries the newer schema (locale maps, reviewScore, categories), and the
 * home screen only runs a count() against the collection, so it is unaffected.
 *
 * ⚠️ `imageUrls` is left empty on every document. Upload the photos to
 * Firebase Storage first, then paste their download URLs in below (or set them
 * from the admin panel). With no URL the card falls back to a brand-coloured
 * panel with a park icon rather than showing a broken image.
 *
 * Usage:
 *   1. Download a service-account key from
 *      Firebase Console → Project Settings → Service accounts.
 *      Do NOT commit it — .gitignore already covers *-service-account.json.
 *   2. cd functions && npm install && cd ..
 *   3. GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *        node tool/seed_explore_nature.js
 */

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
  GeoPoint,
} = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

/**
 * `name`, `description` and `locationLabel` are locale maps so switching
 * language costs no extra read. A missing locale falls back to `en` in the app.
 *
 * `reviewScore` is 0–10 (Booking.com style). The 5-star row on the card is
 * DERIVED from it (score ÷ 2, rounded) — there is deliberately no separate
 * star field to fall out of sync with the score.
 *
 * Three independent tag arrays, all filtered in the app rather than in the
 * query (Firestore permits one array clause per query, and there are three):
 *   categories  — the quick chips: hiking | beach | sunset_view
 *   placeTypes  — forest | mountain | canyon | park | lake | waterfall |
 *                 river | museum
 *   amenities   — parking | restrooms | restaurants | cafes | mobile_signal |
 *                 lodging_nearby | atm_nearby
 */
const SPOTS = [
  {
    id: "rawanduz-canyon",
    name: {
      en: "Rawanduz Canyon",
      ku: "دەربەندی ڕەواندز",
      ar: "وادي راوندوز",
    },
    locationLabel: {
      en: "Erbil, Iraq",
      ku: "هەولێر، عێراق",
      ar: "أربيل، العراق",
    },
    description: {
      en:
        "Bekhal Waterfall is one of the most famous natural attractions in " +
        "the Rawanduz area of Iraqi Kurdistan. Cool spring water cascades " +
        "down the rock face all summer long.",
      ku:
        "ئاوشاری بێخاڵ یەکێکە لە ناودارترین شوێنە سروشتییەکانی ناوچەی " +
        "ڕەواندز لە کوردستانی عێراق. ئاوی سارد بە درێژایی هاوین بەسەر " +
        "بەردەکاندا دەڕژێت.",
      ar:
        "شلال بيخال هو أحد أشهر المعالم الطبيعية في منطقة راوندوز بكردستان " +
        "العراق. تتدفق مياه الينابيع الباردة على الصخور طوال الصيف.",
    },
    imageUrls: [],
    location: new GeoPoint(36.6089, 44.5286),
    categories: ["hiking", "sunset_view"],
    placeTypes: ["canyon", "waterfall", "river", "mountain"],
    amenities: ["parking", "restrooms", "restaurants", "lodging_nearby"],
    nearbyStays: [
      { id: "rawanduz-resort", name: { en: "Rawanduz Resort", ku: "ڕیزۆرتی ڕەواندز", ar: "منتجع رواندوز" }, imageUrl: "", distanceKm: 3.2, reviewScore: 8.8 },
      { id: "bekhal-cabin", name: { en: "Bekhal Cabin", ku: "کابینی بێخاڵ", ar: "كوخ بيخال" }, imageUrl: "", distanceKm: 1.4, reviewScore: 8.5 },
      { id: "korek-lodge", name: { en: "Korek Mountain Lodge", ku: "لۆجی چیای کۆڕەک", ar: "نُزل جبل كورك" }, imageUrl: "", distanceKm: 18, reviewScore: 9 },
    ],
    highlighted: true,
    highlightOrder: 1,
  },
  {
    id: "sami-abdulrahman-park",
    name: {
      en: "Sami Abdulrahman Park",
      ku: "پارکی سامی عەبدولڕەحمان",
      ar: "حديقة سامي عبد الرحمن",
    },
    locationLabel: {
      en: "Erbil, Iraq",
      ku: "هەولێر، عێراق",
      ar: "أربيل، العراق",
    },
    description: {
      en:
        "A beautiful urban park with scenic lakes, walking trails, and " +
        "picnic areas perfect for a slow afternoon in the city.",
      ku:
        "پارکێکی جوانی ناوشار بە دەریاچەی دڵڕفێن و ڕێڕەوی پیاسە و شوێنی " +
        "پیکنیک، گونجاو بۆ نیوەڕۆیەکی ئارام لە شاردا.",
      ar:
        "حديقة حضرية جميلة ببحيرات خلابة ومسارات للمشي وأماكن للنزهات، " +
        "مثالية لقضاء عصر هادئ في المدينة.",
    },
    imageUrls: [],
    location: new GeoPoint(36.1901, 43.993),
    categories: ["hiking", "sunset_view"],
    placeTypes: ["park", "lake"],
    amenities: [
      "parking",
      "restrooms",
      "restaurants",
      "cafes",
      "mobile_signal",
      "atm_nearby",
    ],
    highlighted: false,
    highlightOrder: 0,
  },
  {
    id: "erbil-citadel",
    name: {
      en: "Erbil Citadel",
      ku: "قەڵای هەولێر",
      ar: "قلعة أربيل",
    },
    locationLabel: {
      en: "Erbil, Iraq",
      ku: "هەولێر، عێراق",
      ar: "أربيل، العراق",
    },
    description: {
      en:
        "A historic citadel and one of the world's oldest continuously " +
        "inhabited places, with museums and stunning views over the city.",
      ku:
        "قەڵایەکی مێژوویی و یەکێک لە کۆنترین شوێنەکانی جیهان کە بەردەوام " +
        "نیشتەجێی تێدا بووە، بە مۆزەخانە و دیمەنی سەرنجڕاکێشی شار.",
      ar:
        "قلعة تاريخية وأحد أقدم الأماكن المأهولة باستمرار في العالم، " +
        "تضم متاحف وإطلالات رائعة على المدينة.",
    },
    imageUrls: [],
    location: new GeoPoint(36.1912, 44.0093),
    categories: ["sunset_view"],
    placeTypes: ["museum"],
    amenities: [
      "parking",
      "restrooms",
      "cafes",
      "mobile_signal",
      "lodging_nearby",
      "atm_nearby",
    ],
    highlighted: false,
    highlightOrder: 0,
  },
];

async function main() {
  const envelope = {
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    source: "manual",
    createdBy: "seed-script",
  };

  const batch = db.batch();

  for (const spot of SPOTS) {
    const { id, ...data } = spot;
    batch.set(db.collection("nature_spots").doc(id), {
      ...data,
      ...envelope,
      id,
      // Only active spots are queried; this is the flag the admin panel
      // toggles to pull a place off the list without deleting its document.
      active: true,
    });
  }

  await batch.commit();
  await seedReviews();

  console.log(`Seeded ${SPOTS.length} nature spots.`);
  console.log(
    `Seeded ${countReviews()} visitor reviews across ${
      Object.keys(REVIEWS).length
    } places.`
  );
  console.log(
    "Reminder: every document still has an empty imageUrls array — upload " +
      "the photos to Storage and set the URLs before calling this page done."
  );
  console.log(
    "Reminder: reviewScore / ratingCount / ratingBreakdown are NOT written " +
      "by this script. Deploy `syncNatureReviewAggregates` (firebase deploy " +
      "--only functions) — it derives them from the reviews above. Until it " +
      "runs, every place will show no score."
  );
}

/**
 * The visitor reviews behind each place's score.
 *
 * **The document id is the author's uid**, which is what `firestore.rules`
 * requires and what keeps one review per person per place enforceable rather
 * than merely intended. The `seed-*` ids stand in for real Auth uids; replace
 * them (or delete these documents) once real accounts exist.
 *
 * `rating` is a number in **half-star steps**, 0.5–5. The page shows it as
 * `rating × 2` out of 10 — so 4.5 reads as 9.0 / 10. It is not an integer:
 * the design draws half stars, and an integer cannot hold one.
 *
 * The three Rawanduz reviews are the ones drawn in the Reviews & Ratings
 * reference. Their comments are verbatim from it; their scores are the nearest
 * half-star values, because the reference's own numbers (9.2, 7.5, 9.5) cannot
 * be produced by any star picker — see PROGRESS.md.
 */
const REVIEWS = {
  "rawanduz-canyon": [
    {
      uid: "seed-elena",
      userName: "Elena P.",
      rating: 4.5,
      hoursAgo: 3,
      comment:
        "The view is absolutely stunning! The sound of the waterfall is so " +
        "relaxing. Perfect place to unwind.",
    },
    {
      uid: "seed-hassan",
      userName: "Hassan S.",
      rating: 4,
      hoursAgo: 24,
      comment:
        "Great place for hiking and photography. I visited in the morning " +
        "and the lighting was perfect.",
    },
    {
      uid: "seed-priya",
      userName: "Priya N.",
      rating: 3.5,
      hoursAgo: 96,
      comment:
        "Beautiful waterfall and clean area. There are small stalls with " +
        "tea and snacks.",
    },
  ],
  "sami-abdulrahman-park": [
    {
      uid: "seed-aland",
      userName: "Aland K.",
      rating: 4.5,
      hoursAgo: 30,
      comment:
        "Wide open lawns and a proper lake path. Best just before sunset.",
    },
    {
      uid: "seed-sara",
      userName: "Sara A.",
      rating: 4,
      hoursAgo: 200,
      comment:
        "Clean, safe and easy to park at. Gets busy on Friday afternoons.",
    },
  ],
  "erbil-citadel": [
    {
      uid: "seed-dara",
      userName: "Dara M.",
      rating: 5,
      hoursAgo: 60,
      comment:
        "Standing somewhere people have lived for thousands of years is " +
        "worth the trip on its own. Take a guide.",
    },
    {
      uid: "seed-noor",
      userName: "Noor H.",
      rating: 4,
      hoursAgo: 500,
      comment:
        "The museums are small but well kept, and the view over the bazaar " +
        "is the best in the city.",
    },
  ],
};

function countReviews() {
  return Object.values(REVIEWS).reduce((total, list) => total + list.length, 0);
}

/**
 * Written in a separate batch from the spots, and after it, so the aggregate
 * trigger always finds the parent document already there — it skips a spot
 * that does not exist yet, and nothing would come back to recompute it.
 */
async function seedReviews() {
  const batch = db.batch();
  const now = Date.now();

  for (const [spotId, reviews] of Object.entries(REVIEWS)) {
    for (const review of reviews) {
      const { uid, hoursAgo, ...data } = review;
      const createdAt = new Date(now - hoursAgo * 60 * 60 * 1000);
      batch.set(
        db.collection("nature_spots").doc(spotId)
          .collection("reviews").doc(uid),
        {
          ...data,
          userId: uid,
          avatarUrl: "",
          // Server-owned; the votes trigger maintains it from here on.
          helpfulCount: 0,
          status: "published",
          // A real timestamp rather than serverTimestamp(), so "3 hours ago"
          // on the card is actually three hours ago and the newest-first sort
          // has something to sort by.
          createdAt,
          updatedAt: FieldValue.serverTimestamp(),
        }
      );
    }
  }

  await batch.commit();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
