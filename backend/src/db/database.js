const Database = require('better-sqlite3');
const path = require('path');

const db = new Database(path.join(__dirname, '../../gerobak.db'));

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'customer',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    capacity TEXT,
    price_per_km REAL,
    status TEXT DEFAULT 'available'
  );
  CREATE TABLE IF NOT EXISTS carts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    price_per_hour REAL,
    price_per_day REAL,
    stock INTEGER DEFAULT 1,
    status TEXT DEFAULT 'available'
  );
  CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    vehicle_id INTEGER,
    pickup_location TEXT,
    destination TEXT,
    status TEXT DEFAULT 'pending',
    total_price REAL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );
  CREATE TABLE IF NOT EXISTS cart_rentals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    cart_id INTEGER,
    start_date TEXT,
    end_date TEXT,
    duration_hours INTEGER,
    total_price REAL,
    deposit REAL DEFAULT 0,
    status TEXT DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(cart_id) REFERENCES carts(id)
  );
  CREATE TABLE IF NOT EXISTS app_version (
    id INTEGER PRIMARY KEY,
    version TEXT NOT NULL,
    apk_url TEXT,
    changelog TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  INSERT OR IGNORE INTO app_version (id, version, apk_url, changelog)
  VALUES (1, '1.0.0', '', 'Initial release');
`);

module.exports = db;
