const Joi = require('joi');

const base = {
  invoiceId: Joi.number().integer().positive(),
  amount: Joi.number().precision(2),
  method: Joi.string().valid('cash', 'card', 'transfer', 'other'),
  paid_at: Joi.date().iso()
};

const createPayment = Joi.object({
  ...base,
  invoiceId: base.invoiceId.required(),
  amount: base.amount.required(),
  method: base.method.required(),
  paid_at: base.paid_at.default(new Date())
});

const updatePayment = Joi.object(base);

module.exports = { createPayment, updatePayment };
