const Joi = require('joi');

const registerSchema = Joi.object({
  full_name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).max(128).required(),
  role: Joi.alternatives().try(Joi.string(), Joi.number()).default('user'),
  role_id: Joi.alternatives().try(Joi.string(), Joi.number())
});

const loginSchema = Joi.object({
  username: Joi.string().min(2).max(150).required(), // full_name used as username
  password: Joi.string().required()
});

module.exports = { registerSchema, loginSchema };
