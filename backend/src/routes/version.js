const express = require('express');
const router = express.Router();
const db = require('../db/database');
const auth = require('../middleware/auth');

// cek versi terbaru - dipanggil app setiap buka
router.get('/check', (req, res) => {
  const version = db.prepare('SELECT * FROM app_version WHERE id = 1').get();
  res.json(version);
});

// update versi - admin only
router.put('/update', auth, (req, res) => {
  const { version, apk_url, changelog } = req.body;
  if (req.user.role !== 'admin')
    return res.status(403).json({ message: 'Admin only' });

  db.prepare(`
    UPDATE app_version 
    SET version = ?, apk_url = ?, changelog = ?, updated_at = CURRENT_TIMESTAMP
    WHERE id = 1
  `).run(version, apk_url, changelog);

  res.json({ message: 'Versi berhasil diupdate' });
});

module.exports = router;
