const Joi = require('joi');

const base = {
  name: Joi.string().min(2).max(120),
  price: Joi.number().precision(2)
};

const createProcedure = Joi.object({
  ...base,
  name: base.name.required(),
  price: base.price.required()
});

const updateProcedure = Joi.object(base);

module.exports = { createProcedure, updateProcedure };
