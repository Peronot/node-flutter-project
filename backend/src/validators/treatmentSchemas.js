const Joi = require('joi');

const base = {
  appointment_id: Joi.number().integer().positive(),
  doctor_id: Joi.number().integer().positive(),
  notes: Joi.string().allow('', null),
  created_at: Joi.date().iso()
};

const createTreatment = Joi.object({
  ...base,
  appointment_id: base.appointment_id.required(),
  doctor_id: base.doctor_id.required()
});

const updateTreatment = Joi.object(base);

module.exports = { createTreatment, updateTreatment };
