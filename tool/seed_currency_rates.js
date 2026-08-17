/**
 * Seeds `currency_rates/latest` — the one document behind every converted
 * price in the app.
 *
 * ⚠️ **These rates are indicative, not transactional.** They exist so a
 * traveller can compare a tour priced in USD against one priced in IQD. They
 * are NOT what a charge is settled at: a checkout must price in the operator's
 * own currency and let the payment processor convert, or the app takes on FX
 * risk it has no way to hedge. Every screen that shows a converted figure
 * marks it approximate ("≈") and prints the disclosure above the list.
 *
 * ⚠️ **Nothing refreshes this document yet.** The values below are round
 * illustrative numbers, and they will drift. Before release this needs either:
 *
 *   - a scheduled Cloud Function (`onSchedule`) pulling from a rate provider
 *     and writing this same document — the provider's API key belongs in
 *     Secret Manager / functions config, never in this repo (SECURITY.md 4);
 *     or
 *   - an admin-panel form, if the operator is happy updating it by hand.
 *
 * A stale rate is the failure mode to design against, which is why the
 * document carries `updatedAt` and the app prints it: an undated rate is worse
 * than no rate. `CurrencyRates.convert` returns null for any currency missing
 * from the table, and the UI then falls back to the operator's own price —
 * so deleting a currency here is safe, and adding a wrong one is not.
 *
 * The same numbers are mirrored by `CurrencyRatesService.bundledRates` in
 * `lib/services/currency_rates_service.dart`, which preview mode serves before
 * Firebase exists. **Keep the two in sync.**
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *     node tool/seed_currency_rates.js
 */

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

/**
 * How many units of each currency one unit of `base` buys.
 *
 * Keep `base` in the table itself, at 1 — it makes the cross-rate arithmetic
 * in `CurrencyRates.convert` uniform, with no special case for "the base".
 */
const RATES = {
  base: "USD",
  rates: {
    USD: 1,
    IQD: 1310,
    EUR: 0.92,
  },
};

async function main() {
  await db.collection("currency_rates").doc("latest").set({
    ...RATES,
    id: "latest",
    source: "manual",
    createdBy: "seed-script",
    updatedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log("seeded currency_rates/latest");
  console.log(
    "\n⚠️ Indicative rates only, and nothing refreshes them yet — see the" +
      "\nheader of this file before release.",
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
