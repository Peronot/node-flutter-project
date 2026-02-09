const Joi = require('joi');

const base = {
  full_name: Joi.string().min(2).max(120),
  specialty: Joi.string().max(120),
  phone: Joi.string().max(30)
};

const createDoctor = Joi.object({
  ...base,
  full_name: base.full_name.required()
});

const updateDoctor = Joi.object(base);

module.exports = { createDoctor, updateDoctor };
