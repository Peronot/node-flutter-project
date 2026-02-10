const { pool } = require('../config/db');
const { buildSearch, pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'role_permissions';
const COLUMNS = ['role_id', 'permission_id'];
const SEARCH_FIELDS = ['role_id', 'permission_id'];

const list = async (search, page, pageSize) => {
  const { clause, params } = buildSearch(search, SEARCH_FIELDS);
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`${clause} ORDER BY role_id ASC, permission_id ASC LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );
  return rows;
};

const find = async (roleId, permissionId) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` WHERE role_id = ? AND permission_id = ?`,
    [roleId, permissionId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const payload = pickFields(data, COLUMNS);
  await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return payload;
};

const update = async (roleId, permissionId, data) => {
  const payload = pickFields(data, COLUMNS);
  if (!Object.keys(payload).length) return find(roleId, permissionId);
  await pool.query(
    `UPDATE \`${TABLE}\` SET ? WHERE role_id = ? AND permission_id = ?`,
    [payload, roleId, permissionId]
  );
  return find(payload.role_id || roleId, payload.permission_id || permissionId);
};

const remove = async (roleId, permissionId) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE role_id = ? AND permission_id = ?`, [roleId, permissionId]);
};

module.exports = { list, find, create, update, remove };
