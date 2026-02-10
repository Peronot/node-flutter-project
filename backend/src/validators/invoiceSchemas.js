const Joi = require('joi');

const base = {
  patient_id: Joi.number().integer().positive(),
  total: Joi.number().precision(2),
  status: Joi.string().valid('unpaid', 'paid', 'cancelled'),
  created_at: Joi.date().iso()
};

const createInvoice = Joi.object({
  ...base,
  patient_id: base.patient_id.required(),
  total: base.total.required(),
  status: base.status.default('unpaid'),
  created_at: base.created_at.default(new Date())
});

const updateInvoice = Joi.object(base);

module.exports = { createInvoice, updateInvoice };
