const express = require('express');
const controller = require('../controllers/authController');
const validate = require('../middleware/validate');
const { registerSchema, loginSchema } = require('../validators/authSchemas');
const { changePasswordSchema } = require('../validators/authExtendedSchemas');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/register', validate(registerSchema), controller.register);
router.post('/login', validate(loginSchema), controller.login);
router.post('/logout', requireAuth, controller.logout);
router.post('/change-password', requireAuth, validate(changePasswordSchema), controller.changePassword);

module.exports = router;
