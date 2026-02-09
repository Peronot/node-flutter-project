const Joi = require('joi');

const base = {
  name: Joi.string().min(2).max(120),
  description: Joi.string().allow('', null)
};

const createTreatment = Joi.object({
  ...base,
  name: base.name.required()
});

const updateTreatment = Joi.object(base);

module.exports = { createTreatment, updateTreatment };
