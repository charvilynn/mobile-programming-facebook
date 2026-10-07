require('dotenv').config();
const app = require('./app');
const db = require('./models');

const PORT = process.env.PORT || 3000;
const sequelize = db.sequelize || db;

// Sinkronkan dan buat semua tabel otomatis ke MySQL
sequelize.sync({ alter: true })
  .then(() => {
    console.log('✅ Semua tabel (termasuk users) berhasil disinkronkan ke MySQL!');
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 PaceBook API running on http://localhost:${PORT}`);
      console.log(`   Environment : ${process.env.NODE_ENV || 'development'}`);
    });
  })
  .catch((err) => {
    console.error('❌ Gagal sinkronisasi database:', err);
  });