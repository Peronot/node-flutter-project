const model = require('../models/appointmentModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createAppointment, updateAppointment } = require('../validators/appointmentSchemas');
const patientModel = require('../models/patientModel');
const doctorModel = require('../models/doctorModel');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.findById(req.params.id);
  if (!row) return res.status(404).json({ message: 'Appointment not found' });
  res.json(row);
});

exports.create = [
  validate(createAppointment),
  asyncHandler(async (req, res) => {
    const { patient_id, doctor_id } = req.validatedBody;
    const [patient, doctor] = await Promise.all([
      patientModel.findById(patient_id),
      doctorModel.findById(doctor_id)
    ]);
    if (!patient) return res.status(400).json({ message: 'Invalid patient_id' });
    if (!doctor) return res.status(400).json({ message: 'Invalid doctor_id' });
    const created = await model.create(req.validatedBody);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updateAppointment),
  asyncHandler(async (req, res) => {
    const exists = await model.findById(req.params.id);
    if (!exists) return res.status(404).json({ message: 'Appointment not found' });
    const body = req.validatedBody;
    if (body.patient_id) {
      const patient = await patientModel.findById(body.patient_id);
      if (!patient) return res.status(400).json({ message: 'Invalid patient_id' });
    }
    if (body.doctor_id) {
      const doctor = await doctorModel.findById(body.doctor_id);
      if (!doctor) return res.status(400).json({ message: 'Invalid doctor_id' });
    }
    const updated = await model.update(req.params.id, body);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.id);
  res.status(204).end();
});
