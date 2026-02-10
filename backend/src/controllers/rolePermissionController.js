const model = require('../models/rolePermissionModel');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');
const { createRolePermission, updateRolePermission } = require('../validators/rolePermissionSchemas');

exports.list = asyncHandler(async (req, res) => {
  const rows = await model.list(req.query.search, req.query.page, req.query.pageSize);
  res.json(rows);
});

exports.get = asyncHandler(async (req, res) => {
  const row = await model.find(req.params.roleId, req.params.permissionId);
  if (!row) return res.status(404).json({ message: 'Role permission not found' });
  res.json(row);
});

exports.create = [
  validate(createRolePermission),
  asyncHandler(async (req, res) => {
    const created = await model.create(req.validatedBody);
    res.status(201).json(created);
  })
];

exports.update = [
  validate(updateRolePermission),
  asyncHandler(async (req, res) => {
    const exists = await model.find(req.params.roleId, req.params.permissionId);
    if (!exists) return res.status(404).json({ message: 'Role permission not found' });
    const updated = await model.update(req.params.roleId, req.params.permissionId, req.validatedBody);
    res.json(updated);
  })
];

exports.remove = asyncHandler(async (req, res) => {
  await model.remove(req.params.roleId, req.params.permissionId);
  res.status(204).end();
});
