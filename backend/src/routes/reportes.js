const express = require('express');
const router = express.Router();
const { pool } = require('../db');  
const auth = require('../middlewares/auth'); 

// 1. AÑADIR UN REPORTE (POST)
router.post('/', auth, async (req, res) => {
    const { id_thief, description, id_supermarket, image } = req.body;

    // Validación básica
    if (!id_thief || !id_supermarket) {
        return res.status(400).json({ error: 'Faltan campos obligatorios (id_thief, id_supermarket)' });
    }

    try {
        const query = `
            INSERT INTO report (id_thief, description, id_supermarket, image) 
            VALUES ($1, $2, $3, $4) 
            RETURNING *`;
        
        const values = [id_thief, description, id_supermarket, image];
        const result = await pool.query(query, values);

        res.status(201).json({
            mensaje: 'Reporte creado con éxito',
            reporte: result.rows[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno del servidor al crear reporte' });
    }
});

// 2. MODIFICAR UN REPORTE (PUT)
router.put('/:id', auth, async (req, res) => {
    const { id } = req.params;
    const { id_thief, description, id_supermarket, image } = req.body;

    try {
        const query = `
            UPDATE report 
            SET id_thief = $1, description = $2, id_supermarket = $3, image = $4 
            WHERE id = $5 
            RETURNING *`;
        
        const values = [id_thief, description, id_supermarket, image, id];
        const result = await pool.query(query, values);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'El reporte no existe' });
        }

        res.json({
            mensaje: 'Reporte actualizado',
            reporte: result.rows[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar el reporte' });
    }
});

// 3. ELIMINAR UN REPORTE (DELETE)
router.delete('/:id', auth, async (req, res) => {
    const { id } = req.params;

    // Opcional: Solo permitir a administradores borrar
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

module.exports = router;