const Joi = require('joi');

const base = {
  name: Joi.string().min(2).max(120)
};

const createPermission = Joi.object({
  ...base,
  name: base.name.required()
});

const updatePermission = Joi.object(base);

module.exports = { createPermission, updatePermission };
