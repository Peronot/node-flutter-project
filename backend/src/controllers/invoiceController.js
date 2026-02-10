const model = require('../models/invoiceModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createInvoice, updateInvoice } = require('../validators/invoiceSchemas');
const patientModel = require('../models/patientModel');
const doctorModel = require('../models/doctorModel');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.findById(req.params.id);
  if (!row) return res.status(404).json({ message: 'Invoice not found' });
  res.json(row);
});

exports.create = [
  validate(createInvoice),
  asyncHandler(async (req, res) => {
    const { patient_id } = req.validatedBody;
    const patient = await patientModel.findById(patient_id);
    if (!patient) return res.status(400).json({ message: 'Invalid patient_id' });
    const conn = await model.getConnection();
    try {
      await conn.beginTransaction();
      const created = await model.createWithConnection(conn, req.validatedBody);
      await conn.commit();
      res.status(201).json(created);
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  })
];

exports.update = [
  validate(updateInvoice),
  asyncHandler(async (req, res) => {
    const exists = await model.findById(req.params.id);
    if (!exists) return res.status(404).json({ message: 'Invoice not found' });
    const body = req.validatedBody;
    if (body.patient_id) {
      const patient = await patientModel.findById(body.patient_id);
      if (!patient) return res.status(400).json({ message: 'Invalid patient_id' });
    }
    const conn = await model.getConnection();
    try {
      await conn.beginTransaction();
      const updated = await model.updateWithConnection(conn, req.params.id, body);
      await conn.commit();
      res.json(updated);
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.id);
  res.status(204).end();
});
