const express = require('express');
const bcrypt = require('bcryptjs');
const isAdmin = require('../middleware/isAdmin');

module.exports = (pool) => {
  const router = express.Router();

  // ─── Helper: obtener el id_supermarket del admin desde el token ──────────────
  // Asume que tu middleware de auth escribe req.usuario = { id, isadmin, id_supermarket, ... }
  function adminSupermarket(req) {
    return req.usuario?.id_supermarket ?? null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET /usuarios/perfil/:id  →  perfil propio (cualquier usuario autenticado)
  // ─────────────────────────────────────────────────────────────────────────────
  router.get('/perfil/:id', async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT id, name, last_name, email, isadmin, id_supermarket
         FROM users WHERE id = $1`,
        [req.params.id]
      );
      if (result.rowCount === 0)
        return res.status(404).json({ error: 'Usuario no encontrado' });

      res.json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // GET /usuarios  →  listar guardias del mismo supermercado del admin
  // ─────────────────────────────────────────────────────────────────────────────
  router.get('/', isAdmin(pool), async (req, res) => {
    const id_supermarket = adminSupermarket(req);
    if (id_supermarket === null)
      return res.status(500).json({ error: 'No se pudo determinar el supermercado del administrador' });

    try {
      const result = await pool.query(
        `SELECT id, name, last_name, email, isadmin, id_supermarket
         FROM users
         WHERE id_supermarket = $1
         ORDER BY id ASC`,
        [id_supermarket]
      );
      res.json({ total: result.rowCount, usuarios: result.rows });
    } catch (err) {
      res.status(500).json({ error: 'Error al obtener usuarios' });
    }
  });
  

  // ─────────────────────────────────────────────────────────────────────────────
  // POST /usuarios  →  crear guardia, el admin envía id_supermarket en el body
  // ─────────────────────────────────────────────────────────────────────────────
  router.post('/', isAdmin(pool), async (req, res) => {
    const { name, last_name, email, password, id_supermarket, isadmin } = req.body;

    if (!name || !last_name || !email || !password || !id_supermarket)
      return res.status(400).json({ error: 'Faltan campos obligatorios: name, last_name, email, password, id_supermarket' });

    if (parseInt(id_supermarket) !== adminSupermarket(req))
      return res.status(403).json({ error: 'No puedes crear usuarios en otro supermercado' });

    try {
      const hashedPassword = await bcrypt.hash(password, 10);

      const result = await pool.query(
        `INSERT INTO users (name, last_name, email, password, isadmin, id_supermarket)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, name, last_name, email, isadmin, id_supermarket`,
        [name, last_name, email, hashedPassword, isadmin ?? false, id_supermarket]
      );

      res.status(201).json({ mensaje: 'Guardia creado', usuario: result.rows[0] });
    } catch (err) {
      if (err.code === '23505')
        return res.status(409).json({ error: 'El email ya está registrado' });
      if (err.code === '23502')
        return res.status(400).json({ error: `El campo '${err.column}' es obligatorio` });
      res.status(500).json({ error: 'Error interno al crear usuario' });
    }
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // PUT /usuarios/:id  →  editar guardia, solo si pertenece al mismo supermercado
  // ─────────────────────────────────────────────────────────────────────────────
  router.put('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    const id_supermarket = adminSupermarket(req);

    // Verificar que el guardia a editar pertenece al supermercado del admin
    const ownership = await pool.query(
      'SELECT id FROM users WHERE id = $1 AND id_supermarket = $2',
      [id, id_supermarket]
    );
    if (ownership.rowCount === 0)
      return res.status(404).json({ error: 'Guardia no encontrado en tu supermercado' });

    // Solo se permiten editar estos campos
    const { name, last_name, email, password } = req.body;

    if (!name || !email)
      return res.status(400).json({ error: 'Faltan campos obligatorios: name, email' });

    try {
      let query, values;

      if (password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        query = `UPDATE users
                 SET name=$1, last_name=$2, email=$3, password=$4
                 WHERE id=$5 AND id_supermarket=$6
                 RETURNING id, name, last_name, email, isadmin, id_supermarket`;
        values = [name, last_name ?? null, email, hashedPassword, id, id_supermarket];
      } else {
        query = `UPDATE users
                 SET name=$1, last_name=$2, email=$3
                 WHERE id=$4 AND id_supermarket=$5
                 RETURNING id, name, last_name, email, isadmin, id_supermarket`;
        values = [name, last_name ?? null, email, id, id_supermarket];
      }

      const result = await pool.query(query, values);
      res.json({ mensaje: 'Guardia actualizado', usuario: result.rows[0] });
    } catch (err) {
      if (err.code === '23505')
        return res.status(409).json({ error: 'El email ya está registrado' });
      if (err.code === '23502')
        return res.status(400).json({ error: `El campo '${err.column}' es obligatorio` });
      res.status(500).json({ error: 'Error interno al actualizar usuario' });
    }
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // DELETE /usuarios/:id  →  eliminar guardia, solo si pertenece al mismo supermercado
  // ─────────────────────────────────────────────────────────────────────────────
  router.delete('/:id', isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    const id_supermarket = adminSupermarket(req);

    // Evitar que el admin se elimine a sí mismo
    if (parseInt(id) === req.usuario?.id)
      return res.status(400).json({ error: 'No puedes eliminarte a ti mismo' });

    try {
      const result = await pool.query(
        'DELETE FROM users WHERE id=$1 AND id_supermarket=$2 RETURNING id, name',
        [id, id_supermarket]
      );

      if (result.rowCount === 0)
        return res.status(404).json({ error: 'Guardia no encontrado en tu supermercado' });

      res.json({ mensaje: `Guardia ${result.rows[0].name} eliminado correctamente` });
    } catch (err) {
      res.status(500).json({ error: 'Error interno al eliminar usuario' });
    }
  });

  router.put('/:id/fcm-token', async (req, res) => {
    const { id } = req.params;
    const { fcm_token } = req.body;

    if (!fcm_token)
      return res.status(400).json({ error: 'fcm_token requerido' });

    try {
      await pool.query(
        'UPDATE users SET fcm_token = $1 WHERE id = $2',
        [fcm_token, id]
      );
      res.json({ ok: true });
    } catch (err) {
      res.status(500).json({ error: 'Error interno al actualizar token' });
    }
  });

  return router;
};