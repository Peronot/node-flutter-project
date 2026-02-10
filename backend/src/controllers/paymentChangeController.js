const model = require('../models/paymentChangeModel');
const asyncHandler = require('../utils/asyncHandler');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.create = asyncHandler(async (req, res) => {
  const created = await model.create(req.body);
  res.status(201).json(created);
});
