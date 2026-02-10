const express = require('express');
const controller = require('../controllers/rolePermissionController');

const router = express.Router();

router.get('/', controller.list);
router.get('/:roleId/:permissionId', controller.get);
router.post('/', controller.create);
router.put('/:roleId/:permissionId', controller.update);
router.delete('/:roleId/:permissionId', controller.remove);

module.exports = router;
