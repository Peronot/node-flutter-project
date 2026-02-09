const mysql = require('mysql2/promise');

// Create a connection pool for reuse across requests
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'dental_management',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const pingDb = async () => {
  // Simple query to verify the connection works
  await pool.query('SELECT 1');
};

module.exports = {
  pool,
  pingDb
};
