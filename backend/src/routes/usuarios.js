const express = require('express');
const auth = require('../middleware/auth');

module.exports = (pool) => {
  const router = express.Router();

  router.get('/perfil/:id', auth, async (req, res) => {
  try {
    

    const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.params.id])
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

  
  return router;
};

