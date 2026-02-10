const model = require('../models/userModel');
const asyncHandler = require('../utils/asyncHandler');
const bcrypt = require('bcryptjs');
const validate = require('../middleware/validate');
const { createUser, updateUser } = require('../validators/userSchemas');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.findById(req.params.id);
  if (!row) return res.status(404).json({ message: 'User not found' });
  res.json(row);
});

exports.create = [
  validate(createUser),
  asyncHandler(async (req, res) => {
    const body = { ...req.validatedBody };
    if (body.password) {
      body.password = await bcrypt.hash(body.password, 10);
    }
    const created = await model.create(body);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updateUser),
  asyncHandler(async (req, res) => {
    const exists = await model.findById(req.params.id);
    if (!exists) return res.status(404).json({ message: 'User not found' });
    const payload = { ...req.validatedBody };
    if (payload.password) {
      payload.password = await bcrypt.hash(payload.password, 10);
    }
    const updated = await model.update(req.params.id, payload);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.id);
  res.status(204).end();
});
