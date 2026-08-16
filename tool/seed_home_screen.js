/**
 * Seeds the two collections the Home screen reads:
 *
 *   featured/*        — the four carousel slides
 *   nature_spots/*    — one example spot, so the count() aggregation behind
 *                       the "N+ places" button returns something real
 *
 * See the "one example, seeded to Firestore, per page" rule in CLAUDE.md and
 * the tracking table in SEED_DATA.md.
 *
 * The same four slides are duplicated as `bundledFeatured()` in
 * `lib/services/featured_service.dart`, which is what preview mode serves
 * before Firebase exists. Keep the two in sync.
 *
 * ⚠️ `imageUrl` is left empty on every slide. Upload the four photos to
 * Firebase Storage first, then paste their download URLs in below (or set
 * them from the admin panel). With no URL the card falls back to the brand
 * colour rather than showing a broken image.
 *
 * Usage:
 *   1. Download a service-account key from
 *      Firebase Console → Project Settings → Service accounts.
 *      Do NOT commit it — .gitignore already covers *-service-account.json.
 *   2. cd functions && npm install && cd ..
 *   3. GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *        node tool/seed_home_screen.js
 */

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue, GeoPoint } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

/**
 * Titles and subtitles are locale maps so switching language costs no extra
 * read. A missing locale falls back to `en` in the app.
 */
const FEATURED = [
  {
    id: "rawanduz-canyon",
    type: "nature_spot",
    referenceId: "rawanduz-canyon",
    title: {
      en: "Rawanduz Canyon",
      ku: "دەربەندی ڕەواندز",
      ar: "وادي راوندوز",
    },
    subtitle: {
      en: "Erbil  •  Nature escape",
      ku: "هەولێر  •  گەشتی سروشتی",
      ar: "أربيل  •  رحلة طبيعية",
    },
    imageUrl: "",
    rating: 4.8,
    order: 1,
  },
  {
    id: "greenwheels-rentals",
    type: "car",
    referenceId: "greenwheels-rentals",
    title: {
      en: "GreenWheels Rentals",
      ku: "گرینویڵز بۆ بەکرێدان",
      ar: "غرين ويلز للتأجير",
    },
    subtitle: {
      en: "Erbil  •  Car rental",
      ku: "هەولێر  •  بەکرێدانی ئۆتۆمبێل",
      ar: "أربيل  •  تأجير سيارات",
    },
    imageUrl: "",
    rating: 4.6,
    order: 2,
  },
  {
    id: "astra-ebl-ist",
    type: "flight",
    referenceId: "astra-ebl-ist",
    title: {
      en: "Astra Airlines",
      ku: "ئاسترا ئێێرلاینز",
      ar: "أسترا للطيران",
    },
    subtitle: {
      en: "Erbil → Istanbul  •  Flight",
      ku: "هەولێر → ئەستەنبوڵ  •  فڕین",
      ar: "أربيل → إسطنبول  •  رحلة جوية",
    },
    imageUrl: "",
    rating: 4.5,
    order: 3,
  },
  {
    id: "moraine-lake",
    type: "tour",
    referenceId: "moraine-lake",
    title: {
      en: "Moraine Lake",
      ku: "دەریاچەی مۆرین",
      ar: "بحيرة موراين",
    },
    subtitle: {
      en: "3 days travel  •  Guided tour",
      ku: "٣ ڕۆژ گەشت  •  گەشتی ڕێبەرایەتیکراو",
      ar: "رحلة ٣ أيام  •  جولة بمرشد",
    },
    imageUrl: "",
    rating: 4.7,
    order: 4,
  },
];

/** The one example nature spot, matching SEED_DATA.md. */
const NATURE_SPOT = {
  id: "rawanduz-canyon",
  name: "Rawanduz Canyon",
  description:
    "A deep gorge above the Rawanduz river, with switchback mountain roads, " +
    "waterfalls and viewpoints over the Zagros foothills.",
  imageUrls: [],
  location: new GeoPoint(36.6089, 44.5286),
  distanceLabel: "123 km from Erbil",
  rating: 4.8,
  ratingCount: 0,
};

async function main() {
  const envelope = {
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    source: "manual",
    createdBy: "seed-script",
  };

  const batch = db.batch();

  for (const item of FEATURED) {
    const { id, ...data } = item;
    batch.set(db.collection("featured").doc(id), {
      ...data,
      ...envelope,
      id,
      // Only active slides appear in the carousel; this is the flag the
      // admin panel toggles to pull something off the front page.
      active: true,
    });
  }

  const { id: spotId, ...spotData } = NATURE_SPOT;
  batch.set(db.collection("nature_spots").doc(spotId), {
    ...spotData,
    ...envelope,
    id: spotId,
  });

  await batch.commit();

  console.log(`Seeded ${FEATURED.length} featured slides and 1 nature spot.`);
  console.log(
    "Reminder: every featured slide still has an empty imageUrl — upload the " +
      "photos to Storage and set the URLs before calling this page done."
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
