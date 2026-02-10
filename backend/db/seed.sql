-- Basic seed data aligned to current API schema (snake_case, plural table names)

INSERT INTO doctors (full_name, specialization, phone) VALUES
('Dr. Amina Yusuf', 'Orthodontics', '555-1001'),
('Dr. Khalid Noor', 'Endodontics', '555-1002');

INSERT INTO patients (full_name, gender, date_of_birth, phone, address, created_at) VALUES
('Ahmed Ali', 'male', '1990-04-12', '555-2001', 'Main St 1', NOW()),
('Maryam Abdullahi', 'female', '1995-09-20', '555-2002', 'Main St 2', NOW());

INSERT INTO allergies (name, notes) VALUES
('Penicillin', 'Causes rash'),
('Latex', 'Mild reaction');

INSERT INTO procedures (name, price) VALUES
('Cleaning', 50.00),
('Filling', 120.00);

INSERT INTO invoices (patient_id, total, status, created_at) VALUES
(1, 170.00, 'unpaid', NOW()),
(2, 120.00, 'unpaid', NOW());

INSERT INTO invoice_items (invoice_id, procedure_id, price, subtotal, qty) VALUES
(1, 1, 50.00, 50.00, 1),
(1, 2, 120.00, 120.00, 1),
(2, 2, 120.00, 120.00, 1);

INSERT INTO payments (invoice_id, amount, method, paid_at, status) VALUES
(1, 50.00, 'cash', NOW(), 'paid');

INSERT INTO users (full_name, email, password, role_id, doctor_id, created_at) VALUES
('Admin User', 'admin@example.com', '$2a$10$UfaV0kSRh6ujwvc4BUnzre5NnvnvEIDVnWswM2Xvs6z1QRt6g3u9.', 1, NULL, NOW());
