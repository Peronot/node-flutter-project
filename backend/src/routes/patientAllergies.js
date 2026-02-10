const express = require('express');
const controller = require('../controllers/patientAllergyController');

const router = express.Router();

router.get('/', controller.list);
router.get('/:patientId/:allergyId', controller.get);
router.post('/', controller.create);
router.put('/:patientId/:allergyId', controller.update);
router.delete('/:patientId/:allergyId', controller.remove);

module.exports = router;
