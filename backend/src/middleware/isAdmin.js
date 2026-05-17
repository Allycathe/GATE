const isAdmin = async (req, res, next) => {
  try {
    // req.usuario ya viene del middleware auth
    const userId = req.usuario.id;

    // Consulta la BD para verificar isadmin en tiempo real
    const result = await pool.query(
      'SELECT isadmin FROM users WHERE id = $1', [userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (!result.rows[0].isadmin) {
      return res.status(403).json({ error: 'Acceso denegado: se requiere rol administrador' });
    }

    next();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al verificar permisos' });
  }
};

// src/middleware/isAdmin.js
module.exports = (pool) => async (req, res, next) => {
  try {
    const result = await pool.query(
      'SELECT isadmin FROM users WHERE id = $1', [req.usuario.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (!result.rows[0].isadmin) {  // ← isadmin en minúscula
      return res.status(403).json({ error: 'Acceso denegado: se requiere rol administrador' });
    }

    next();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al verificar permisos' });
  }
};