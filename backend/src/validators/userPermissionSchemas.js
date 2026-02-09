const Joi = require('joi');

const base = {
  userId: Joi.number().integer().positive(),
  permissionId: Joi.number().integer().positive(),
  allow: Joi.number().valid(0, 1)
};

const createUserPermission = Joi.object({
  ...base,
  userId: base.userId.required(),
  permissionId: base.permissionId.required(),
  allow: base.allow.default(1)
});

const updateUserPermission = Joi.object(base);

module.exports = { createUserPermission, updateUserPermission };
