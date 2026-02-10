const model = require('../models/patientAllergyModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createPatientAllergy, updatePatientAllergy } = require('../validators/patientAllergySchemas');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(
    { patient_id: req.query.patient_id, allergy_id: req.query.allergy_id },
    req.query.page,
    req.query.pageSize
  );
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.find(req.params.patientId, req.params.allergyId);
  if (!row) return res.status(404).json({ message: 'Patient allergy not found' });
  res.json(row);
});

exports.create = [
  validate(createPatientAllergy),
  asyncHandler(async (req, res) => {
    const created = await model.create(req.validatedBody);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updatePatientAllergy),
  asyncHandler(async (req, res) => {
    const exists = await model.find(req.params.patientId, req.params.allergyId);
    if (!exists) return res.status(404).json({ message: 'Patient allergy not found' });
    const updated = await model.update(req.params.patientId, req.params.allergyId, req.validatedBody);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.patientId, req.params.allergyId);
  res.status(204).end();
});
