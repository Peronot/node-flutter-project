const Joi = require('joi');

const id = Joi.number().integer().positive();

const base = {
  userId: id,
  user_id: id,
  permissionId: id,
  permission_id: id,
  allow: Joi.number().valid(0, 1)
};

const normalize = (value, helpers, requireBoth) => {
  const user_id = value.user_id ?? value.userId;
  const permission_id = value.permission_id ?? value.permissionId;
  const normalized = {};
  if (user_id !== undefined) normalized.user_id = user_id;
  if (permission_id !== undefined) normalized.permission_id = permission_id;
  if (requireBoth && (!normalized.user_id || !normalized.permission_id)) {
    return helpers.error('any.required');
  }
  if (!requireBoth && Object.keys(normalized).length === 0 && value.allow === undefined) {
    return helpers.error('any.required');
  }
  if (value.allow !== undefined) normalized.allow = value.allow;
  return normalized;
};

const createUserPermission = Joi.object(base).custom((v, h) => normalize(v, h, true))
  .messages({ 'any.required': 'user_id and permission_id are required' });

const updateUserPermission = Joi.object(base).custom((v, h) => normalize(v, h, false));

module.exports = { createUserPermission, updateUserPermission };
