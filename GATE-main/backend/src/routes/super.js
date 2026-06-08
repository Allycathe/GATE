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
    const { name, location_x, location_y } = req.body;
    if (!name || location_x === undefined || location_y === undefined) {
      return res.status(400).json({ error: 'Faltan campos obligatorios (name, location_x, location_y)' });
    }
    try {
      const result = await pool.query(
        'INSERT INTO supermarket (name, location_x, location_y) VALUES ($1, $2, $3) RETURNING *',
        [name, location_x, location_y]
      );
      res.status(201).json({ mensaje: 'Supermercado creado', supermercado: result.rows[0] });
    } catch (err) {
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  router.put('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    const { name, location_x, location_y } = req.body;
    try {
      const result = await pool.query(
        'UPDATE supermarket SET name=$1, location_x=$2, location_y=$3 WHERE id=$4 RETURNING *',
        [name, location_x, location_y, id]
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