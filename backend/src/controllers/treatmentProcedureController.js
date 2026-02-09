const model = require('../models/treatmentProcedureModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { linkSchema, updateSchema } = require('../validators/treatmentProcedureSchemas');
const treatmentModel = require('../models/treatmentModel');
const procedureModel = require('../models/procedureModel');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list({
    treatmentId: req.query.treatmentId,
    procedureId: req.query.procedureId
  }, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.find(req.params.treatmentId, req.params.procedureId);
  if (!row) return res.status(404).json({ message: 'Treatment-procedure link not found' });
  res.json(row);
});

exports.create = [
  validate(linkSchema),
  asyncHandler(async (req, res) => {
    const { treatmentId, procedureId } = req.validatedBody;
    const [treatment, procedure] = await Promise.all([
      treatmentModel.findById(treatmentId),
      procedureModel.findById(procedureId)
    ]);
    if (!treatment) return res.status(400).json({ message: 'Invalid treatmentId' });
    if (!procedure) return res.status(400).json({ message: 'Invalid procedureId' });
    const created = await model.create(req.validatedBody);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updateSchema),
  asyncHandler(async (req, res) => {
    const exists = await model.find(req.params.treatmentId, req.params.procedureId);
    if (!exists) return res.status(404).json({ message: 'Treatment-procedure link not found' });
    const body = req.validatedBody;
    if (body.treatmentId) {
      const treatment = await treatmentModel.findById(body.treatmentId);
      if (!treatment) return res.status(400).json({ message: 'Invalid treatmentId' });
    }
    if (body.procedureId) {
      const procedure = await procedureModel.findById(body.procedureId);
      if (!procedure) return res.status(400).json({ message: 'Invalid procedureId' });
    }
    const updated = await model.update(req.params.treatmentId, req.params.procedureId, body);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.treatmentId, req.params.procedureId);
  res.status(204).end();
});
