-- Create a mock Clinical Trial Subjects & Vitals Table
CREATE TABLE clinical_vitals (
    subject_id VARCHAR(10),
    visit_name VARCHAR(20),
    systolic_bp INT,
    diastolic_bp INT,
    heart_rate INT,
    recorded_at DATETIME
);

-- Insert sample clinical trial data (including a protocol deviation)
INSERT INTO clinical_vitals VALUES
('SUBJ-101', 'Baseline', 120, 80, 72, '2026-08-01 09:00:00'),
('SUBJ-102', 'Baseline', 185, 115, 95, '2026-08-01 09:30:00'), -- Hypertensive Crisis (Out of Range!)
('SUBJ-103', 'Baseline', 118, 78, 68, '2026-08-01 10:00:00'),
('SUBJ-104', 'Baseline', NULL, 82, 70, '2026-08-01 10:15:00');  -- Missing Systolic BP (Data Quality Issue!)

-- Query: Flag subjects with severe blood pressure deviations (Systolic > 140 OR Diastolic > 90)
SELECT 
    subject_id,
    visit_name,
    systolic_bp,
    diastolic_bp,
    CASE 
        WHEN systolic_bp IS NULL OR diastolic_bp IS NULL THEN 'ACTION REQUIRED: Missing Data'
        WHEN systolic_bp > 140 OR diastolic_bp > 90 THEN 'PROTOCOL DEVIATION: Severe Hypertension'
        ELSE 'Normal'
    END AS clinical_flag
FROM clinical_vitals;