const express = require('express');
const cors = require('cors');
const path = require('path');
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static('/data/data/com.termux/files/home/gerobak-backend/public'));

const authRoutes = require('./src/routes/auth');
const versionRoutes = require('./src/routes/version');
const bookingRoutes = require('./src/routes/bookings');
const rentalRoutes = require('./src/routes/rentals');
const ratingRoutes = require('./src/routes/ratings');
const paymentRoutes = require('./src/routes/payments');

app.use('/api/auth', authRoutes);
app.use('/api/version', versionRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/rentals', rentalRoutes);
app.use('/api/ratings', ratingRoutes);
app.use('/api/payments', paymentRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', app: 'GERObakIN Backend', time: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`GERObakIN backend running on port ${PORT}`);
});
