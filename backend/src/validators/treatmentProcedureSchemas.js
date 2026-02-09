const Joi = require('joi');

const linkSchema = Joi.object({
  treatmentId: Joi.number().integer().positive().required(),
  procedureId: Joi.number().integer().positive().required()
});

const updateSchema = Joi.object({
  treatmentId: Joi.number().integer().positive(),
  procedureId: Joi.number().integer().positive()
});

module.exports = { linkSchema, updateSchema };
