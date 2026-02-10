const Joi = require('joi');

const base = {
  patient_id: Joi.number().integer().positive(),
  allergy_id: Joi.number().integer().positive()
};

const createPatientAllergy = Joi.object({
  ...base,
  patient_id: base.patient_id.required(),
  allergy_id: base.allergy_id.required()
});

const updatePatientAllergy = Joi.object(base);

module.exports = { createPatientAllergy, updatePatientAllergy };
