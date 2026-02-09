const model = require('../models/paymentModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createPayment, updatePayment } = require('../validators/paymentSchemas');
const invoiceModel = require('../models/invoiceModel');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.findById(req.params.id);
  if (!row) return res.status(404).json({ message: 'Payment not found' });
  res.json(row);
});

exports.create = [
  validate(createPayment),
  asyncHandler(async (req, res) => {
    const { invoiceId, amount, method, paid_at } = req.validatedBody;
    const invoice = await invoiceModel.findById(invoiceId);
    if (!invoice) return res.status(400).json({ message: 'Invalid invoiceId' });

    const conn = await model.getConnection();
    try {
      await conn.beginTransaction();
      const created = await model.createWithConnection(conn, { invoiceId, amount, method, paid_at });
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
  validate(updatePayment),
  asyncHandler(async (req, res) => {
    const exists = await model.findById(req.params.id);
    if (!exists) return res.status(404).json({ message: 'Payment not found' });
    const body = req.validatedBody;
    if (body.invoiceId) {
      const invoice = await invoiceModel.findById(body.invoiceId);
      if (!invoice) return res.status(400).json({ message: 'Invalid invoiceId' });
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
