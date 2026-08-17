-- Create a mock Clinical Trial Visit Tracking Table
CREATE TABLE patient_visits (
    subject_id VARCHAR(10),
    visit_number INT,
    visit_name VARCHAR(30),
    visit_date DATE
);

-- Insert sample visit data with common EDC data errors
INSERT INTO patient_visits VALUES
('SUBJ-201', 1, 'Screening', '2026-07-01'),
('SUBJ-201', 2, 'Baseline', '2026-07-08'),
('SUBJ-201', 3, 'Week 4 Follow-up', '2026-08-05'),

('SUBJ-202', 1, 'Screening', '2026-07-02'),
('SUBJ-202', 3, 'Week 4 Follow-up', '2026-07-15'), -- ERROR: Skipped Visit 2 (Baseline)!

('SUBJ-203', 1, 'Screening', '2026-07-05'),
('SUBJ-203', 2, 'Baseline', '2026-07-01');       -- ERROR: Baseline date is BEFORE Screening!

-- Query: Use LAG() window function to check visit sequence & dates
SELECT 
    subject_id,
    visit_number,
    visit_name,
    visit_date,
    LAG(visit_number, 1) OVER (PARTITION BY subject_id ORDER BY visit_number) AS prev_visit_num,
    LAG(visit_date, 1) OVER (PARTITION BY subject_id ORDER BY visit_number) AS prev_visit_date,
    CASE 
        WHEN LAG(visit_number, 1) OVER (PARTITION BY subject_id ORDER BY visit_number) IS NULL THEN 'First Visit'
        WHEN visit_number - LAG(visit_number, 1) OVER (PARTITION BY subject_id ORDER BY visit_number) > 1 THEN 'QUERY: Skipped Prior Visit'
        WHEN visit_date < LAG(visit_date, 1) OVER (PARTITION BY subject_id ORDER BY visit_number) THEN 'QUERY: Date Anomaly (Current visit before previous)'
        ELSE 'Valid Sequence'
    END AS sequence_audit_flag
FROM patient_visits;