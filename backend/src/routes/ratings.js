const express = require('express');
const router = express.Router();
const Database = require('better-sqlite3');
const db = new Database('/data/data/com.termux/files/home/gerobak-backend/gerobak.db');
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET || 'gerobakIN_secret';

const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  try { req.user = jwt.verify(token, SECRET); next(); }
  catch { res.status(401).json({ error: 'Token invalid' }); }
};

router.post('/', auth, (req, res) => {
  const { booking_id, booking_type, rating, review, target_id, target_type } = req.body;
  if (rating < 1 || rating > 5) return res.status(400).json({ error: 'Rating 1-5' });
  const exist = db.prepare('SELECT id FROM ratings WHERE booking_id=? AND booking_type=? AND user_id=?').get(booking_id, booking_type||'booking', req.user.id);
  if (exist) return res.status(409).json({ error: 'Sudah pernah rating' });
  const result = db.prepare('INSERT INTO ratings (user_id,booking_id,booking_type,rating,review,target_id,target_type) VALUES (?,?,?,?,?,?,?)').run(req.user.id, booking_id, booking_type||'booking', rating, review||'', target_id||null, target_type||'driver');
  res.json({ message: 'ok', id: result.lastInsertRowid });
});

router.get('/my', auth, (req, res) => {
  res.json(db.prepare('SELECT * FROM ratings WHERE user_id=? ORDER BY created_at DESC').all(req.user.id));
});

router.get('/target/:type/:id', (req, res) => {
  const rows = db.prepare('SELECT r.rating,r.review,r.created_at,u.name as reviewer FROM ratings r LEFT JOIN users u ON r.user_id=u.id WHERE r.target_id=? AND r.target_type=? ORDER BY r.created_at DESC').all(req.params.id, req.params.type);
  const avg = rows.length ? (rows.reduce((s,r)=>s+r.rating,0)/rows.length).toFixed(1) : 0;
  res.json({ average: parseFloat(avg), total: rows.length, data: rows });
});

module.exports = router;