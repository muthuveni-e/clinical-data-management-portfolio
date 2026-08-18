-- Create a mock Adverse Events (AE) Table
CREATE TABLE adverse_events (
    ae_id VARCHAR(10),
    subject_id VARCHAR(10),
    ae_term VARCHAR(50),
    severity VARCHAR(15),
    serious_ae VARCHAR(3), -- 'YES' or 'NO'
    action_taken VARCHAR(50)
);

-- Insert sample AE data with clinical inconsistencies
INSERT INTO adverse_events VALUES
('AE-001', 'SUBJ-101', 'Headache', 'Mild', 'NO', 'None'),
('AE-002', 'SUBJ-102', 'Nausea', 'Moderate', 'NO', 'Dose Reduced'),
('AE-003', 'SUBJ-103', 'Anaphylaxis', 'Mild', 'YES', 'Hospitalization'), -- ERROR: Marked Mild but caused Hospitalization!
('AE-004', 'SUBJ-104', 'Dizziness', 'Severe', 'NO', 'Drug Withdrawn');  -- DISCREPANCY: Marked Severe but recorded as Non-Serious

-- Query: Audit AE safety data for logical contradictions
SELECT 
    ae_id,
    subject_id,
    ae_term,
    severity,
    serious_ae,
    action_taken,
    CASE 
        WHEN severity = 'Mild' AND (serious_ae = 'YES' OR action_taken = 'Hospitalization') 
            THEN 'SAFETY QUERY: Mild severity conflicts with SAE/Hospitalization'
        WHEN severity = 'Severe' AND serious_ae = 'NO' 
            THEN 'DATA QUERY: Confirm if Severe AE meets SAE criteria'
        ELSE 'Clean AE Record'
    END AS safety_audit_flag
FROM adverse_events;