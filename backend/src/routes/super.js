const express = require('express');
const isAdmin = require('../middleware/isAdmin');

module.exports = (pool) => {
  const router = express.Router();

  // Cualquier usuario - Ver supermercados
  router.get('/', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM supermarket ORDER BY id ASC');
      res.status(200).json({ total: result.rowCount, supermercados: result.rows });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  router.get('/:id', async (req, res) => {
    try {
      const { id } = req.params;
      if (isNaN(id)) return res.status(400).json({ error: 'El ID debe ser un número válido' });
      const result = await pool.query('SELECT * FROM supermarket WHERE id = $1', [id]);
      if (result.rowCount === 0) return res.status(404).json({ error: 'Supermercado no encontrado' });
      res.status(200).json({ supermercado: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  // ADMIN - Crear, editar, eliminar
  router.post('/', isAdmin(pool), async (req, res) => {
    const { name, latitude, longitude } = req.body;
    if (!name || latitude === undefined || longitude === undefined) {
    return res.status(400).json({ error: 'Faltan campos obligatorios (name, latitude, longitude)' });
    }
    try {
      const result = await pool.query(
        'INSERT INTO supermarket (name, latitude, longitude) VALUES ($1, $2, $3) RETURNING *',
[name, latitude, longitude]
      );
      res.status(201).json({ mensaje: 'Supermercado creado', supermercado: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  router.put('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    const { name, latitude, longitude } = req.body;
    try {
      const result = await pool.query(
        'UPDATE supermarket SET name=$1, latitude=$2, longitude=$3 WHERE id=$4 RETURNING *',
[name, latitude, longitude, id]
      );
      if (result.rowCount === 0) return res.status(404).json({ error: 'Supermercado no encontrado' });
      res.json({ mensaje: 'Supermercado actualizado', supermercado: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  router.delete('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('DELETE FROM supermarket WHERE id=$1 RETURNING *', [id]);
      if (result.rowCount === 0) return res.status(404).json({ error: 'Supermercado no encontrado' });
      res.json({ mensaje: 'Supermercado eliminado correctamente' });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  return router;
};