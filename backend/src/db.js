// src/db.js
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

const comprobarConexion = async () => {
  const result = await pool.query('SELECT NOW()');
  return result.rows[0];
};

module.exports = { pool, comprobarConexion };