-- Quiz 1: Pengetahuan Umum
INSERT INTO quiz (title, description, duration, created_by, is_active) VALUES
('Pengetahuan Umum', 'Quiz tentang pengetahuan umum sehari-hari', 10, 1, TRUE);

SET @quiz1_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(@quiz1_id, 'Ibu kota Indonesia adalah?', 'Jakarta', 'Bandung', 'Surabaya', 'Medan', 'A'),
(@quiz1_id, 'Planet terbesar di tata surya adalah?', 'Saturnus', 'Jupiter', 'Uranus', 'Neptunus', 'B'),
(@quiz1_id, 'Berapa jumlah provinsi di Indonesia?', '34', '35', '37', '38', 'D'),
(@quiz1_id, 'Gunung tertinggi di Indonesia adalah?', 'Gunung Semeru', 'Gunung Kerinci', 'Puncak Jaya', 'Gunung Rinjani', 'C'),
(@quiz1_id, 'Bahasa resmi Indonesia adalah?', 'Bahasa Jawa', 'Bahasa Indonesia', 'Bahasa Melayu', 'Bahasa Sunda', 'B');

-- Quiz 2: Matematika Dasar
INSERT INTO quiz (title, description, duration, created_by, is_active) VALUES
('Matematika Dasar', 'Quiz matematika dasar untuk mengasah kemampuan berhitung', 15, 1, TRUE);

SET @quiz2_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(@quiz2_id, 'Berapa hasil dari 15 + 27?', '42', '41', '43', '40', 'A'),
(@quiz2_id, 'Berapa hasil dari 100 - 37?', '63', '67', '73', '53', 'A'),
(@quiz2_id, 'Berapa hasil dari 8 x 7?', '54', '56', '58', '52', 'B'),
(@quiz2_id, 'Berapa hasil dari 81 : 9?', '8', '10', '9', '7', 'C'),
(@quiz2_id, 'Berapa nilai dari 5² + 3²?', '34', '32', '36', '30', 'A');

-- Quiz 3: Ilmu Pengetahuan Alam
INSERT INTO quiz (title, description, duration, created_by, is_active) VALUES
('Ilmu Pengetahuan Alam', 'Quiz tentang sains dan alam sekitar', 12, 1, TRUE);

SET @quiz3_id = LAST_INSERT_ID();

INSERT INTO questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES
(@quiz3_id, 'H2O adalah rumus kimia dari?', 'Hidrogen', 'Oksigen', 'Air', 'Udara', 'C'),
(@quiz3_id, 'Proses fotosintesis terjadi di?', 'Akar', 'Batang', 'Daun', 'Bunga', 'C'),
(@quiz3_id, 'Planet yang dikenal sebagai Planet Merah adalah?', 'Venus', 'Mars', 'Jupiter', 'Merkurius', 'B'),
(@quiz3_id, 'Sistem tata surya kita memiliki berapa planet?', '7', '8', '9', '10', 'B'),
(@quiz3_id, 'Satuan SI untuk suhu adalah?', 'Celsius', 'Fahrenheit', 'Kelvin', 'Reamur', 'C');
