-- Testing for worker dashboard
INSERT INTO users (full_name, contact_number, password, role, profile_picture, avg_rating)
VALUES
('Ali Khan', '03001234567', 'pass123', 'worker', NULL, 4.5),
('Sara Ahmed', '03007654321', 'worker123', 'worker', NULL, 4.7),
('Usman Tariq', '03111222333', 'worker456', 'worker', NULL, 4.2),
('Ayesha Malik', '03219876543', 'client123', 'client', NULL, 0),
('Bilal Hussain', '03331234567', 'client456', 'client', NULL, 0);


INSERT INTO worker (user_id, profession, skills, experience_years)
VALUES
(1, 'Plumber', 'Leak fixing, pipe installation', 5),
(2, 'Electrician', 'Wiring, lighting installation', 4),
(3, 'Cleaner', 'House cleaning, deep cleaning', 3);

INSERT INTO service_request (requester_id, service_type, description, date, time, location, status)
VALUES
(4, 'Plumbing', 'Kitchen pipe leakage', '2026-04-10', '10:00', 'Karachi', 'open'),
(5, 'Electrical', 'Install ceiling lights', '2026-04-11', '14:00', 'Karachi', 'open'),
(4, 'Cleaning', 'Full house cleaning', '2026-04-12', '09:00', 'Karachi', 'open');

INSERT INTO bid (request_id, worker_id, bid_amount, bid_date, bid_time, status)
VALUES
(1, 1, 2000, '2026-04-08', '12:00', 'pending'),
(2, 2, 1500, '2026-04-08', '13:00', 'accepted'),
(3, 3, 3000, '2026-04-08', '14:00', 'pending');

INSERT INTO job (request_id, worker_id, status)
VALUES
(2, 2, 'ongoing'),
(1, 2, 'Completed');

INSERT INTO message (job_id, sender_id, content)
VALUES
(1, 2, 'I will arrive at 2 PM'),
(1, 5, 'Okay, I will be available');

INSERT INTO rating_review (reviewer_id, reviewee_id, rating, comment)
VALUES
(5, 2, 5, 'Great work!'),
(4, 1, 4, 'Good service');

INSERT INTO notification (user_id, content)
VALUES
(1, 'New job request available'),
(2, 'Your bid was accepted'),
(4, 'Worker assigned to your request');

