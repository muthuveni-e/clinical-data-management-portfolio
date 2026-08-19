-- Create a mock Demographics (DM) Table
CREATE TABLE demographics (
    subject_id VARCHAR(15),
    site_id VARCHAR(10),
    age INT,
    sex VARCHAR(10),
    race VARCHAR(30),
    informed_consent_date DATE
);

-- Insert sample demographics data with integrity issues
INSERT INTO demographics VALUES
('SITE101-001', 'SITE101', 45, 'Female', 'Asian', '2026-08-01'),
('SITE101-002', 'SITE101', 17, 'Male', 'White', '2026-08-02'),      -- ERROR: Age under 18 (Protocol Inclusion Failure!)
('SITE101-001', 'SITE101', 45, 'Female', 'Asian', '2026-08-01'),   -- ERROR: Duplicate Subject ID record!
('INVALID_ID',  'SITE102', 52, 'Male', 'Black', '2026-08-03');     -- ERROR: Subject ID doesn't match 'SITE-XXX' format!

-- Query: Detect duplicates, formatting errors, and age eligibility violations
WITH duplicate_checker AS (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY subject_id) AS id_count
    FROM demographics
)
SELECT 
    subject_id,
    site_id,
    age,
    sex,
    race,
    informed_consent_date,
    CASE 
        WHEN id_count > 1 
            THEN 'QUERY: Duplicate Subject Entry Detected'
        WHEN subject_id NOT LIKE 'SITE%' OR LENGTH(subject_id) < 10 
            THEN 'QUERY: Invalid Subject ID Formatting'
        WHEN age < 18 OR age > 75 
            THEN 'QUERY: Age Outside Protocol Inclusion Criteria (18-75)'
        ELSE 'Clean Demographics Record'
    END AS dm_audit_flag
FROM duplicate_checker;