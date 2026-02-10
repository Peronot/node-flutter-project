const { pool } = require('../config/db');
const { paginationParams } = require('../utils/dbUtils');

const TABLE = 'payment_changes';
const COLUMNS = ['payment_id', 'changed_by', 'changes', 'created_at'];

const list = async (page, pageSize) => {
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` ORDER BY created_at DESC LIMIT ? OFFSET ?`,
    [limit, offset]
  );
  return rows;
};

const create = async (data) => {
  const payload = {};
  COLUMNS.forEach((c) => {
    if (data[c] !== undefined) payload[c] = data[c];
  });
  await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return payload;
};

module.exports = { list, create };
