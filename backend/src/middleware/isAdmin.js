// src/middleware/isAdmin.js
module.exports = (pool) => async (req, res, next) => {
  try {
    const result = await pool.query(
      'SELECT isadmin, id_supermarket FROM users WHERE id = $1',
      [req.usuario.id]
    );

    if (result.rowCount === 0)
      return res.status(404).json({ error: 'Usuario no encontrado' });

    if (!result.rows[0].isadmin)
      return res.status(403).json({ error: 'Acceso denegado: se requiere rol administrador' });

    // Adjunta id_supermarket para usarlo en las rutas
    req.usuario.id_supermarket = result.rows[0].id_supermarket;

    next();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al verificar permisos' });
  }
};