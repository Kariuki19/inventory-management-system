/**
 * Seeds the ONE shared, pre-entered demo dataset that every public/anonymous
 * trial user reads from.
 *
 * Firestore structure:
 * users/demo_admin_seed/demo_categories
 * users/demo_admin_seed/demo_inventory_items
 * users/demo_admin_seed/demo_stock_movements
 * users/demo_admin_seed/demo_stock_predictions
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const Timestamp = admin.firestore.Timestamp;

// Helpers to build Timestamps for past and future dates
const daysAgo = (n) => Timestamp.fromDate(new Date(Date.now() - n * 24 * 60 * 60 * 1000));
const daysInFuture = (n) => Timestamp.fromDate(new Date(Date.now() + n * 24 * 60 * 60 * 1000));

// ---------- CATEGORIES ----------
const categories = [
  { id: 'cat_beverages',   name: 'Food & Beverages', description: 'Juices, water, sodas, and drinks' },
{ id: 'cat_snacks',      name: 'Snacks',           description: 'Chips, biscuits, and packaged snacks' },
{ id: 'cat_dairy',       name: 'Dairy',            description: 'Milk, yoghurt, cheese, and related products' },
{ id: 'cat_bakery',      name: 'Bakery',           description: 'Bread, pastries, and baked goods' },
{ id: 'cat_household',   name: 'Household',        description: 'Cleaning and home supplies' },
{ id: 'cat_personal',    name: 'Personal Care',    description: 'Toiletries and personal hygiene items' },
];

// ---------- INVENTORY ITEMS ----------
const inventoryItems = [
  {
    id: 'item_afia_juice',
    name: 'Afia Juice 1L',
    itemName: 'Afia Juice 1L',
    description: '1 Litre natural fruit juice blend',
    category: 'Food & Beverages',
    categoryId: 'cat_beverages',
    categoryName: 'Food & Beverages',
    unit: 'bottle',
    quantity: 2527,
    unitPrice: 120.00,
    price: 120.00,
    costPrice: 90.00,
    sellingPrice: 120.00,
    currency: 'KSh',
    supplier: 'Afia Distributors Ltd',
    reorderLevel: 500,
    isPerishable: true,
    expiryDate: daysInFuture(180),
    imageUrl: null,
  },
{
  id: 'item_delmonte',
  name: 'Delmonte Juice 500ml',
  itemName: 'Delmonte Juice 500ml',
  description: '500ml premium fruit juice',
  category: 'Food & Beverages',
  categoryId: 'cat_beverages',
  categoryName: 'Food & Beverages',
  unit: 'bottle',
  quantity: 940,
  unitPrice: 95.00,
  price: 95.00,
  costPrice: 70.00,
  sellingPrice: 95.00,
  currency: 'KSh',
  supplier: 'Delmonte Kenya',
  reorderLevel: 200,
  isPerishable: true,
  expiryDate: daysInFuture(120),
  imageUrl: null,
},
{
  id: 'item_coke_500ml',
  name: 'Coca-Cola 500ml',
  itemName: 'Coca-Cola 500ml',
  description: '500ml carbonated soft drink',
  category: 'Food & Beverages',
  categoryId: 'cat_beverages',
  categoryName: 'Food & Beverages',
  unit: 'bottle',
  quantity: 1800,
  unitPrice: 65.00,
  price: 65.00,
  costPrice: 45.00,
  sellingPrice: 65.00,
  currency: 'KSh',
  supplier: 'Coastal Bottlers',
  reorderLevel: 400,
  isPerishable: false,
  expiryDate: null,
  imageUrl: null,
},
{
  id: 'item_crisps_big',
  name: 'Tropical Heat Crisps',
  itemName: 'Tropical Heat Crisps',
  description: 'Salted potato crisps 150g',
  category: 'Snacks',
  categoryId: 'cat_snacks',
  categoryName: 'Snacks',
  unit: 'packet',
  quantity: 45,
  unitPrice: 80.00,
  price: 80.00,
  costPrice: 55.00,
  sellingPrice: 80.00,
  currency: 'KSh',
  supplier: 'Tropical Heat Ltd',
  reorderLevel: 100,
  isPerishable: true,
  expiryDate: daysInFuture(90),
  imageUrl: null,
},
{
  id: 'item_digestive',
  name: 'Digestive Biscuits',
  itemName: 'Digestive Biscuits',
  description: 'Wheat digestive biscuits 200g',
  category: 'Snacks',
  categoryId: 'cat_snacks',
  categoryName: 'Snacks',
  unit: 'packet',
  quantity: 210,
  unitPrice: 85.00,
  price: 85.00,
  costPrice: 60.00,
  sellingPrice: 85.00,
  currency: 'KSh',
  supplier: 'Manji Food Industries',
  reorderLevel: 80,
  isPerishable: true,
  expiryDate: daysInFuture(150),
  imageUrl: null,
},
{
  id: 'item_milk_500ml',
  name: 'Fresh Milk 500ml',
  itemName: 'Fresh Milk 500ml',
  description: 'Pasteurized fresh cow milk 500ml',
  category: 'Dairy',
  categoryId: 'cat_dairy',
  categoryName: 'Dairy',
  unit: 'packet',
  quantity: 640,
  unitPrice: 55.00,
  price: 55.00,
  costPrice: 40.00,
  sellingPrice: 55.00,
  currency: 'KSh',
  supplier: 'Brookside Dairy',
  reorderLevel: 150,
  isPerishable: true,
  expiryDate: daysInFuture(7),
  imageUrl: null,
},
{
  id: 'item_yoghurt_1l',
  name: 'Yoghurt 1L',
  itemName: 'Yoghurt 1L',
  description: 'Strawberry flavored drinking yoghurt',
  category: 'Dairy',
  categoryId: 'cat_dairy',
  categoryName: 'Dairy',
  unit: 'bottle',
  quantity: 0,
  unitPrice: 200.00,
  price: 200.00,
  costPrice: 150.00,
  sellingPrice: 200.00,
  currency: 'KSh',
  supplier: 'Brookside Dairy',
  reorderLevel: 60,
  isPerishable: true,
  expiryDate: daysInFuture(14),
  imageUrl: null,
},
{
  id: 'item_bread_400g',
  name: 'White Bread 400g',
  itemName: 'White Bread 400g',
  description: 'Sliced white bread 400g',
  category: 'Bakery',
  categoryId: 'cat_bakery',
  categoryName: 'Bakery',
  unit: 'loaf',
  quantity: 130,
  unitPrice: 65.00,
  price: 65.00,
  costPrice: 48.00,
  sellingPrice: 65.00,
  currency: 'KSh',
  supplier: 'Broadways Bakery',
  reorderLevel: 100,
  isPerishable: true,
  expiryDate: daysInFuture(5),
  imageUrl: null,
},
{
  id: 'item_detergent_1kg',
  name: 'Detergent Powder 1kg',
  itemName: 'Detergent Powder 1kg',
  description: 'Washing powder 1kg pack',
  category: 'Household',
  categoryId: 'cat_household',
  categoryName: 'Household',
  unit: 'packet',
  quantity: 410,
  unitPrice: 240.00,
  price: 240.00,
  costPrice: 180.00,
  sellingPrice: 240.00,
  currency: 'KSh',
  supplier: 'Omo Distributors',
  reorderLevel: 120,
  isPerishable: false,
  expiryDate: null,
  imageUrl: null,
},
{
  id: 'item_soap_bar',
  name: 'Bathing Soap Bar',
  itemName: 'Bathing Soap Bar',
  description: 'Hygiene bathing soap 200g bar',
  category: 'Personal Care',
  categoryId: 'cat_personal',
  categoryName: 'Personal Care',
  unit: 'piece',
  quantity: 560,
  unitPrice: 50.00,
  price: 50.00,
  costPrice: 35.00,
  sellingPrice: 50.00,
  currency: 'KSh',
  supplier: 'PZ Cussons Kenya',
  reorderLevel: 150,
  isPerishable: false,
  expiryDate: null,
  imageUrl: null,
},
];

// ---------- STOCK MOVEMENTS ----------
const stockMovements = [
  { itemId: 'item_afia_juice',   itemName: 'Afia Juice 1L',        quantity: 2527, reason: 'Initial inventory load', type: 'stockIn',  daysAgo: 1, userId: 'demo_user_1', userName: 'Amidu Dabor' },
{ itemId: 'item_delmonte',     itemName: 'Delmonte Juice 500ml', quantity: 300,  reason: 'Weekly restock',         type: 'stockIn',  daysAgo: 2, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
{ itemId: 'item_coke_500ml',   itemName: 'Coca-Cola 500ml',      quantity: 500,  reason: 'Supplier delivery',     type: 'stockIn',  daysAgo: 3, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
{ itemId: 'item_crisps_big',   itemName: 'Tropical Heat Crisps', quantity: 60,   reason: 'Retail sale',            type: 'stockOut', daysAgo: 1, userId: 'demo_user_1', userName: 'Amidu Dabor' },
{ itemId: 'item_digestive',    itemName: 'Digestive Biscuits',   quantity: 40,   reason: 'Retail sale',            type: 'stockOut', daysAgo: 2, userId: 'demo_user_3', userName: 'Peter Otieno' },
{ itemId: 'item_milk_500ml',   itemName: 'Fresh Milk 500ml',     quantity: 200,  reason: 'Morning delivery',       type: 'stockIn',  daysAgo: 1, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
{ itemId: 'item_yoghurt_1l',   itemName: 'Yoghurt 1L',           quantity: 15,   reason: 'Expired stock removed',  type: 'stockOut', daysAgo: 4, userId: 'demo_user_1', userName: 'Amidu Dabor' },
{ itemId: 'item_bread_400g',   itemName: 'White Bread 400g',     quantity: 80,   reason: 'Daily bakery delivery',  type: 'stockIn',  daysAgo: 1, userId: 'demo_user_3', userName: 'Peter Otieno' },
{ itemId: 'item_detergent_1kg',itemName: 'Detergent Powder 1kg', quantity: 100,  reason: 'Bulk restock',           type: 'stockIn',  daysAgo: 5, userId: 'demo_user_2', userName: 'Grace Wanjiru' },
{ itemId: 'item_soap_bar',     itemName: 'Bathing Soap Bar',     quantity: 90,   reason: 'Retail sale',            type: 'stockOut', daysAgo: 2, userId: 'demo_user_1', userName: 'Amidu Dabor' },
];

// ---------- STOCK PREDICTIONS (Matching StockPrediction.fromMap) ----------
const stockPredictions = [
  {
    itemId: 'item_afia_juice',
    itemName: 'Afia Juice 1L',
    currentQuantity: 2527,
    averageDailyUsage: 60,
    daysLeft: 42,
    needsRestock: false,
    confidence: 'high',
  },
{
  itemId: 'item_delmonte',
  itemName: 'Delmonte Juice 500ml',
  currentQuantity: 940,
  averageDailyUsage: 30,
  daysLeft: 31,
  needsRestock: false,
  confidence: 'medium',
},
{
  itemId: 'item_coke_500ml',
  itemName: 'Coca-Cola 500ml',
  currentQuantity: 1800,
  averageDailyUsage: 50,
  daysLeft: 36,
  needsRestock: false,
  confidence: 'high',
},
{
  itemId: 'item_crisps_big',
  itemName: 'Tropical Heat Crisps',
  currentQuantity: 45,
  averageDailyUsage: 15,
  daysLeft: 3,
  needsRestock: true,
  confidence: 'low',
},
{
  itemId: 'item_yoghurt_1l',
  itemName: 'Yoghurt 1L',
  currentQuantity: 0,
  averageDailyUsage: 10,
  daysLeft: 0,
  needsRestock: true,
  confidence: 'high',
},
{
  itemId: 'item_milk_500ml',
  itemName: 'Fresh Milk 500ml',
  currentQuantity: 640,
  averageDailyUsage: 40,
  daysLeft: 16,
  needsRestock: false,
  confidence: 'high',
},
{
  itemId: 'item_bread_400g',
  itemName: 'White Bread 400g',
  currentQuantity: 130,
  averageDailyUsage: 25,
  daysLeft: 5,
  needsRestock: true,
  confidence: 'medium',
},
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
    inventoryItems.map((i) => ({
      ...i,
      createdAt: daysAgo(30),
                               lastUpdated: daysAgo(1),
    })),
    'id'
  );

  // demo_stock_movements
  await seedCollection(
    'demo_stock_movements',
    stockMovements.map(({ daysAgo: d, ...m }) => ({ ...m, timestamp: daysAgo(d) })),
                       '__none__'
  );

  // demo_stock_predictions
  await seedCollection(
    'demo_stock_predictions',
    stockPredictions.map((p) => ({ ...p, calculatedAt: daysAgo(1) })),
                       'itemId'
  );

  console.log('Done seeding demo data.');
  process.exit(0);
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
