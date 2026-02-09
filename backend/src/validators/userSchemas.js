const Joi = require('joi');

const base = {
  full_name: Joi.string().min(2).max(120),
  email: Joi.string().email(),
  password: Joi.string().min(6).max(128),
  role: Joi.string().max(50),
  created_at: Joi.date().iso()
};

const updateUser = Joi.object(base);

module.exports = { updateUser };
