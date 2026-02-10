const express = require('express');
const controller = require('../controllers/auditLogController');

const router = express.Router();

router.get('/', controller.list);
router.post('/', controller.create);

module.exports = router;
