const express = require('express');
const controller = require('../controllers/treatmentProcedureController');

const router = express.Router();

router.get('/', controller.list);
router.get('/:treatmentId/:procedureId', controller.get);
router.post('/', controller.create);
router.put('/:treatmentId/:procedureId', controller.update);
router.delete('/:treatmentId/:procedureId', controller.remove);

module.exports = router;
