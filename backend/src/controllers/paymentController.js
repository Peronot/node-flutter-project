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
    const { invoice_id, amount, method, paid_at, status } = req.validatedBody;
    const invoice = await invoiceModel.findById(invoice_id);
    if (!invoice) return res.status(400).json({ message: 'Invalid invoice_id' });

    const finalAmount = amount ?? invoice.total;
    const finalStatus = status ?? 'paid';

    const conn = await model.getConnection();
    try {
      await conn.beginTransaction();
      const created = await model.createWithConnection(conn, {
        invoice_id,
        amount: finalAmount,
        method,
        paid_at,
        status: finalStatus
      });
      await invoiceModel.updateWithConnection(conn, invoice_id, { status: finalStatus });
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
    if (body.invoice_id) {
      const invoice = await invoiceModel.findById(body.invoice_id);
      if (!invoice) return res.status(400).json({ message: 'Invalid invoice_id' });
    }
    const conn = await model.getConnection();
    try {
      await conn.beginTransaction();
      const updated = await model.updateWithConnection(conn, req.params.id, body);
      if (body.status && (updated?.invoice_id ?? body.invoice_id)) {
        await invoiceModel.updateWithConnection(conn, updated.invoice_id ?? body.invoice_id, { status: body.status });
      }
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
