const Joi = require('joi');

const base = {
  invoice_id: Joi.number().integer().positive(),
  amount: Joi.number().precision(2),
  method: Joi.string().valid('cash', 'card', 'transfer', 'mobile', 'other'),
  paid_at: Joi.date().iso(),
  status: Joi.string().valid('paid', 'unpaid', 'pending', 'cancelled')
};

const createPayment = Joi.object({
  ...base,
  invoice_id: base.invoice_id.required(),
  amount: base.amount.required(),
  method: base.method.required(),
  paid_at: base.paid_at.default(new Date()),
  status: base.status.default('paid')
});

const updatePayment = Joi.object(base);

module.exports = { createPayment, updatePayment };
