const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

module.exports = (pool) => {
  const router = express.Router();

  router.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body;
      const result = await pool.query(
        'SELECT * FROM usuarios WHERE email = $1', [email]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }

      const usuario = result.rows[0];
      const passwordValida = await bcrypt.compare(password, usuario.password);

      if (!passwordValida) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }

      const token = jwt.sign(
        { id: usuario.id, email: usuario.email },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      res.json({ token, usuario: { id: usuario.id, email: usuario.email } });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  return router;
};