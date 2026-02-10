const { pool } = require('../config/db');
const { pickFields, paginationParams } = require('../utils/dbUtils');

const TABLE = 'treatment_procedures';
const COLUMNS = ['treatment_id', 'procedure_id'];

const list = async (filters = {}, page, pageSize) => {
  const clauses = [];
  const params = [];
  const treatmentId = filters.treatment_id ?? filters.treatmentId;
  const procedureId = filters.procedure_id ?? filters.procedureId;
  if (treatmentId) {
    clauses.push('treatment_id = ?');
    params.push(treatmentId);
  }
  if (procedureId) {
    clauses.push('procedure_id = ?');
    params.push(procedureId);
  }
  const where = clauses.length ? ' WHERE ' + clauses.join(' AND ') : '';
  const { limit, offset } = paginationParams(page, pageSize);
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\`${where} ORDER BY treatment_id, procedure_id LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );
  return rows;
};

const find = async (treatmentId, procedureId) => {
  const [rows] = await pool.query(
    `SELECT * FROM \`${TABLE}\` WHERE treatment_id = ? AND procedure_id = ?`,
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
    `UPDATE \`${TABLE}\` SET ? WHERE treatment_id = ? AND procedure_id = ?`,
    [payload, treatmentId, procedureId]
  );
  return find(payload.treatment_id || treatmentId, payload.procedure_id || procedureId);
};

const remove = async (treatmentId, procedureId) => {
  await pool.query(`DELETE FROM \`${TABLE}\` WHERE treatment_id = ? AND procedure_id = ?`, [treatmentId, procedureId]);
};

module.exports = { list, find, create, update, remove };
