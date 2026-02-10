const { pool } = require('../config/db');
const { pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'patient_allergies';
const COLUMNS = ['patient_id', 'allergy_id'];

const list = async (filters = {}, page, pageSize) => {
  const clauses = [];
  const params = [];
  if (filters.patient_id) {
    clauses.push('patient_id = ?');
    params.push(filters.patient_id);
  }
  if (filters.allergy_id) {
    clauses.push('allergy_id = ?');
    params.push(filters.allergy_id);
  }
  const where = clauses.length ? ' WHERE ' + clauses.join(' AND ') : '';
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`${where} ORDER BY patient_id, allergy_id LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );
  return rows;
};

const find = async (patientId, allergyId) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` WHERE patient_id = ? AND allergy_id = ?`,
    [patientId, allergyId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const payload = pickFields(data, COLUMNS);
  await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return payload;
};

const update = async (patientId, allergyId, data) => {
  const payload = pickFields(data, COLUMNS);
  if (!Object.keys(payload).length) return find(patientId, allergyId);
  await pool.query(
    `UPDATE \`${TABLE}\` SET ? WHERE patient_id = ? AND allergy_id = ?`,
    [payload, patientId, allergyId]
  );
  return find(payload.patient_id || patientId, payload.allergy_id || allergyId);
};

const remove = async (patientId, allergyId) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE patient_id = ? AND allergy_id = ?`, [patientId, allergyId]);
};

module.exports = { list, find, create, update, remove };
