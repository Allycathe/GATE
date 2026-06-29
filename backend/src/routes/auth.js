const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { sendPasswordResetEmail } = require('../services/emailService');

module.exports = (pool) => {
  const router = express.Router();

  // LOGIN
  router.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body;
      const result = await pool.query(
        'SELECT * FROM users WHERE email = $1', [email]
      );
      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }
      const usuario = result.rows[0];
      const passwordValida = await bcrypt.compare(password, usuario.password);
      if (!passwordValida) {
        return res.status(401).json({ error: 'Credenciales incorrectas' });
      }
      await pool.query(
      'UPDATE users SET fcm_token = NULL WHERE id != $1',
      [usuario.id]
        );
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

  // FORGOT PASSWORD
  router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'Email requerido' });

    try {
      const userResult = await pool.query(
        'SELECT id, email FROM users WHERE email = $1', [email]
      );

      if (userResult.rowCount === 0) {
        return res.json({ mensaje: 'Si el correo existe, recibirás un enlace en breve' });
      }

      const user = userResult.rows[0];
      const token = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + 60 * 60 * 1000).toISOString();

      await pool.query(
        'UPDATE password_reset_tokens SET used = TRUE WHERE id_user = $1',
        [user.id]
      );

      await pool.query(
        `INSERT INTO password_reset_tokens (id_user, token, expires_at)
         VALUES ($1, $2, $3)`,
        [user.id, token, expiresAt]
      );

      await sendPasswordResetEmail(user.email, token);

      res.json({ mensaje: 'Si el correo existe, recibirás un enlace en breve' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al procesar la solicitud' });
    }
  });

  // RESET PASSWORD
  router.post('/reset-password', async (req, res) => {
    const { token, nueva_password } = req.body;
    if (!token || !nueva_password) {
      return res.status(400).json({ error: 'Token y nueva contraseña requeridos' });
    }

    try {
      const tokenResult = await pool.query(
        `SELECT t.id, t.id_user FROM password_reset_tokens t
         WHERE t.token = $1
           AND t.used = FALSE
           AND t.expires_at > NOW()`,
        [token]
      );

      if (tokenResult.rowCount === 0) {
        return res.status(400).json({ error: 'Token inválido o expirado' });
      }

      const { id: tokenId, id_user } = tokenResult.rows[0];
      const hash = await bcrypt.hash(nueva_password, 10);

      await pool.query('UPDATE users SET password = $1 WHERE id = $2', [hash, id_user]);
      await pool.query('UPDATE password_reset_tokens SET used = TRUE WHERE id = $1', [tokenId]);

      res.json({ mensaje: 'Contraseña actualizada correctamente' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al restablecer la contraseña' });
    }
  });

  // RECUPERAR - Paso 1: enviar código de 6 dígitos
router.post('/recuperar', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email requerido' });

  try {
    const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (userResult.rowCount === 0)
      return res.json({ mensaje: 'Si el correo existe, recibirás un código en breve' });

    const id_user = userResult.rows[0].id;
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expires_at = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    await pool.query(
      'UPDATE password_reset_tokens SET used = TRUE WHERE id_user = $1',
      [id_user]
    );
    await pool.query(
      'INSERT INTO password_reset_tokens (id_user, token, expires_at) VALUES ($1, $2, $3)',
      [id_user, codigo, expires_at]
    );

    await sendPasswordResetEmail(email, codigo);
    res.json({ mensaje: 'Si el correo existe, recibirás un código en breve' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al procesar la solicitud' });
  }
});

// RECUPERAR - Paso 2: verificar código y cambiar contraseña
router.post('/recuperar/resetear', async (req, res) => {
  const { email, codigo, nueva_password } = req.body;
  if (!email || !codigo || !nueva_password)
    return res.status(400).json({ error: 'Faltan campos obligatorios' });

  try {
    const result = await pool.query(
      `SELECT t.id, t.id_user FROM password_reset_tokens t
       JOIN users u ON u.id = t.id_user
       WHERE u.email = $1
         AND t.token = $2
         AND t.used = FALSE
         AND t.expires_at > NOW()`,
      [email, codigo]
    );

    if (result.rowCount === 0)
      return res.status(400).json({ error: 'Código inválido o expirado' });

    const { id: tokenId, id_user } = result.rows[0];
    const hash = await bcrypt.hash(nueva_password, 10);

    await pool.query('UPDATE users SET password = $1 WHERE id = $2', [hash, id_user]);
    await pool.query('UPDATE password_reset_tokens SET used = TRUE WHERE id = $1', [tokenId]);

    res.json({ mensaje: 'Contraseña actualizada correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al restablecer la contraseña' });
  }
});

  return router;
};