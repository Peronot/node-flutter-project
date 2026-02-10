const express = require('express');
const { pingDb } = require('../config/db');
const { requireAuth } = require('../middleware/auth');
const { requireRoles } = require('../middleware/authorize');

const router = express.Router();

// Health check
router.get('/health', async (req, res, next) => {
  try {
    await pingDb();
    res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    next(error);
  }
});

// Auth (public)
router.use('/auth', require('./auth'));

// Resource routes
router.use('/allergies', requireAuth, require('./allergies'));
router.use('/appointments', requireAuth, require('./appointments'));
router.use('/invoice-items', requireAuth, require('./invoiceItems'));
router.use('/patient-allergies', requireAuth, require('./patientAllergies'));
router.use('/roles', requireAuth, require('./roles'));
router.use('/audit-logs', requireAuth, require('./auditLogs'));
router.use('/payment-changes', requireAuth, require('./paymentChanges'));
router.use('/refresh-tokens', requireAuth, require('./refreshTokens'));
router.use('/doctors', requireAuth, require('./doctors'));
router.use('/invoices', requireAuth, require('./invoices'));
router.use('/medical-histories', requireAuth, require('./medicalHistories'));
router.use('/patients', requireAuth, require('./patients'));
router.use('/payments', requireAuth, require('./payments'));
router.use('/permissions', requireAuth, require('./permissions'));
router.use('/procedures', requireAuth, require('./procedures'));
router.use('/role-permissions', requireAuth, require('./rolePermissions'));
router.use('/treatments', requireAuth, require('./treatments'));
router.use('/treatment-procedures', requireAuth, require('./treatmentProcedures'));
router.use('/users', requireAuth, require('./users'));
router.use('/user-permissions', requireAuth, require('./userPermissions'));

module.exports = router;
