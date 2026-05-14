const express = require('express');
const auth = require('../middleware/auth');

module.exports = (pool) => {
  const router = express.Router();

  // 1. LISTAR TODOS LOS REPORTES (GET)
  router.get('/', auth, async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM report ORDER BY id DESC');
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al obtener reportes' });
    }
  });

  // 2. OBTENER UN REPORTE POR ID (GET)
  router.get('/:id', auth, async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('SELECT * FROM report WHERE id = $1', [id]);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al obtener el reporte' });
    }
  });

  // 3. CREAR UN REPORTE (POST)
  router.post('/', auth, async (req, res) => {
    const { id_thief, description, id_supermarket, image } = req.body;
    if (!id_thief || !id_supermarket) {
      return res.status(400).json({ error: 'Faltan campos obligatorios (id_thief, id_supermarket)' });
    }
    try {
      const query = `
        INSERT INTO report (id_thief, description, id_supermarket, image) 
        VALUES ($1, $2, $3, $4) 
        RETURNING *`;
      const result = await pool.query(query, [id_thief, description, id_supermarket, image]);
      res.status(201).json({ mensaje: 'Reporte creado con éxito', reporte: result.rows[0] });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error interno al crear reporte' });
    }
  });

  // 4. MODIFICAR UN REPORTE (PUT)
  router.put('/:id', auth, async (req, res) => {
    const { id } = req.params;
    const { id_thief, description, id_supermarket, image } = req.body;
    try {
      const query = `
        UPDATE report 
        SET id_thief = $1, description = $2, id_supermarket = $3, image = $4 
        WHERE id = $5 
        RETURNING *`;
      const result = await pool.query(query, [id_thief, description, id_supermarket, image, id]);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'El reporte no existe' });
      }
      res.json({ mensaje: 'Reporte actualizado', reporte: result.rows[0] });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al actualizar el reporte' });
    }
  });

  // 5. ELIMINAR UN REPORTE (DELETE)
  router.delete('/:id', auth, async (req, res) => {
    const { id } = req.params;
    if (!req.usuario.isAdmin) {
      return res.status(403).json({ error: 'No tienes permisos para eliminar reportes' });
    }
    try {
      const result = await pool.query('DELETE FROM report WHERE id = $1 RETURNING *', [id]);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      res.json({ mensaje: 'Reporte eliminado correctamente' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al eliminar el reporte' });
    }
  });

  return router;
};