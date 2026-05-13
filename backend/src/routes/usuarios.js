const express = require('express');
const auth = require('../middleware/auth');

module.exports = (pool) => {
  const router = express.Router();

  router.get('/', auth, async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM usuarios');
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ... resto de rutas CRUD igual pero con auth como middleware
  return router;
};