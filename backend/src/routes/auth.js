const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db/database');

const SECRET = process.env.JWT_SECRET || 'gerobak-secret-key';

router.post('/register', (req, res) => {
  const { name, phone, password } = req.body;
  if (!name || !phone || !password)
    return res.status(400).json({ message: 'Semua field wajib diisi' });

  const hashed = bcrypt.hashSync(password, 10);
  try {
    const stmt = db.prepare('INSERT INTO users (name, phone, password) VALUES (?, ?, ?)');
    const result = stmt.run(name, phone, hashed);
    res.json({ message: 'Registrasi berhasil', userId: result.lastInsertRowid });
  } catch (e) {
    res.status(400).json({ message: 'Nomor HP sudah terdaftar' });
  }
});

router.post('/login', (req, res) => {
  const { phone, password } = req.body;
  const user = db.prepare('SELECT * FROM users WHERE phone = ?').get(phone);
  if (!user || !bcrypt.compareSync(password, user.password))
    return res.status(401).json({ message: 'Phone atau password salah' });

  const token = jwt.sign(
    { id: user.id, role: user.role, name: user.name },
    SECRET,
    { expiresIn: '30d' }
  );
  res.json({ token, user: { id: user.id, name: user.name, role: user.role } });
});

module.exports = router;
