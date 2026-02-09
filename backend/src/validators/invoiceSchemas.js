const Joi = require('joi');

const base = {
  patientId: Joi.number().integer().positive(),
  doctorId: Joi.number().integer().positive(),
  total: Joi.number().precision(2),
  status: Joi.string().valid('unpaid', 'paid', 'cancelled'),
  issued_at: Joi.date().iso()
};

const createInvoice = Joi.object({
  ...base,
  patientId: base.patientId.required(),
  doctorId: base.doctorId.required(),
  total: base.total.required(),
  status: base.status.default('unpaid'),
  issued_at: base.issued_at.default(new Date())
});

const updateInvoice = Joi.object(base);

module.exports = { createInvoice, updateInvoice };
