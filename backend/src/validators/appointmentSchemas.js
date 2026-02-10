const Joi = require('joi');

const base = {
  patient_id: Joi.number().integer().positive(),
  doctor_id: Joi.number().integer().positive(),
  appointment_date: Joi.date().iso(),
  appointment_time: Joi.string(),
  status: Joi.string().valid('pending', 'booked', 'confirmed', 'cancelled', 'completed'),
  notes: Joi.string().allow('', null)
};

const createAppointment = Joi.object({
  ...base,
  patient_id: base.patient_id.required(),
  doctor_id: base.doctor_id.required(),
  appointment_date: base.appointment_date.required(),
  appointment_time: base.appointment_time.required(),
  status: base.status.default('pending')
});

const updateAppointment = Joi.object(base);

module.exports = { createAppointment, updateAppointment };
