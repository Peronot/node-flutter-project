-- Basic seed data for dental_management

INSERT INTO doctor (full_name, specialty, phone) VALUES
('Dr. Amina Yusuf', 'Orthodontics', '555-1001'),
('Dr. Khalid Noor', 'Endodontics', '555-1002');

INSERT INTO patient (full_name, gender, date_of_birth, phone, address) VALUES
('Ahmed Ali', 'male', '1990-04-12', '555-2001', 'Main St 1'),
('Maryam Abdullahi', 'female', '1995-09-20', '555-2002', 'Main St 2');

INSERT INTO allergy (name, notes) VALUES
('Penicillin', 'Causes rash'),
('Latex', 'Mild reaction');

INSERT INTO medicalhistory (patientId, allergyId, details) VALUES
(1, 1, 'Avoid penicillin-based meds'),
(2, 2, 'Use latex-free gloves');

INSERT INTO procedure (name, price) VALUES
('Cleaning', 50.00),
('Filling', 120.00);

INSERT INTO treatment (name, description) VALUES
('Initial Checkup', 'Basic exam and cleaning'),
('Cavity Care', 'Filling procedure');

INSERT INTO treatmentprocedure (treatmentId, procedureId) VALUES
(1, 1),
(2, 2);

INSERT INTO invoice (patientId, doctorId, total, status, issued_at) VALUES
(1, 1, 170.00, 'unpaid', NOW()),
(2, 2, 120.00, 'unpaid', NOW());

INSERT INTO payment (invoiceId, amount, method, paid_at) VALUES
(1, 50.00, 'cash', NOW());

INSERT INTO user (full_name, email, password, role, created_at) VALUES
('Admin User', 'admin@example.com', '$2a$10$UfaV0kSRh6ujwvc4BUnzre5NnvnvEIDVnWswM2Xvs6z1QRt6g3u9.', 'admin', NOW());
