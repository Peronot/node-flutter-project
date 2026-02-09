const { pool } = require('../config/db');
const { pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'treatmentprocedure';
const COLUMNS = ['treatmentId', 'procedureId'];

const list = async (filters = {}, page, pageSize) => {
  const clauses = [];
  const params = [];
  if (filters.treatmentId) {
    clauses.push('treatmentId = ?');
    params.push(filters.treatmentId);
  }
  if (filters.procedureId) {
    clauses.push('procedureId = ?');
    params.push(filters.procedureId);
  }
  const where = clauses.length ? ' WHERE ' + clauses.join(' AND ') : '';
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`${where} ORDER BY treatmentId, procedureId LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );
  return rows;
};

const find = async (treatmentId, procedureId) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` WHERE treatmentId = ? AND procedureId = ?`,
    [treatmentId, procedureId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const payload = pickFields(data, COLUMNS);
  await pool.query(`INSERT INTO \`${TABLE}\` SET ?`, payload);
  return payload;
};

const update = async (treatmentId, procedureId, data) => {
  const payload = pickFields(data, COLUMNS);
  if (!Object.keys(payload).length) return find(treatmentId, procedureId);
  await pool.query(
    `UPDATE \`${TABLE}\` SET ? WHERE treatmentId = ? AND procedureId = ?`,
    [payload, treatmentId, procedureId]
  );
  return find(payload.treatmentId || treatmentId, payload.procedureId || procedureId);
};

const remove = async (treatmentId, procedureId) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE treatmentId = ? AND procedureId = ?`, [treatmentId, procedureId]);
};

module.exports = { list, find, create, update, remove };
