const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const header = req.headers['authorization'];

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token no proporcionado o formato incorrecto' });
  }

  const token = header.split(' ')[1];

  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET || 'secret_key_provisional');
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido o expirado' });
  }
};