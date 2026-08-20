-- Create a mock Concomitant Medications (CM) Table
CREATE TABLE concomitant_meds (
    cm_id VARCHAR(10),
    subject_id VARCHAR(15),
    cm_term VARCHAR(50),      -- Medication Name
    start_date DATE,
    end_date DATE,
    ongoing VARCHAR(3)       -- 'YES' or 'NO'
);

-- Insert sample CM data with protocol violations
INSERT INTO concomitant_meds VALUES
('CM-001', 'SITE101-001', 'Paracetamol', '2026-08-01', '2026-08-05', 'NO'),
('CM-002', 'SITE101-001', 'Ketoconazole', '2026-08-02', NULL, 'YES'),         -- ERROR: Prohibited Strong CYP3A4 Inhibitor!
('CM-003', 'SITE101-002', 'Ibuprofen',    '2026-08-10', '2026-08-05', 'NO'),   -- ERROR: End date is before Start date!
('CM-004', 'SITE101-003', 'Aspirin',      '2026-08-01', NULL, 'NO');          -- ERROR: Not ongoing, but missing End Date!

-- Query: Audit CM data for prohibited drugs and date logic errors
SELECT 
    cm_id,
    subject_id,
    cm_term,
    start_date,
    end_date,
    ongoing,
    CASE 
        WHEN LOWER(cm_term) IN ('ketoconazole', 'clarithromycin', 'rifampin') 
            THEN 'PROTOCOL VIOLATION: Prohibited Medication Administered'
        WHEN end_date IS NOT NULL AND end_date < start_date 
            THEN 'DATA QUERY: Medication End Date is prior to Start Date'
        WHEN ongoing = 'NO' AND end_date IS NULL 
            THEN 'DATA QUERY: Missing End Date for completed medication'
        ELSE 'Clean CM Record'
    END AS cm_audit_flag
FROM concomitant_meds;