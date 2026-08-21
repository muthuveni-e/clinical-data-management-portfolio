-- Create a mock Lab Results (LB) Table
CREATE TABLE lab_results (
    lab_id VARCHAR(10),
    subject_id VARCHAR(15),
    lab_test VARCHAR(20),       -- e.g., ALT, AST, CREATININE
    result_val NUMERIC,
    unit VARCHAR(10),
    low_limit NUMERIC,
    high_limit NUMERIC
);

-- Insert sample Lab data with safety violations
INSERT INTO lab_results VALUES
('LB-001', 'SITE101-001', 'ALT', 25.0, 'U/L', 7.0, 56.0),
('LB-002', 'SITE101-001', 'ALT', 180.0, 'U/L', 7.0, 56.0),     -- ERROR: > 3x Upper Limit of Normal (Toxicity Risk!)
('LB-003', 'SITE101-002', 'CREATININE', NULL, 'mg/dL', 0.6, 1.2),-- ERROR: Missing Lab Result!
('LB-004', 'SITE101-003', 'HEMOGLOBIN', 5.2, 'g/dL', 12.0, 16.0);-- ERROR: Severe Anemia (< 7.0 g/dL Danger Level)

-- Query: Audit lab results for missing values, out-of-bounds, and critical toxicities
SELECT 
    lab_id,
    subject_id,
    lab_test,
    result_val,
    unit,
    low_limit,
    high_limit,
    CASE 
        WHEN result_val IS NULL 
            THEN 'DATA QUERY: Missing Lab Result'
        WHEN lab_test = 'ALT' AND result_val > (high_limit * 3) 
            THEN 'CRITICAL SAFETY ALERT: ALT > 3x ULN (Potential Liver Injury)'
        WHEN result_val < low_limit 
            THEN 'FLAG: Below Normal Limit'
        WHEN result_val > high_limit 
            THEN 'FLAG: Above Normal Limit'
        ELSE 'Normal Lab Result'
    END AS lab_audit_flag
FROM lab_results;