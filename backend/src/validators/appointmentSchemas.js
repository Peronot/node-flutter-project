const Joi = require('joi');

const base = {
  patientId: Joi.number().integer().positive(),
  doctorId: Joi.number().integer().positive(),
  scheduled_at: Joi.date().iso(),
  status: Joi.string().valid('pending', 'confirmed', 'cancelled', 'completed'),
  notes: Joi.string().allow('', null)
};

const createAppointment = Joi.object({
  ...base,
  patientId: base.patientId.required(),
  doctorId: base.doctorId.required(),
  scheduled_at: base.scheduled_at.required(),
  status: base.status.default('pending')
});

const updateAppointment = Joi.object(base);

module.exports = { createAppointment, updateAppointment };
