const Joi = require('joi');

const base = {
  full_name: Joi.string().min(2).max(120),
  gender: Joi.string().valid('male', 'female', 'other'),
  date_of_birth: Joi.date(),
  phone: Joi.string().max(30),
  address: Joi.string().max(255)
};

const createPatient = Joi.object({
  ...base,
  full_name: base.full_name.required()
});

const updatePatient = Joi.object(base);

module.exports = { createPatient, updatePatient };
