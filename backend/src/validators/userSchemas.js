const Joi = require('joi');

const base = {
  full_name: Joi.string().min(2).max(120),
  email: Joi.string().email(),
  password: Joi.string().min(6).max(128),
  role_id: Joi.number().integer().positive(),
  doctor_id: Joi.number().integer().positive(),
  created_at: Joi.date().iso()
};

const createUser = Joi.object({
  ...base,
  full_name: base.full_name.required(),
  email: base.email.required(),
  password: base.password.required(),
  role_id: base.role_id.required()
});

const updateUser = Joi.object(base);

module.exports = { createUser, updateUser };
