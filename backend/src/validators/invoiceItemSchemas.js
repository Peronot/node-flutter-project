const Joi = require('joi');

const base = {
  invoice_id: Joi.number().integer().positive(),
  procedure_id: Joi.number().integer().positive(),
  price: Joi.number().precision(2),
  subtotal: Joi.number().precision(2),
  qty: Joi.number().integer().positive()
};

const createInvoiceItem = Joi.object({
  ...base,
  invoice_id: base.invoice_id.required(),
  procedure_id: base.procedure_id.required(),
  price: base.price.required(),
  qty: base.qty.default(1),
  subtotal: base.subtotal
});

const updateInvoiceItem = Joi.object(base);

module.exports = { createInvoiceItem, updateInvoiceItem };
