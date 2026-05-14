const express = require('express');

module.exports = (pool) => {
  const router = express.Router();

  // Endpoint para crear un supermercado
  router.post('/', async (req, res) => {
    try {
      const { name, location_x, location_y } = req.body;

      // Validación básica
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

  return router;
};