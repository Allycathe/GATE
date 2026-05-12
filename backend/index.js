const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

app.use(express.json());

// Rutas
app.use('/usuarios', require('./routes/usuarios')(pool));
app.use('/mecheros', require('./routes/mecheros')(pool));
app.use('/reportes', require('./routes/reportes')(pool));
app.use('/supermercados', require('./routes/supermercados')(pool));
app.use('/auth', require('./routes/auth')(pool));

app.listen(port, () => {
  console.log(`Servidor corriendo en puerto ${port}`);
});