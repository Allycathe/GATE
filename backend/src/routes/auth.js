const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

module.exports = (pool) => {
  const router = express.Router();

  router.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body;

      // Buscar usuario por email
      const result = await pool.query(
        'SELECT * FROM users WHERE email = $1', [email]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }

      const usuario = result.rows[0];

      // Verificar contraseña
      const passwordValida = await bcrypt.compare(password, usuario.password);

      if (!passwordValida) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }

      // Generar Token JWT
      const token = jwt.sign(
        { id: usuario.id, email: usuario.email },
        process.env.JWT_SECRET || 'secret_key_provisional',
        { expiresIn: '8h' }
      );

      res.json({ 
        token, 
        usuario: { id: usuario.id, email: usuario.email } 
      });

    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error en el servidor' });
    }
  });

  return router;
};