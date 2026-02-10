const { pool } = require('../config/db');
const { pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'user_permissions';
const COLUMNS = ['user_id', 'permission_id', 'allow'];

const list = async (filters = {}, page, pageSize) => {
  const clauses = [];
  const params = [];
  const userId = filters.user_id ?? filters.userId;
  const permissionId = filters.permission_id ?? filters.permissionId;
  if (userId) {
    clauses.push('user_id = ?');
    params.push(userId);
  }
  if (permissionId) {
    clauses.push('permission_id = ?');
    params.push(permissionId);
  }
  const where = clauses.length ? ' WHERE ' + clauses.join(' AND ') : '';
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`${where} ORDER BY user_id, permission_id LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );
  return rows;
};

const findById = async (id) => {
  const [rows] = await pool.query(`SELECT * FROM \`${TABLE}\` WHERE id = ?`, [id]);
  return rows[0] || null;
};

const create = async (data) => {
  const payload = pickFields(data, COLUMNS);
  const [result] = await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return { id: result.insertId, ...payload };
};

const update = async (id, data) => {
  const payload = pickFields(data, COLUMNS);
  if (!Object.keys(payload).length) return findById(id);
  await pool.query(`UPDATE \`${TABLE}\` SET ? WHERE id = ?`, [payload, id]);
  return findById(id);
};

const remove = async (id) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE id = ?`, [id]);
};

module.exports = { list, findById, create, update, remove };
