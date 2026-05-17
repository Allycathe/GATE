const express = require('express');
module.exports = (pool) => {
  const router = express.Router();

  // Endpoint para crear un supermercado
  router.post('/', async (req, res) => {
    try {
      const { name, location_x, location_y } = req.body;

      if (!name || location_x === undefined || location_y === undefined) {
        return res.status(400).json({ error: 'Faltan campos obligatorios (name, location_x, location_y)' });
      }

      const query = `
        INSERT INTO supermarket (name, location_x, location_y)
        VALUES ($1, $2, $3)
        RETURNING *;
      `;
      const values = [name, location_x, location_y];
      const result = await pool.query(query, values);

      res.status(201).json({
        mensaje: 'Supermercado creado exitosamente',
        supermercado: result.rows[0]
      });
    } catch (err) {
      console.error('Error al crear supermercado:', err);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  // Endpoint para obtener todos los supermercados
  router.get('/', async (req, res) => {
    try {
      const query = `SELECT * FROM supermarket ORDER BY id ASC;`;
      const result = await pool.query(query);

      res.status(200).json({
        total: result.rowCount,
        supermercados: result.rows
      });
    } catch (err) {
      console.error('Error al obtener supermercados:', err);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  // Endpoint para obtener un supermercado por ID
  router.get('/:id', async (req, res) => {
    try {
      const { id } = req.params;

      if (isNaN(id)) {
        return res.status(400).json({ error: 'El ID debe ser un número válido' });
      }

      const query = `SELECT * FROM supermarket WHERE id = $1;`;
      const result = await pool.query(query, [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Supermercado no encontrado' });
      }

      res.status(200).json({
        supermercado: result.rows[0]
      });
    } catch (err) {
      console.error('Error al obtener supermercado:', err);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });

  return router;
};