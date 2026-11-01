const express = require('express');
const router = express.Router();
const db = require('../db/database');
const auth = require('../middleware/auth');

// buat booking baru
router.post('/', auth, (req, res) => {
  const { vehicle_id, pickup_location, destination, total_price } = req.body;
  if (!vehicle_id || !pickup_location || !destination)
    return res.status(400).json({ message: 'Data tidak lengkap' });

  const stmt = db.prepare(`
    INSERT INTO bookings (user_id, vehicle_id, pickup_location, destination, total_price)
    VALUES (?, ?, ?, ?, ?)
  `);
  const result = stmt.run(req.user.id, vehicle_id, pickup_location, destination, total_price);
  res.json({ message: 'Booking berhasil', bookingId: result.lastInsertRowid });
});

// ambil semua booking user
router.get('/my', auth, (req, res) => {
  const bookings = db.prepare(`
    SELECT b.*, v.name as vehicle_name, v.type as vehicle_type
    FROM bookings b
    LEFT JOIN vehicles v ON b.vehicle_id = v.id
    WHERE b.user_id = ?
    ORDER BY b.created_at DESC
  `).all(req.user.id);
  res.json(bookings);
});

// update status booking - driver/admin
router.put('/:id/status', auth, (req, res) => {
  const { status } = req.body;
  const validStatus = [
    'pending', 'confirmed', 'driver_heading',
    'driver_arrived', 'in_progress', 'completed', 'cancelled'
  ];
  if (!validStatus.includes(status))
    return res.status(400).json({ message: 'Status tidak valid' });

  db.prepare('UPDATE bookings SET status = ? WHERE id = ?')
    .run(status, req.params.id);
  res.json({ message: 'Status diupdate' });
});

// ambil semua booking - admin
router.get('/all', auth, (req, res) => {
  if (req.user.role !== 'admin')
    return res.status(403).json({ message: 'Admin only' });

  const bookings = db.prepare(`
    SELECT b.*, u.name as customer_name, u.phone,
           v.name as vehicle_name
    FROM bookings b
    LEFT JOIN users u ON b.user_id = u.id
    LEFT JOIN vehicles v ON b.vehicle_id = v.id
    ORDER BY b.created_at DESC
  `).all();
  res.json(bookings);
});

module.exports = router;
