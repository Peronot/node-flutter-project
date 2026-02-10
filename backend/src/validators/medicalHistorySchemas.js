const Joi = require('joi');

const base = {
  patient_id: Joi.number().integer().positive(),
  description: Joi.string().allow('', null),
  created_at: Joi.date().iso()
};

const createMedicalHistory = Joi.object({
  ...base,
  patient_id: base.patient_id.required()
});

const updateMedicalHistory = Joi.object(base);

module.exports = { createMedicalHistory, updateMedicalHistory };
