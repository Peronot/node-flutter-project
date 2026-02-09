const Joi = require('joi');

const base = {
  name: Joi.string().min(1).max(120),
  notes: Joi.string().allow('', null)
};

const createAllergy = Joi.object({
  ...base,
  name: base.name.required()
});

const updateAllergy = Joi.object(base);

module.exports = { createAllergy, updateAllergy };
