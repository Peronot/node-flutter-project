const Joi = require('joi');

const base = {
  role: Joi.string().max(120),
  permissionId: Joi.number().integer().positive()
};

const createRolePermission = Joi.object({
  ...base,
  role: base.role.required(),
  permissionId: base.permissionId.required()
});

const updateRolePermission = Joi.object(base);

module.exports = { createRolePermission, updateRolePermission };
