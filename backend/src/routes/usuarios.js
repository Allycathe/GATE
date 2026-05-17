const express = require('express');
const bcrypt = require('bcryptjs');
const isAdmin = require('../middleware/isAdmin');

module.exports = (pool) => {
  const router = express.Router();

  // Perfil propio (cualquier usuario)
  router.get('/perfil/:id', async (req, res) => {
    try {
      const result = await pool.query(
        'SELECT id, name, last_name, email, isadmin, id_supermarket FROM users WHERE id = $1',
        [req.params.id]
      );
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }
      res.json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN - Listar todos los usuarios
  router.get('/', isAdmin(pool), async (req, res) => {
    try {
      const result = await pool.query(
        'SELECT id, name, last_name, email, isadmin, id_supermarket FROM users ORDER BY id ASC'
      );
      res.json({ total: result.rowCount, usuarios: result.rows });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN - Crear usuario
  router.post('/', isAdmin(pool), async (req, res) => {
    const { name, last_name, email, password, isadmin, id_supermarket } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Faltan campos obligatorios (name, email, password)' });
    }

    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      const result = await pool.query(
        `INSERT INTO users (name, last_name, email, password, isadmin, id_supermarket)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, name, last_name, email, isadmin, id_supermarket`,
        [name, last_name, email, hashedPassword, isadmin ?? false, id_supermarket ?? null]
      );
      res.status(201).json({ mensaje: 'Usuario creado', usuario: result.rows[0] });
    } catch (err) {
      if (err.code === '23505') { // email duplicado
        return res.status(409).json({ error: 'El email ya está registrado' });
      }
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN - Editar usuario
  router.put('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    const { name, last_name, email, password, isadmin, id_supermarket } = req.body;

    try {
      let query, values;

      if (password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        query = `UPDATE users SET name=$1, last_name=$2, email=$3, password=$4, isadmin=$5, id_supermarket=$6
                 WHERE id=$7 RETURNING id, name, last_name, email, isadmin, id_supermarket`;
        values = [name, last_name, email, hashedPassword, isadmin, id_supermarket, id];
      } else {
        query = `UPDATE users SET name=$1, last_name=$2, email=$3, isadmin=$4, id_supermarket=$5
                 WHERE id=$6 RETURNING id, name, last_name, email, isadmin, id_supermarket`;
        values = [name, last_name, email, isadmin, id_supermarket, id];
      }

      const result = await pool.query(query, values);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }
      res.json({ mensaje: 'Usuario actualizado', usuario: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ADMIN - Eliminar usuario
  router.delete('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('DELETE FROM users WHERE id=$1 RETURNING id', [id]);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }
      res.json({ mensaje: 'Usuario eliminado correctamente' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  return router;
};