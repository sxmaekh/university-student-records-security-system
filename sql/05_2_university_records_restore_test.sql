-- ============================================
-- PHASE 5: BACKUP AND RECOVERY VERIFICATION
-- ============================================

-- Verify restored academic records
SELECT 'students' AS table_name, COUNT(*) AS record_count
FROM academics.students

UNION ALL

SELECT 'instructors', COUNT(*)
FROM academics.instructors

UNION ALL

SELECT 'courses', COUNT(*)
FROM academics.courses

UNION ALL

SELECT 'enrollments', COUNT(*)
FROM academics.enrollments

UNION ALL

SELECT 'grades', COUNT(*)
FROM academics.grades;

-- Verify restored audit triggers
SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    tgenabled AS enabled
FROM pg_trigger
WHERE NOT tgisinternal
  AND tgname IN (
      'trg_student_audit',
      'trg_grade_audit'
  );

-- Verify restored performance indexes
SELECT
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'academics'
  AND indexname IN (
      'idx_enrollments_student_id',
      'idx_enrollments_course_id',
      'idx_courses_instructor_id'
  );

-- Verify restored security policies
SELECT
    schemaname,
    tablename,
    policyname
FROM pg_policies
WHERE schemaname = 'academics'
ORDER BY tablename, policyname;

SELECT 'Audit Triggers' AS feature, COUNT(*) AS total
FROM pg_trigger
WHERE NOT tgisinternal
  AND tgname IN ('trg_student_audit', 'trg_grade_audit')

UNION ALL

SELECT 'Performance Indexes', COUNT(*)
FROM pg_indexes
WHERE schemaname = 'academics'
  AND indexname IN (
      'idx_enrollments_student_id',
      'idx_enrollments_course_id',
      'idx_courses_instructor_id'
  )

UNION ALL

SELECT 'RLS Policies', COUNT(*)
FROM pg_policies
WHERE schemaname = 'academics';