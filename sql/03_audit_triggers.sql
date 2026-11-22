-- CSCE 4355 - Team 1
-- University Student Records Security System
-- Phase 3: Database Auditing and Triggers

-- ============================================
-- 1. CREATE AUDIT SCHEMA AND TABLES
-- ============================================

CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.student_changes (
    audit_id BIGSERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    operation VARCHAR(10) NOT NULL
        CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

CREATE TABLE IF NOT EXISTS audit.grade_changes (
    audit_id BIGSERIAL PRIMARY KEY,
    grade_id INTEGER NOT NULL,
    operation VARCHAR(10) NOT NULL
        CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by TEXT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

-- Verify audit tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'audit'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- ============================================
-- 2. CREATE STUDENT AUDIT FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION audit.log_student_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit
AS $$
DECLARE
    actor_name TEXT;
BEGIN
    actor_name := COALESCE(
        NULLIF(current_setting('role', true), 'none'),
        session_user
    );

    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.student_changes
            (student_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (NEW.student_id, TG_OP, actor_name,
             NULL, to_jsonb(NEW));

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.student_changes
            (student_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (NEW.student_id, TG_OP, actor_name,
             to_jsonb(OLD), to_jsonb(NEW));

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.student_changes
            (student_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (OLD.student_id, TG_OP, actor_name,
             to_jsonb(OLD), NULL);

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


-- ============================================
-- 3. CREATE GRADE AUDIT FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION audit.log_grade_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit
AS $$
DECLARE
    actor_name TEXT;
BEGIN
    actor_name := COALESCE(
        NULLIF(current_setting('role', true), 'none'),
        session_user
    );

    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.grade_changes
            (grade_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (NEW.grade_id, TG_OP, actor_name,
             NULL, to_jsonb(NEW));

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.grade_changes
            (grade_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (NEW.grade_id, TG_OP, actor_name,
             to_jsonb(OLD), to_jsonb(NEW));

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.grade_changes
            (grade_id, operation, changed_by,
             old_data, new_data)
        VALUES
            (OLD.grade_id, TG_OP, actor_name,
             to_jsonb(OLD), NULL);

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


-- ============================================
-- 4. CREATE AUDIT TRIGGERS
-- ============================================

DROP TRIGGER IF EXISTS trg_student_audit
ON academics.students;

CREATE TRIGGER trg_student_audit
AFTER INSERT OR UPDATE OR DELETE
ON academics.students
FOR EACH ROW
EXECUTE FUNCTION audit.log_student_changes();


DROP TRIGGER IF EXISTS trg_grade_audit
ON academics.grades;

CREATE TRIGGER trg_grade_audit
AFTER INSERT OR UPDATE OR DELETE
ON academics.grades
FOR EACH ROW
EXECUTE FUNCTION audit.log_grade_changes();


-- ============================================
-- 5. VERIFY FUNCTIONS AND TRIGGERS
-- ============================================

-- Verify audit functions
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'audit'
ORDER BY routine_name;

-- Verify triggers (expect 2 rows)
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    tgenabled AS enabled
FROM pg_trigger
WHERE NOT tgisinternal
  AND tgname IN (
      'trg_student_audit',
      'trg_grade_audit'
  )
ORDER BY trigger_name;


-- ============================================
-- 6. TEST STUDENT UPDATE AUDIT
-- ============================================

BEGIN;

UPDATE academics.students
SET major = 'Cybersecurity'
WHERE student_id = 1;

SELECT
    audit_id,
    student_id,
    operation,
    changed_by,
    changed_at,
    old_data->>'major' AS old_major,
    new_data->>'major' AS new_major
FROM audit.student_changes
ORDER BY audit_id DESC
LIMIT 5;

ROLLBACK;


-- ============================================
-- 7. TEST GRADE UPDATE AUDIT
-- ============================================

BEGIN;

UPDATE academics.grades
SET grade = 92,
    letter_grade = 'A',
    last_updated = CURRENT_TIMESTAMP
WHERE grade_id = 1;

SELECT
    audit_id,
    grade_id,
    operation,
    changed_by,
    changed_at,
    old_data->>'grade' AS old_grade,
    new_data->>'grade' AS new_grade
FROM audit.grade_changes
ORDER BY audit_id DESC
LIMIT 5;

ROLLBACK;


-- ============================================
-- 8. TEST STUDENT INSERT AND DELETE AUDIT
-- ============================================

BEGIN;

-- Insert a temporary test student
INSERT INTO academics.students
    (first_name, last_name, email,
     major, enrollment_year)
VALUES
    ('Audit', 'Test',
     'phase3.audit.test@example.com',
     'Computer Science', 2026);

-- Verify INSERT audit entry
SELECT
    audit_id,
    student_id,
    operation,
    changed_by,
    new_data->>'email' AS email
FROM audit.student_changes
WHERE new_data->>'email' =
      'phase3.audit.test@example.com'
ORDER BY audit_id DESC;

-- Delete only the temporary test student
DELETE FROM academics.students
WHERE email = 'phase3.audit.test@example.com';

-- Verify INSERT and DELETE audit entries
SELECT
    audit_id,
    student_id,
    operation,
    changed_by,
    changed_at
FROM audit.student_changes
WHERE new_data->>'email' =
      'phase3.audit.test@example.com'
   OR old_data->>'email' =
      'phase3.audit.test@example.com'
ORDER BY audit_id;

ROLLBACK;


-- ============================================
-- 9. TEST GRADE INSERT AND DELETE AUDIT
-- ============================================

BEGIN;

-- Create a temporary enrollment using
-- existing student 1 and course 5
INSERT INTO academics.enrollments
    (student_id, course_id)
VALUES (1, 5);

-- Insert a grade for the temporary enrollment
INSERT INTO academics.grades
    (enrollment_id, grade, letter_grade)
SELECT enrollment_id, 88, 'B'
FROM academics.enrollments
WHERE student_id = 1
  AND course_id = 5;

-- Verify grade INSERT audit
SELECT
    audit_id,
    grade_id,
    operation,
    changed_by,
    new_data->>'grade' AS grade
FROM audit.grade_changes
WHERE new_data->>'enrollment_id' IN (
    SELECT enrollment_id::TEXT
    FROM academics.enrollments
    WHERE student_id = 1
      AND course_id = 5
)
ORDER BY audit_id DESC;

-- Delete the temporary grade
DELETE FROM academics.grades
WHERE enrollment_id IN (
    SELECT enrollment_id
    FROM academics.enrollments
    WHERE student_id = 1
      AND course_id = 5
);

-- Verify grade INSERT and DELETE audits
SELECT
    audit_id,
    grade_id,
    operation,
    changed_by,
    changed_at
FROM audit.grade_changes
WHERE new_data->>'enrollment_id' IN (
    SELECT enrollment_id::TEXT
    FROM academics.enrollments
    WHERE student_id = 1
      AND course_id = 5
)
OR old_data->>'enrollment_id' IN (
    SELECT enrollment_id::TEXT
    FROM academics.enrollments
    WHERE student_id = 1
      AND course_id = 5
)
ORDER BY audit_id;

ROLLBACK;


-- ============================================
-- 10. FINAL AUDIT VERIFICATION
-- ============================================

SELECT
    'student_changes' AS audit_table,
    COUNT(*) AS saved_audit_records
FROM audit.student_changes

UNION ALL

SELECT
    'grade_changes' AS audit_table,
    COUNT(*) AS saved_audit_records
FROM audit.grade_changes;
