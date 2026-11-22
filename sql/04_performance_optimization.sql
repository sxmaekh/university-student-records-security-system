-- CSCE 4355 - Team 1
-- University Student Records Security System
-- Phase 4: Performance Optimization

-- ============================================
-- STEP 1: BASELINE PERFORMANCE TEST
-- ============================================

-- Update PostgreSQL table statistics
ANALYZE academics.students;
ANALYZE academics.enrollments;
ANALYZE academics.courses;
ANALYZE academics.grades;

-- Measure performance before optimization
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_code,
    c.course_name,
    g.grade,
    g.letter_grade
FROM academics.students s
JOIN academics.enrollments e
    ON s.student_id = e.student_id
JOIN academics.courses c
    ON e.course_id = c.course_id
JOIN academics.grades g
    ON e.enrollment_id = g.enrollment_id
WHERE s.student_id = 1;

-- ============================================
-- STEP 3: CREATE PERFORMANCE INDEXES
-- ============================================

-- Improve student enrollment lookups
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id
ON academics.enrollments(student_id);

-- Improve course enrollment lookups
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id
ON academics.enrollments(course_id);

-- Improve instructor course lookups
CREATE INDEX IF NOT EXISTS idx_courses_instructor_id
ON academics.courses(instructor_id);

-- Update query planner statistics
ANALYZE academics.enrollments;
ANALYZE academics.courses;

-- Verify indexes
SELECT
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'academics'
  AND indexname IN (
      'idx_enrollments_student_id',
      'idx_enrollments_course_id',
      'idx_courses_instructor_id'
  )
ORDER BY tablename, indexname;

-- ============================================
-- STEP 4: PERFORMANCE TEST AFTER INDEXING
-- ============================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_code,
    c.course_name,
    g.grade,
    g.letter_grade
FROM academics.students s
JOIN academics.enrollments e
    ON s.student_id = e.student_id
JOIN academics.courses c
    ON e.course_id = c.course_id
JOIN academics.grades g
    ON e.enrollment_id = g.enrollment_id
WHERE s.student_id = 1;

-- ============================================
-- STEP 5: VERIFY INDEX USAGE
-- ============================================

SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS index_scans
FROM pg_stat_user_indexes
WHERE schemaname = 'academics'
  AND indexrelname IN (
      'idx_enrollments_student_id',
      'idx_enrollments_course_id',
      'idx_courses_instructor_id'
  )
ORDER BY indexrelname;

-- ============================================
-- PHASE 4: PERFORMANCE TEST RESULTS
-- ============================================

-- Baseline Execution Time: 0.102 ms
-- After Indexing Execution Time: 0.112 ms
--
-- Indexes Created:
-- 1. idx_enrollments_student_id
-- 2. idx_enrollments_course_id
-- 3. idx_courses_instructor_id
--
-- Index Usage:
-- All three indexes recorded 0 scans.
--
-- Conclusion:
-- PostgreSQL continued using sequential scans
-- because the sample database is very small.
-- Indexing did not improve this test query.
-- These indexes may benefit larger datasets
-- and queries that filter on indexed columns.