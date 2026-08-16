/**
 * Seeds every document in the `legal_documents` collection.
 *
 * Reads `assets/legal/legal_documents.json` — the **single source of truth**,
 * which the app also bundles and serves in preview mode. Nothing is retyped
 * here, so the wording the app shows and the wording in Firestore cannot
 * drift apart. Add a document to that JSON file and it gets seeded by this
 * script and rendered by the app automatically.
 *
 * Writes (one per row on the Policy hub):
 *   terms_of_service        — also the consent gate during registration
 *   privacy_policy
 *   cancellation_refunds
 *   payment_policy
 *   liability_disclaimer
 *   contact_complaints
 *   account_data_deletion
 *
 * `updatedAt` in the JSON is an ISO-8601 string; it is replaced here with a
 * Firestore server timestamp so the "Last updated" line reflects the write.
 *
 * ⚠️ Every document has `legalReviewed: false`, and the app shows a visible
 * warning banner while it is. Flip it to true only once the wording —
 * especially the Kurdish and Arabic renderings, which were translated rather
 * than drafted by a legal translator — has been signed off.
 *
 * ⚠️ Several documents contain [square-bracket placeholders] (support email,
 * phone number, business name and address, response times, payment methods).
 * Replace them in the JSON before release; `contact_complaints` says so in
 * its own text.
 *
 * ⚠️ `terms_of_service` is seeded at **version 2**. Consent is recorded
 * against the version in `users.termsVersion`, so anyone who accepted v1 has
 * not accepted this wording and should be re-prompted.
 *
 * Usage:
 *   1. Download a service-account key from
 *      Firebase Console → Project Settings → Service accounts.
 *      Do NOT commit it — .gitignore already covers *-service-account.json.
 *   2. cd functions && npm install && cd ..
 *   3. GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
 *        node tool/seed_legal_documents.js
 */

const fs = require("fs");
const path = require("path");
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const ASSET = path.join(
  __dirname,
  "..",
  "assets",
  "legal",
  "legal_documents.json"
);

/** Mirrors LegalBlock.tryParse, so a bad block fails here instead of shipping. */
function validateBlock(docId, locale, s, b, block) {
  const where = `${docId}/${locale} section ${s} block ${b}`;
  if (!block || typeof block !== "object") {
    throw new Error(`${where} is not an object`);
  }
  if (block.type !== "paragraph" && block.type !== "bullet") {
    throw new Error(`${where} has an unknown type "${block.type}"`);
  }
  if (typeof block.text !== "string" || block.text.trim() === "") {
    throw new Error(`${where} has no text`);
  }
  if (block.lead !== undefined && typeof block.lead !== "string") {
    throw new Error(`${where} has a non-string lead`);
  }
}

/**
 * Checks that every locale of a document has the same shape as English — the
 * same guarantee the Dart test suite enforces, repeated here so a bad edit
 * can't be seeded from a machine that never ran the tests.
 */
function validate(docId, doc) {
  if (typeof doc.version !== "number") {
    throw new Error(`${docId} has no numeric version`);
  }
  const content = doc.content;
  if (!content || !content.en) throw new Error(`${docId} has no English text`);

  const reference = content.en.sections;
  for (const [locale, body] of Object.entries(content)) {
    const sections = body.sections;
    if (!Array.isArray(sections)) {
      throw new Error(`${docId}/${locale} has no sections array`);
    }
    if (sections.length !== reference.length) {
      throw new Error(
        `${docId}/${locale} has ${sections.length} sections, English has ` +
          `${reference.length}`
      );
    }
    sections.forEach((section, s) => {
      const ref = reference[s];
      const hasHeading = Boolean(section.heading);
      if (hasHeading !== Boolean(ref.heading)) {
        throw new Error(
          `${docId}/${locale} section ${s} disagrees with English about ` +
            `having a heading`
        );
      }
      if (section.blocks.length !== ref.blocks.length) {
        throw new Error(
          `${docId}/${locale} section ${s} has ${section.blocks.length} ` +
            `blocks, English has ${ref.blocks.length}`
        );
      }
      section.blocks.forEach((block, b) => {
        validateBlock(docId, locale, s, b, block);
        if (Boolean(block.lead) !== Boolean(ref.blocks[b].lead)) {
          throw new Error(
            `${docId}/${locale} section ${s} block ${b} disagrees with ` +
              `English about its bold lead-in`
          );
        }
      });
    });
  }
}

async function main() {
  const raw = JSON.parse(fs.readFileSync(ASSET, "utf8"));
  const entries = Object.entries(raw).filter(([id]) => !id.startsWith("_"));

  if (entries.length === 0) {
    throw new Error(`No documents found in ${ASSET}`);
  }

  // Validate everything before writing anything, so a bad file can't leave
  // the collection half-updated.
  for (const [docId, doc] of entries) validate(docId, doc);

  let unreviewed = 0;
  let placeholders = 0;

  for (const [docId, doc] of entries) {
    const { updatedAt, ...rest } = doc;
    await db
      .collection("legal_documents")
      .doc(docId)
      .set({
        ...rest,
        updatedAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
        source: "manual",
      });
    console.log(`Seeded legal_documents/${docId} (version ${doc.version}).`);

    if (!doc.legalReviewed) unreviewed++;
    if (JSON.stringify(doc).match(/\[[^\]]+\]/)) placeholders++;
  }

  console.log(`\nDone — ${entries.length} documents.`);
  if (unreviewed > 0) {
    console.log(
      `NOTE: ${unreviewed} have legalReviewed:false — the app shows a warning.`
    );
  }
  if (placeholders > 0) {
    console.log(
      `NOTE: ${placeholders} still contain [square-bracket placeholders].`
    );
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
