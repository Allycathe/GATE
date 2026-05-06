const express = require('express');
const { Pool } = require('pg');
const app = express();
const port = 3000;

// Configuración de la conexión a PostgreSQL
// Docker permite usar el nombre del servicio 'db' definido en el compose
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://tu_usuario:tu_password@db:5432/nombre_db'
});

app.use(express.json());

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ mensaje: "Backend funcionando con Node.js y Docker" });
});

// Ruta para probar la conexión con la DB
app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ status: "Conectado a PostgreSQL", time: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error al conectar con la base de datos" });
  }
});

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
