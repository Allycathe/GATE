const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const header = header.startsWith('Bearer ') ? header.split(' ')[1] : header;
  if (!header) return res.status(401).json({ error: 'Formato de token incorrecto' });

  const token = header.split(' ')[1]; // Bearer <token>
  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido' });
  }
};
