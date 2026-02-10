const { pool } = require('../config/db');
const { buildSearch, pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'appointments';
const COLUMNS = ['patient_id', 'doctor_id', 'appointment_date', 'appointment_time', 'status'];
const SEARCH_FIELDS = ['status'];

const list = async (search, page, pageSize) => {
  const { clause, params } = buildSearch(search, SEARCH_FIELDS);
  const { limit, offset } = paginationParams(page, pageSize);
  const sql = `SELECT * FROM \`${TABLE}\`${clause} ORDER BY appointment_date DESC, appointment_time DESC LIMIT ? OFFSET ?`;
  const [rows] = await pool.query(sql, [...params, limit, offset]);
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
