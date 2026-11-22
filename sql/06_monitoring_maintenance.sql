-- CSCE 4355 - Team 1
-- University Student Records Security System
-- Phase 6: Database Monitoring and Maintenance

-- ============================================
-- STEP 1: MONITOR DATABASE CONNECTIONS
-- ============================================

SELECT
    pid,
    usename AS username,
    datname AS database_name,
    application_name,
    client_addr,
    state,
    backend_start,
    query_start,
    wait_event_type,
    wait_event
FROM pg_stat_activity
WHERE datname = 'university_records'
ORDER BY backend_start;

-- ============================================
-- STEP 2: DATABASE HEALTH AND TABLE ACTIVITY
-- ============================================

-- Check database size
SELECT
    datname AS database_name,
    pg_size_pretty(pg_database_size(datname)) AS database_size
FROM pg_database
WHERE datname = 'university_records';


-- Check table activity and maintenance statistics
SELECT
    schemaname,
    relname AS table_name,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows,
    seq_scan AS sequential_scans,
    idx_scan AS index_scans,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname IN ('academics', 'audit')
ORDER BY schemaname, relname;

-- ============================================
-- STEP 3: MONITOR LONG-RUNNING QUERIES
-- ============================================

SELECT
    pid,
    usename AS username,
    state,
    NOW() - query_start AS query_duration,
    LEFT(query, 100) AS query_text
FROM pg_stat_activity
WHERE datname = 'university_records'
  AND state = 'active'
  AND query_start < NOW() - INTERVAL '1 minute'
ORDER BY query_duration DESC;


-- ============================================
-- STEP 4: MONITOR BLOCKED SESSIONS
-- ============================================

SELECT
    pid AS blocked_pid,
    usename AS username,
    pg_blocking_pids(pid) AS blocking_pids,
    LEFT(query, 100) AS blocked_query
FROM pg_stat_activity
WHERE datname = 'university_records'
  AND cardinality(pg_blocking_pids(pid)) > 0;

-- ============================================
-- STEP 5: DATABASE MAINTENANCE
-- ============================================

-- Remove dead tuples and update table statistics
VACUUM (ANALYZE) academics.students;
VACUUM (ANALYZE) academics.instructors;
VACUUM (ANALYZE) academics.courses;
VACUUM (ANALYZE) academics.enrollments;
VACUUM (ANALYZE) academics.grades;

-- Maintain audit tables
VACUUM (ANALYZE) audit.student_changes;
VACUUM (ANALYZE) audit.grade_changes;


-- ============================================
-- STEP 6: VERIFY MAINTENANCE
-- ============================================

SELECT
    schemaname,
    relname AS table_name,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows,
    last_vacuum,
    last_analyze
FROM pg_stat_user_tables
WHERE schemaname IN ('academics', 'audit')
ORDER BY schemaname, relname;

VACUUM (ANALYZE) academics.students;
