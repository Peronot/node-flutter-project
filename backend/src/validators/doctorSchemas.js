const Joi = require('joi');

const base = {
  full_name: Joi.string().min(2).max(120),
  specialization: Joi.string().max(120),
  phone: Joi.string().max(30),
  photo: Joi.string()
    .uri({ scheme: [/https?/, /data/] })
    .message('photo must be a valid http(s) or data URI')
    .optional()
};

const createDoctor = Joi.object({
  ...base,
  full_name: base.full_name.required()
});

const updateDoctor = Joi.object(base);

module.exports = { createDoctor, updateDoctor };
