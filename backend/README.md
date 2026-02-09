# Dental Management Backend

Express + MySQL API wired to the `dental_management` schema. CRUD + live search for every table, plus auth, validation, rate limiting, and seed data.

## Quick start
1) Copy `.env.example` to `.env` and fill in MySQL creds.  
2) Install deps: `npm install`  
3) Run dev server: `npm run dev` (default port 4000)  
4) Check connectivity: `curl http://localhost:4000/api/health`

## Project layout
- `src/app.js` – Express bootstrap (JSON, CORS allowlist, rate limit, errors).
- `src/server.js` – Starts the listener.
- `src/config/db.js` – mysql2/promise pool + `pingDb`.
- `src/utils/asyncHandler.js` – wraps async controllers.
- `src/utils/dbUtils.js` – search clause builder + safe field picker.
- `src/middleware/auth.js` – JWT guard; `validate.js` – Joi validator wrapper.
- `src/validators/` – Joi schemas (auth, patients, appointments, invoices, payments, treatment-procedures, users).
- `src/models/` – one file per table (allergy, appointment, doctor, invoice, medicalhistory, patient, payment, permission, procedure, rolepermission, treatment, treatmentprocedure, user, userpermission).
- `src/controllers/` – per-table request handlers with validation/FK checks.
- `src/routes/` – plural endpoints mounted under `/api`.
- `db/seed.sql` – sample data for quick bootstrapping.
- Tests: `test/health.test.js`, `test/auth.test.js` (Jest + Supertest).

## Auth
- Register: `POST /api/auth/register` `{ full_name, email, password }` → returns JWT.
- Login: `POST /api/auth/login` `{ email, password }` → returns JWT.
- All resource routes are protected with `Authorization: Bearer <token>`.

## Example endpoints
- Patients with search: `GET /api/patients?search=ahmed`
- Create appointment: `POST /api/appointments` `{ patientId, doctorId, scheduled_at, status, notes }`
- Update invoice: `PUT /api/invoices/3` `{ status:"paid", total:120 }`
- Link treatment & procedure: `POST /api/treatment-procedures` `{ treatmentId, procedureId }`
- User permissions filter: `GET /api/user-permissions?userId=1`

## Validation and FK safety
- Joi schemas enforce required fields and friendly 400 errors.
- Appointment/invoice verify `patientId` and `doctorId`.
- Payment verifies `invoiceId`.
- Treatment-procedure verifies both sides before linking.

## Security
- Passwords hashed with bcryptjs; JWT uses `JWT_SECRET` / `JWT_EXPIRES_IN`.
- CORS allowlist via `CORS_ORIGINS` (comma separated).
- Rate limiting via `RATE_LIMIT_WINDOW_MS` and `RATE_LIMIT_MAX`.

## Seed data
Run the SQL file against your database (e.g., via phpMyAdmin or `mysql` CLI):
```
mysql -u <user> -p<password> dental_management < db/seed.sql
```

## Tests
```
npm run test
```
Tests mock the DB connection so they run without MySQL.
