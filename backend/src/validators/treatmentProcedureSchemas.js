const Joi = require('joi');

const id = Joi.number().integer().positive();

// Accept camelCase or snake_case and normalize to snake_case.
const linkSchema = Joi.object({
  treatmentId: id,
  treatment_id: id,
  procedureId: id,
  procedure_id: id,
})
  .custom((value, helpers) => {
    const treatment_id = value.treatment_id ?? value.treatmentId;
    const procedure_id = value.procedure_id ?? value.procedureId;
    if (!treatment_id || !procedure_id) {
      return helpers.error('any.required');
    }
    return { treatment_id, procedure_id };
  })
  .messages({ 'any.required': 'treatment_id and procedure_id are required' });

const updateSchema = Joi.object({
  treatmentId: id,
  treatment_id: id,
  procedureId: id,
  procedure_id: id,
}).custom((value, helpers) => {
  const treatment_id = value.treatment_id ?? value.treatmentId;
  const procedure_id = value.procedure_id ?? value.procedureId;
  const normalized = {};
  if (treatment_id !== undefined) normalized.treatment_id = treatment_id;
  if (procedure_id !== undefined) normalized.procedure_id = procedure_id;
  if (!Object.keys(normalized).length) {
    return helpers.error('any.required');
  }
  return normalized;
});

module.exports = { linkSchema, updateSchema };
