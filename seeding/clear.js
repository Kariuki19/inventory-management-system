/**
 * Deletes all documents in the DEDICATED demo collections only
 * (demo_categories, demo_inventory_items, demo_stock_movements,
 * demo_stock_predictions). Never touches your live collections.
 * Run this before `npm run seed` if you want a clean re-seed
 * instead of appending on top of existing demo docs.
 *
 *   npm run clear
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const DEMO_ADMIN_UID = 'demo_admin_seed';

const DEMO_COLLECTIONS = [
  'demo_categories',
  'demo_inventory_items',
  'demo_stock_movements',
  'demo_stock_predictions',
];

async function clearCollection(name) {
  const snapshot = await db.collection('users').doc(DEMO_ADMIN_UID).collection(name).get();
  if (snapshot.empty) {
    console.log(`"${name}" already empty`);
    return;
  }
  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log(`Cleared ${snapshot.size} docs from "users/${DEMO_ADMIN_UID}/${name}"`);
}

async function main() {
  for (const name of DEMO_COLLECTIONS) {
    await clearCollection(name);
  }
  console.log('Done clearing demo collections.');
  process.exit(0);
}

main().catch((err) => {
  console.error('Clear failed:', err);
  process.exit(1);
});
