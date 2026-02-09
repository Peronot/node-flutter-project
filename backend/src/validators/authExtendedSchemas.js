const Joi = require('joi');

const changePasswordSchema = Joi.object({
  current_password: Joi.string().required(),
  new_password: Joi.string().min(6).max(128).required()
});

module.exports = { changePasswordSchema };
