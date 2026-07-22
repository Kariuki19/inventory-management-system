/**
 * Seeds the ONE shared, pre-entered demo dataset that every public/anonymous
 * trial user reads from. This matches your app's actual data model:
 * InventoryService nests everything under `users/{adminUid}/{collection}`,
 * so the demo data lives at:
 *
 *   users/demo_admin_seed/demo_categories
 *   users/demo_admin_seed/demo_inventory_items
 *   users/demo_admin_seed/demo_stock_movements
 *   users/demo_admin_seed/demo_stock_predictions
 *
 * `demo_admin_seed` is NOT a real Firebase Auth account — it's just a
 * reserved document ID under `users/` that InventoryService routes
 * anonymous/trial users to (see `_sharedDemoAdminUid` in inventory_service.dart).
 *
 * These are READ-ONLY at the security-rules level (see your firestore.rules),
 * so this script — run with the Admin SDK / a service account — is the only
 * intended way to populate or refresh this data.
 *
 * IMPORTANT: this never touches your live `users/{realAdminUid}/...` data.
 *
 * SETUP:
 *   1. Firebase Console > Project Settings > Service Accounts > Generate new private key
 *   2. Save the downloaded JSON as ./serviceAccountKey.json in this folder
 *      (do NOT commit this file — add it to .gitignore)
 *   3. npm install
 *   4. npm run seed
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const Timestamp = admin.firestore.Timestamp;

// Helper to build a Timestamp from a "days ago" offset
const daysAgo = (n) => Timestamp.fromDate(new Date(Date.now() - n * 24 * 60 * 60 * 1000));

// ---------- CATEGORIES ----------
const categories = [
  { id: 'cat_beverages',   name: 'Beverages',      description: 'Juices, water, sodas, and drinks' },
  { id: 'cat_snacks',      name: 'Snacks',         description: 'Chips, biscuits, and packaged snacks' },
  { id: 'cat_dairy',       name: 'Dairy',          description: 'Milk, yoghurt, cheese, and related products' },
  { id: 'cat_bakery',      name: 'Bakery',         description: 'Bread, pastries, and baked goods' },
  { id: 'cat_household',   name: 'Household',      description: 'Cleaning and home supplies' },
  { id: 'cat_personal',    name: 'Personal Care',  description: 'Toiletries and personal hygiene items' },
];

// ---------- INVENTORY ITEMS ----------
const inventoryItems = [
  { id: 'item_afia_juice',   name: 'Afia Juice 1L',        categoryId: 'cat_beverages', unit: 'bottle', quantity: 2527, reorderLevel: 500,  costPrice: 90,  sellingPrice: 120, supplier: 'Afia Distributors Ltd' },
  { id: 'item_delmonte',     name: 'Delmonte Juice 500ml', categoryId: 'cat_beverages', unit: 'bottle', quantity: 940,  reorderLevel: 200,  costPrice: 70,  sellingPrice: 95,  supplier: 'Delmonte Kenya' },
  { id: 'item_coke_500ml',   name: 'Coca-Cola 500ml',      categoryId: 'cat_beverages', unit: 'bottle', quantity: 1800, reorderLevel: 400,  costPrice: 45,  sellingPrice: 65,  supplier: 'Coastal Bottlers' },
  { id: 'item_crisps_big',   name: 'Tropical Heat Crisps', categoryId: 'cat_snacks',    unit: 'packet', quantity: 320,  reorderLevel: 100,  costPrice: 55,  sellingPrice: 80,  supplier: 'Tropical Heat Ltd' },
  { id: 'item_digestive',    name: 'Digestive Biscuits',   categoryId: 'cat_snacks',    unit: 'packet', quantity: 210,  reorderLevel: 80,   costPrice: 60,  sellingPrice: 85,  supplier: 'Manji Food Industries' },
  { id: 'item_milk_500ml',   name: 'Fresh Milk 500ml',     categoryId: 'cat_dairy',     unit: 'packet', quantity: 640,  reorderLevel: 150,  costPrice: 40,  sellingPrice: 55,  supplier: 'Brookside Dairy' },
  { id: 'item_yoghurt_1l',   name: 'Yoghurt 1L',           categoryId: 'cat_dairy',     unit: 'bottle', quantity: 95,   reorderLevel: 60,   costPrice: 150, sellingPrice: 200, supplier: 'Brookside Dairy' },
  { id: 'item_bread_400g',   name: 'White Bread 400g',     categoryId: 'cat_bakery',    unit: 'loaf',   quantity: 130,  reorderLevel: 100,  costPrice: 48,  sellingPrice: 65,  supplier: 'Broadways Bakery' },
  { id: 'item_detergent_1kg',name: 'Detergent Powder 1kg', categoryId: 'cat_household', unit: 'packet', quantity: 410,  reorderLevel: 120,  costPrice: 180, sellingPrice: 240, supplier: 'Omo Distributors' },
  { id: 'item_soap_bar',     name: 'Bathing Soap Bar',     categoryId: 'cat_personal',  unit: 'piece',  quantity: 560,  reorderLevel: 150,  costPrice: 35,  sellingPrice: 50,  supplier: 'PZ Cussons Kenya' },
];

// ---------- STOCK MOVEMENTS (matches your existing screenshot schema exactly) ----------
const stockMovements = [
  { itemId: 'item_afia_juice',   itemName: 'Afia Juice 1L',        quantity: 2527, reason: 'Added 1',        type: 'stockOut', daysAgo: 1,  userId: 'demo_user_1', userName: 'Amidu Dabor' },
  { itemId: 'item_delmonte',     itemName: 'Delmonte Juice 500ml', quantity: 300,  reason: 'Weekly restock', type: 'stockIn',  daysAgo: 2,  userId: 'demo_user_2', userName: 'Grace Wanjiru' },
  { itemId: 'item_coke_500ml',   itemName: 'Coca-Cola 500ml',      quantity: 500,  reason: 'Supplier delivery', type: 'stockIn', daysAgo: 3, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
  { itemId: 'item_crisps_big',   itemName: 'Tropical Heat Crisps', quantity: 60,   reason: 'Retail sale',    type: 'stockOut', daysAgo: 1,  userId: 'demo_user_1', userName: 'Amidu Dabor' },
  { itemId: 'item_digestive',    itemName: 'Digestive Biscuits',   quantity: 40,   reason: 'Retail sale',    type: 'stockOut', daysAgo: 2,  userId: 'demo_user_3', userName: 'Peter Otieno' },
  { itemId: 'item_milk_500ml',   itemName: 'Fresh Milk 500ml',     quantity: 200,  reason: 'Morning delivery', type: 'stockIn', daysAgo: 1, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
  { itemId: 'item_yoghurt_1l',   itemName: 'Yoghurt 1L',           quantity: 15,   reason: 'Expired stock removed', type: 'stockOut', daysAgo: 4, userId: 'demo_user_1', userName: 'Amidu Dabor' },
  { itemId: 'item_bread_400g',   itemName: 'White Bread 400g',     quantity: 80,   reason: 'Daily bakery delivery', type: 'stockIn', daysAgo: 1, userId: 'demo_user_3', userName: 'Peter Otieno' },
  { itemId: 'item_detergent_1kg',itemName: 'Detergent Powder 1kg', quantity: 100,  reason: 'Bulk restock',   type: 'stockIn',  daysAgo: 5,  userId: 'demo_user_2', userName: 'Grace Wanjiru' },
  { itemId: 'item_soap_bar',     itemName: 'Bathing Soap Bar',     quantity: 90,   reason: 'Retail sale',    type: 'stockOut', daysAgo: 2,  userId: 'demo_user_1', userName: 'Amidu Dabor' },
];

// ---------- STOCK PREDICTIONS ----------
const stockPredictions = [
  { itemId: 'item_afia_juice',    itemName: 'Afia Juice 1L',        predictedDemand: 1800, confidence: 0.87, period: 'next_30_days', recommendedReorderQty: 1200 },
  { itemId: 'item_delmonte',      itemName: 'Delmonte Juice 500ml', predictedDemand: 620,  confidence: 0.81, period: 'next_30_days', recommendedReorderQty: 400 },
  { itemId: 'item_coke_500ml',    itemName: 'Coca-Cola 500ml',      predictedDemand: 1400, confidence: 0.90, period: 'next_30_days', recommendedReorderQty: 900 },
  { itemId: 'item_crisps_big',    itemName: 'Tropical Heat Crisps', predictedDemand: 260,  confidence: 0.74, period: 'next_30_days', recommendedReorderQty: 200 },
  { itemId: 'item_milk_500ml',    itemName: 'Fresh Milk 500ml',     predictedDemand: 900,  confidence: 0.88, period: 'next_30_days', recommendedReorderQty: 500 },
  { itemId: 'item_bread_400g',    itemName: 'White Bread 400g',     predictedDemand: 500,  confidence: 0.79, period: 'next_30_days', recommendedReorderQty: 350 },
];

const DEMO_ADMIN_UID = 'demo_admin_seed';

function demoCollection(name) {
  return db.collection('users').doc(DEMO_ADMIN_UID).collection(name);
}

async function seedCollection(name, docs, idField = 'id') {
  const batch = db.batch();
  const coll = demoCollection(name);
  docs.forEach((doc) => {
    const { [idField]: docId, ...data } = doc;
    const ref = docId ? coll.doc(docId) : coll.doc();
    batch.set(ref, data);
  });
  await batch.commit();
  console.log(`Seeded ${docs.length} docs into "users/${DEMO_ADMIN_UID}/${name}"`);
}

async function main() {
  // Stub parent doc purely so `users/demo_admin_seed` shows up in the
  // Firebase Console (Firestore doesn't require it to exist for the
  // subcollections below to work, but it's easier to find this way).
  await db.collection('users').doc(DEMO_ADMIN_UID).set(
    {
      displayName: 'Demo Dataset (do not delete)',
      isDemoSeedAccount: true,
      note: 'Reserved namespace for the public trial demo dataset. Not a real account.',
    },
    { merge: true }
  );

  // demo_categories
  await seedCollection(
    'demo_categories',
    categories.map((c) => ({ ...c, createdAt: daysAgo(30) })),
    'id'
  );

  // demo_inventory_items
  await seedCollection(
    'demo_inventory_items',
    inventoryItems.map((i) => {
      const category = categories.find((c) => c.id === i.categoryId);
      return { ...i, categoryName: category ? category.name : null, lastUpdated: daysAgo(1) };
    }),
    'id'
  );

  // demo_stock_movements (no fixed id — auto-generated, like your existing docs)
  await seedCollection(
    'demo_stock_movements',
    stockMovements.map(({ daysAgo: d, ...m }) => ({ ...m, timestamp: daysAgo(d) })),
    '__none__' // no matching field -> forces auto-id
  );

  // demo_stock_predictions
  await seedCollection(
    'demo_stock_predictions',
    stockPredictions.map((p) => ({ ...p, generatedAt: daysAgo(1) })),
    '__none__'
  );

  console.log('Done seeding demo data.');
  process.exit(0);
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
