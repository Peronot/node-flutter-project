const Joi = require('joi');

const base = {
  role_id: Joi.number().integer().positive(),
  permission_id: Joi.number().integer().positive()
};

const createRolePermission = Joi.object({
  ...base,
  role_id: base.role_id.required(),
  permission_id: base.permission_id.required()
});

const updateRolePermission = Joi.object(base);

module.exports = { createRolePermission, updateRolePermission };
