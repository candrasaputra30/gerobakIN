const express = require('express');
const router = express.Router();
const db = require('../db/database');
const auth = require('../middleware/auth');

// ambil semua gerobak tersedia
router.get('/carts', (req, res) => {
  const carts = db.prepare('SELECT * FROM carts').all();
  res.json(carts);
});

// tambah gerobak - admin only
router.post('/carts', auth, (req, res) => {
  if (req.user.role !== 'admin')
    return res.status(403).json({ message: 'Admin only' });

  const { name, type, price_per_hour, price_per_day, stock } = req.body;
  const result = db.prepare(`
    INSERT INTO carts (name, type, price_per_hour, price_per_day, stock)
    VALUES (?, ?, ?, ?, ?)
  `).run(name, type, price_per_hour, price_per_day, stock || 1);

  res.json({ message: 'Gerobak ditambahkan', cartId: result.lastInsertRowid });
});

// buat rental baru
router.post('/', auth, (req, res) => {
  const { cart_id, start_date, end_date, duration_hours, deposit } = req.body;
  if (!cart_id || !start_date || !end_date)
    return res.status(400).json({ message: 'Data tidak lengkap' });

  // cek konflik jadwal
  const conflict = db.prepare(`
    SELECT id FROM cart_rentals
    WHERE cart_id = ?
    AND status NOT IN ('cancelled', 'completed')
    AND NOT (end_date <= ? OR start_date >= ?)
  `).get(cart_id, start_date, end_date);

  if (conflict)
    return res.status(400).json({ message: 'Gerobak sudah dipesan pada periode ini' });

  const cart = db.prepare('SELECT * FROM carts WHERE id = ?').get(cart_id);
  if (!cart) return res.status(404).json({ message: 'Gerobak tidak ditemukan' });

  const total_price = duration_hours
    ? cart.price_per_hour * duration_hours
    : cart.price_per_day;

  const result = db.prepare(`
    INSERT INTO cart_rentals
    (user_id, cart_id, start_date, end_date, duration_hours, total_price, deposit)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(req.user.id, cart_id, start_date, end_date, duration_hours, total_price, deposit || 0);

  res.json({ message: 'Rental berhasil', rentalId: result.lastInsertRowid });
});

// ambil rental user
router.get('/my', auth, (req, res) => {
  const rentals = db.prepare(`
    SELECT r.*, c.name as cart_name, c.type as cart_type
    FROM cart_rentals r
    LEFT JOIN carts c ON r.cart_id = c.id
    WHERE r.user_id = ?
    ORDER BY r.created_at DESC
  `).all(req.user.id);
  res.json(rentals);
});

// update status rental
router.put('/:id/status', auth, (req, res) => {
  const { status } = req.body;
  const validStatus = [
    'pending', 'approved', 'waiting_pickup', 'rented',
    'waiting_return', 'returned', 'inspecting', 'completed', 'cancelled'
  ];
  if (!validStatus.includes(status))
    return res.status(400).json({ message: 'Status tidak valid' });

  db.prepare('UPDATE cart_rentals SET status = ? WHERE id = ?')
    .run(status, req.params.id);
  res.json({ message: 'Status diupdate' });
});

module.exports = router;
