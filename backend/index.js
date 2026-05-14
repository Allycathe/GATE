const express = require('express');
const morgan = require('morgan');
const { pool, comprobarConexion } = require('./src/db');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(morgan('dev'));

// Test de conexión utilizando la lógica extraída
app.get('/db-test', async (req, res) => {
  try {
    const time = await comprobarConexion();
    res.json({ status: 'Conectado', time });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.use('/usuarios', require('./src/routes/usuarios')(pool));
app.use('/auth', require('./src/routes/auth')(pool));
app.use('/supermercados', require('./src/routes/super')(pool));
app.use('/reportes', require('./src/routes/reportes')(pool));

app.listen(port, '0.0.0.0', () => {
  console.log(`Servidor corriendo en puerto ${port}`);
});