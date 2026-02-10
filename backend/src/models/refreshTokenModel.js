const { pool } = require('../config/db');
const { paginationParams } = require('../utils/dbUtils');

const TABLE = 'refresh_tokens';
const COLUMNS = ['user_id', 'token', 'expires_at'];

const list = async (page, pageSize) => {
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` ORDER BY id DESC LIMIT ? OFFSET ?`,
    [limit, offset]
  );
  return rows;
};

const create = async (data) => {
  const payload = {};
  COLUMNS.forEach((c) => {
    if (data[c] !== undefined) payload[c] = data[c];
  });
  const [result] = await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return { id: result.insertId, ...payload };
};

const remove = async (id) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE id = ?`, [id]);
};

module.exports = { list, create, remove };
