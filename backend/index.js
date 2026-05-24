process.env.TZ = 'America/Santiago';
const express = require('express');
const morgan = require('morgan');
const { pool, comprobarConexion } = require('./src/db');
const { init: initFaceService } = require('./src/services/faceService');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));
app.use(morgan('dev'));

// Precarga modelos de reconocimiento facial al arrancar (evita latencia en primera petición)
initFaceService().catch(err => console.error('[FaceService] Error al cargar modelos:', err.message));

const auth = require('./src/middleware/auth');

// Rutas públicas (sin auth)

// Test de conexión utilizando la lógica extraída
app.get('/db-test', async (req, res) => { 
  try {
    const time = await comprobarConexion();
    res.json({ status: 'Conectado', time });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
 });
app.use('/auth', require('./src/routes/auth')(pool)); // login no requiere token

// Auth global para todo lo demás
app.use(auth);

// Rutas protegidas
app.use('/usuarios', require('./src/routes/usuarios')(pool));
app.use('/supermercados', require('./src/routes/super')(pool));
app.use('/reportes', require('./src/routes/reportes')(pool));




app.listen(port, '0.0.0.0', () => {
  console.log(`Servidor corriendo en puerto ${port}`);
});