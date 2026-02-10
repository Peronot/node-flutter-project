const { pool } = require('../config/db');
const { buildSearch, pickFields } = require('../utils/dbUtils');

const TABLE = 'users';
const COLUMNS = ['full_name', 'email', 'password', 'role_id', 'doctor_id', 'created_at'];
const SEARCH_FIELDS = ['full_name', 'email', 'role_id'];

const list = async (search) => {
  const { clause, params } = buildSearch(search, SEARCH_FIELDS);
  const [rows] = await pool.query(`SELECT id, full_name, email, role_id, doctor_id, created_at FROM \`${TABLE}\`${clause} ORDER BY id DESC`, params);
  return rows;
};

const findById = async (id) => {
  const [rows] = await pool.query(
    `SELECT id, full_name, email, role_id, doctor_id, created_at FROM \`${TABLE}\` WHERE id = ?`,
    [id]
  );
  return rows[0] || null;
};

const findWithPasswordById = async (id) => {
  const [rows] = await pool.query(`SELECT * FROM \`${TABLE}\` WHERE id = ?`, [id]);
  return rows[0] || null;
};

const findByEmail = async (email) => {
  const [rows] = await pool.query(
    `SELECT id, full_name, email, role_id, doctor_id, created_at FROM \`${TABLE}\` WHERE email = ?`,
    [email]
  );
  return rows[0] || null;
};

const findWithPasswordByEmail = async (email) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` WHERE email = ?`,
    [email]
  );
  return rows[0] || null;
};

const findWithPasswordByIdentifier = async (identifier) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`
     WHERE LOWER(TRIM(email)) = LOWER(TRIM(?))
        OR LOWER(TRIM(full_name)) = LOWER(TRIM(?))`,
    [identifier, identifier]
  );
  return rows[0] || null;
};

const findWithPasswordByUsername = async (username) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`
     WHERE LOWER(TRIM(full_name)) = LOWER(TRIM(?))`,
    [username]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const payload = pickFields(data, COLUMNS);
  const [result] = await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return findById(result.insertId);
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

module.exports = {
  list,
  findById,
  findWithPasswordById,
  findByEmail,
  findWithPasswordByEmail,
  findWithPasswordByIdentifier,
  findWithPasswordByUsername,
  create,
  update,
  remove
};
