const model = require('../models/medicalHistoryModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createMedicalHistory, updateMedicalHistory } = require('../validators/medicalHistorySchemas');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.findById(req.params.id);
  if (!row) return res.status(404).json({ message: 'Medical history entry not found' });
  res.json(row);
});

exports.create = [
  validate(createMedicalHistory),
  asyncHandler(async (req, res) => {
    const created = await model.create(req.validatedBody);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updateMedicalHistory),
  asyncHandler(async (req, res) => {
    const exists = await model.findById(req.params.id);
    if (!exists) return res.status(404).json({ message: 'Medical history entry not found' });
    const updated = await model.update(req.params.id, req.validatedBody);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.id);
  res.status(204).end();
});
