const admin = require('firebase-admin');

// Adjust path to match whatever service account key you used for the demo seed
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const ADMIN_UID = 'PuAN5X7ZDFWX3iSkWdGt4U195nG3';

const categories = ['Food & Beverages', 'Dairy', 'Personal Care', 'Household', 'Snacks', 'Bakery'];

const items = [
  { name: 'Basmati Rice 5kg', category: 'Food & Beverages', quantity: 120, unitPrice: 8.5, reorderLevel: 20, supplier: 'Golden Grain Co.' },
  { name: 'Cooking Oil 2L', category: 'Food & Beverages', quantity: 8, unitPrice: 6.2, reorderLevel: 15, supplier: 'Sunrise Oils' },
  { name: 'Whole Milk 1L', category: 'Dairy', quantity: 0, unitPrice: 1.4, reorderLevel: 10, supplier: 'DairyPure' },
  { name: 'Cheddar Cheese 500g', category: 'Dairy', quantity: 34, unitPrice: 4.9, reorderLevel: 10, supplier: 'DairyPure' },
  { name: 'Yoghurt 1L', category: 'Dairy', quantity: 5, unitPrice: 2.3, reorderLevel: 12, supplier: 'DairyPure' },
  { name: 'Shampoo 400ml', category: 'Personal Care', quantity: 42, unitPrice: 5.0, reorderLevel: 10, supplier: 'CleanLife' },
  { name: 'Toothpaste 100g', category: 'Personal Care', quantity: 60, unitPrice: 2.1, reorderLevel: 15, supplier: 'CleanLife' },
  { name: 'Dish Soap 750ml', category: 'Household', quantity: 25, unitPrice: 3.2, reorderLevel: 10, supplier: 'HomeFresh' },
  { name: 'Paper Towels (6-pack)', category: 'Household', quantity: 18, unitPrice: 7.5, reorderLevel: 8, supplier: 'HomeFresh' },
  { name: 'Potato Chips 150g', category: 'Snacks', quantity: 90, unitPrice: 1.8, reorderLevel: 20, supplier: 'CrunchCo' },
  { name: 'Chocolate Bar 100g', category: 'Snacks', quantity: 75, unitPrice: 1.5, reorderLevel: 20, supplier: 'SweetTreats' },
  { name: 'Sourdough Loaf', category: 'Bakery', quantity: 12, unitPrice: 3.75, reorderLevel: 10, supplier: 'Local Bakery Co.' },
  { name: 'Croissants (6-pack)', category: 'Bakery', quantity: 6, unitPrice: 4.5, reorderLevel: 8, supplier: 'Local Bakery Co.' },
];

function randomPastDate(daysAgoMax) {
  const daysAgo = Math.floor(Math.random() * daysAgoMax);
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  return d;
}

async function seed() {
  const userRef = db.collection('users').doc(ADMIN_UID);

  const inventoryRef = userRef.collection('inventory_items');
  const categoriesRef = userRef.collection('categories');
  const movementsRef = userRef.collection('stock_movements');

  // 1. Categories
  console.log('Seeding categories...');
  const catBatch = db.batch();
  categories.forEach((name) => {
    const docRef = categoriesRef.doc();
    catBatch.set(docRef, { name });
  });
  await catBatch.commit();

  // 2. Inventory items
  console.log('Seeding inventory items...');
  const itemRefs = [];
  const itemBatch = db.batch();
  for (const item of items) {
    const docRef = inventoryRef.doc();
    const createdAt = randomPastDate(120);
    const updatedAt = new Date();
    itemBatch.set(docRef, {
      name: item.name,
      description: `${item.name} — stock item`,
      category: item.category,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      supplier: item.supplier,
      createdAt: createdAt.toISOString(),
      updatedAt: updatedAt.toISOString(),
      reorderLevel: item.reorderLevel,
      imageUrl: null,
      expiryDate: null,
      isPerishable: ['Dairy', 'Bakery'].includes(item.category),
    });
    itemRefs.push({ id: docRef.id, name: item.name });
  }
  await itemBatch.commit();

  // 3. Stock movements — spread across the last 6 months so "Monthly Trends"
  // shows multiple bars, not just one lump like the earlier screenshot.
  console.log('Seeding stock movements...');
  const movementBatch = db.batch();
  let movementCount = 0;

  for (const item of itemRefs) {
    const numMovements = 3 + Math.floor(Math.random() * 4); // 3-6 movements per item
    for (let i = 0; i < numMovements; i++) {
      const docRef = movementsRef.doc();
      const isStockIn = Math.random() > 0.4;
      const timestamp = randomPastDate(180); // up to 6 months back

      movementBatch.set(docRef, {
        itemId: item.id,
        itemName: item.name,
        type: isStockIn ? 'stockIn' : 'stockOut',
        quantity: 5 + Math.floor(Math.random() * 40),
        reason: isStockIn ? 'Restock' : 'Sale',
        timestamp: admin.firestore.Timestamp.fromDate(timestamp), // must be a real Timestamp, not a string
        userId: ADMIN_UID,
        userName: 'peter',
      });
      movementCount++;
    }
  }
  await movementBatch.commit();

  console.log(`Done. Seeded ${items.length} items, ${categories.length} categories, ${movementCount} stock movements for admin ${ADMIN_UID}.`);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});