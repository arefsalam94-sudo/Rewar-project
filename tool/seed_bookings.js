/**
 * Seeds one example `bookings` document per product type, so the My Bookings
 * screen can be verified against real Firestore data rather than a mock.
 *
 * Writes five documents:
 *   preview-hotel          — confirmed, upcoming    → the Check In card
 *   preview-flight         — confirmed, upcoming    → the boarding pass with barcode
 *   preview-car            — confirmed, upcoming    → the Pickup Info card
 *   preview-tour-upcoming  — confirmed, upcoming    → the Tours chip on Upcoming
 *   preview-tour           — completed, in the past → exercises the Past segment
 *
 * The tour appears twice on purpose. The screen opens on Upcoming, so a single
 * completed tour leaves the Tours chip empty on the segment users land on — it
 * reads as a broken filter rather than as an empty Past.
 *
 * See the "one example, seeded to Firestore, per page" rule in CLAUDE.md and
 * the tracking table in SEED_DATA.md.
 *
 * These same four are duplicated as `BookingsService.bundledBookings()` in
 * `lib/services/bookings_service.dart`, which is what preview mode serves
 * before Firebase exists. Keep the two in sync.
 *
 * ⚠️ THIS SCRIPT EXISTS ONLY BECAUSE THE CHECKOUT FLOW DOES NOT.
 * In production a booking is created exclusively by the checkout Cloud
 * Function after the payment provider confirms the charge — `firestore.rules`
 * denies every client write to this collection, and `bookingReference` must be
 * generated server-side. This script uses the Admin SDK, which bypasses the
 * rules; that is the only reason it can write at all. Delete it, or restrict
 * it to non-production projects, once Phases 4–7 exist.
 *
 * ⚠️ `userId` must be a REAL Firebase Auth uid or the app will show an empty
 * list: the rules pin every read to `request.auth.uid`. Pass yours as the
 * first argument, or set SEED_USER_ID.
 *
 * ⚠️ `display.imageUrl` is left empty on every document. Upload the photos to
 * Firebase Storage first, then paste their download URLs in below (or set them
 * from the admin panel). With no URL the card falls back to a brand-coloured
 * panel with an image icon rather than showing a broken image.
 *
 * Usage:
 *   1. Download a service-account key from
 *      Firebase Console → Project Settings → Service accounts.
 *      Do NOT commit it — .gitignore already covers *-service-account.json.
 *   2. cd functions && npm install && cd ..
 *   3. GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *        node tool/seed_bookings.js <firebase-auth-uid>
 */

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const USER_ID = process.argv[2] || process.env.SEED_USER_ID;

if (!USER_ID) {
  console.error(
    "Refusing to seed without a uid.\n\n" +
      "Every booking is read back through a rule that pins it to the signed-in\n" +
      "user, so a booking written against a placeholder uid would be invisible\n" +
      "in the app and look like a bug in the screen.\n\n" +
      "  node tool/seed_bookings.js <firebase-auth-uid>\n"
  );
  process.exit(1);
}

/** Days from today at a given local time, as a JS Date. */
function inDays(days, hours = 0, minutes = 0) {
  const date = new Date();
  date.setDate(date.getDate() + days);
  date.setHours(hours, minutes, 0, 0);
  return date;
}

/**
 * `display` holds everything the card draws, copied here at "purchase" time
 * rather than joined from `hotels` / `cars` / `tours` / `flights`. A booking is
 * a historical record: renaming or delisting a hotel must not rewrite the
 * user's own past. See DATA_MODEL.md.
 *
 * `title`, `locationLabel`, `fromCity`, `toCity` and `pickupLocation` are
 * locale maps so switching language costs no extra read. A missing locale
 * falls back to `en` in the app.
 */
const BOOKINGS = [
  {
    id: "preview-hotel",
    type: "hotel",
    status: "confirmed",
    bookingReference: "HTL-7845123",
    referenceId: "divan-erbil",
    startAt: inDays(11, 14),
    endAt: inDays(14, 12),
    totalPrice: 420,
    currency: "USD",
    cancellable: true,
    display: {
      title: {
        en: "Divan Erbil Hotel",
        ku: "هوتێلی دیڤان هەولێر",
        ar: "فندق ديوان أربيل",
      },
      locationLabel: {
        en: "Erbil, Iraq",
        ku: "هەولێر، عێراق",
        ar: "أربيل، العراق",
      },
      imageUrl: "",
      guestCount: 2,
      roomName: "Deluxe Twin",
    },
  },
  {
    id: "preview-flight",
    type: "flight",
    status: "confirmed",
    bookingReference: "FL-9856217",
    referenceId: "ebl-ist-0935",
    startAt: inDays(10, 9, 35),
    endAt: inDays(10, 12, 20),
    totalPrice: 310,
    currency: "USD",
    cancellable: false,
    display: {
      title: {
        en: "Iraqi Airways",
        ku: "هێڵی ئاسمانی عێراقی",
        ar: "الخطوط الجوية العراقية",
      },
      locationLabel: {
        en: "Erbil International Airport",
        ku: "فڕۆکەخانەی نێودەوڵەتی هەولێر",
        ar: "مطار أربيل الدولي",
      },
      guestCount: 1,
      fromCode: "EBL",
      toCode: "IST",
      fromCity: { en: "Erbil", ku: "هەولێر", ar: "أربيل" },
      toCity: { en: "Istanbul", ku: "ئەستەنبووڵ", ar: "إسطنبول" },
      durationMinutes: 165,
      seat: "16A",
      // A key, not a display string, so it can be translated.
      cabinClass: "economy",
    },
  },
  {
    id: "preview-car",
    type: "car",
    status: "confirmed",
    bookingReference: "CR-6623148",
    referenceId: "suv-premium",
    startAt: inDays(15, 10),
    endAt: inDays(17, 10),
    totalPrice: 180,
    currency: "USD",
    cancellable: true,
    display: {
      title: {
        en: "SUV – Premium",
        ku: "ئێس یو ڤی – پرێمیۆم",
        ar: "دفع رباعي – ممتاز",
      },
      locationLabel: {
        en: "Erbil International Airport",
        ku: "فڕۆکەخانەی نێودەوڵەتی هەولێر",
        ar: "مطار أربيل الدولي",
      },
      imageUrl: "",
      guestCount: 1,
      pickupLocation: {
        en: "Erbil International Airport",
        ku: "فڕۆکەخانەی نێودەوڵەتی هەولێر",
        ar: "مطار أربيل الدولي",
      },
      carClass: "SUV – Premium",
    },
  },
  {
    id: "preview-tour-upcoming",
    type: "tour",
    status: "confirmed",
    bookingReference: "TO-4471908",
    referenceId: "lalish-amedi-heritage-tour",
    startAt: inDays(6, 7),
    endAt: inDays(6, 17),
    totalPrice: 140,
    currency: "USD",
    cancellable: true,
    display: {
      title: {
        en: "Lalish & Amedi Heritage Tour",
        ku: "گەشتی کەلەپووری لالش و ئامێدی",
        ar: "جولة لالش وآميدي التراثية",
      },
      locationLabel: {
        en: "Duhok, Iraq",
        ku: "دهۆک، عێراق",
        ar: "دهوك، العراق",
      },
      imageUrl: "",
      guestCount: 3,
      durationHours: 10,
    },
  },
  {
    id: "preview-tour",
    type: "tour",
    status: "completed",
    bookingReference: "TO-122534",
    referenceId: "rawanduz-day-tour",
    startAt: inDays(-21, 8),
    endAt: inDays(-21, 16),
    totalPrice: 95,
    currency: "USD",
    cancellable: false,
    display: {
      title: {
        en: "Rawanduz & Bekhal Day Tour",
        ku: "گەشتی ڕۆژانەی ڕەواندز و بێخاڵ",
        ar: "جولة يوم راوندوز وبيخال",
      },
      locationLabel: {
        en: "Rawanduz, Erbil",
        ku: "ڕەواندز، هەولێر",
        ar: "راوندوز، أربيل",
      },
      imageUrl: "",
      guestCount: 2,
      durationHours: 8,
    },
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

  for (const booking of BOOKINGS) {
    const { id, ...data } = booking;
    batch.set(db.collection("bookings").doc(id), {
      ...data,
      ...envelope,
      id,
      userId: USER_ID,
    });
  }

  await batch.commit();

  console.log(`Seeded ${BOOKINGS.length} bookings for uid ${USER_ID}.`);
  console.log(
    "Reminder: every document still has an empty display.imageUrl — upload " +
      "the photos to Storage and set the URLs before calling this page done."
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
