require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const router = require('./routes');

const app = express();

// CORS with origin allowlist
const allowedOrigins = (process.env.CORS_ORIGINS || '').split(',').map(o => o.trim()).filter(Boolean);
app.use(cors({
  origin: allowedOrigins.length ? allowedOrigins : '*'
}));

// Body parsing (raise limit for photo/data URIs)
const jsonLimit = process.env.JSON_LIMIT || '50mb';
app.use(express.json({ limit: jsonLimit }));

// Basic rate limiting
const limiter = rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 15 * 60 * 1000),
  max: Number(process.env.RATE_LIMIT_MAX || 200)
});
app.use(limiter);

// Routes
app.use('/api', router);

// Not found handler
app.use((req, res) => {
  res.status(404).json({ message: 'Not found' });
});

// Central error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  res.status(status).json({ message });
});

module.exports = app;
