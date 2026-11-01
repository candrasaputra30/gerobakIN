const express = require('express');
const router = express.Router();
const db = require('../db/database');
const auth = require('../middleware/auth');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: '/data/data/com.termux/files/home/gerobak-backend/public/uploads/',
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// buat pembayaran baru
router.post('/', auth, (req, res) => {
  const { booking_id, amount, method, notes } = req.body;
  if (!amount) return res.status(400).json({ message: 'Amount wajib diisi' });

  const result = db.prepare(`
    INSERT INTO payments (booking_id, user_id, amount, method, notes)
    VALUES (?, ?, ?, ?, ?)
  `).run(booking_id, req.user.id, amount, method || 'transfer', notes);

  res.json({ message: 'Pembayaran dibuat', paymentId: result.lastInsertRowid });
});

// upload bukti bayar
router.post('/:id/proof', auth, upload.single('proof'), (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'File tidak ada' });
  const url = `/uploads/${req.file.filename}`;
  db.prepare('UPDATE payments SET proof_url = ?, status = ? WHERE id = ?')
    .run(url, 'waiting_confirmation', req.params.id);
  res.json({ message: 'Bukti berhasil diupload', url });
});

// konfirmasi pembayaran - admin only
router.put('/:id/confirm', auth, (req, res) => {
  if (req.user.role !== 'admin')
    return res.status(403).json({ message: 'Admin only' });

  db.prepare('UPDATE payments SET status = ? WHERE id = ?')
    .run('confirmed', req.params.id);
  res.json({ message: 'Pembayaran dikonfirmasi' });
});

// ambil semua pembayaran - admin
router.get('/all', auth, (req, res) => {
  if (req.user.role !== 'admin')
    return res.status(403).json({ message: 'Admin only' });

  const payments = db.prepare(`
    SELECT p.*, u.name as customer_name, u.phone,
           b.pickup_location, b.destination
    FROM payments p
    LEFT JOIN users u ON p.user_id = u.id
    LEFT JOIN bookings b ON p.booking_id = b.id
    ORDER BY p.created_at DESC
  `).all();
  res.json(payments);
});

// ambil pembayaran user
router.get('/my', auth, (req, res) => {
  const payments = db.prepare(`
    SELECT p.*, b.pickup_location, b.destination, b.status as booking_status
    FROM payments p
    LEFT JOIN bookings b ON p.booking_id = b.id
    WHERE p.user_id = ?
    ORDER BY p.created_at DESC
  `).all(req.user.id);
  res.json(payments);
});

module.exports = router;
