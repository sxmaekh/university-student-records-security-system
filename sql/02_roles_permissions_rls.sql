-- CSCE 4355 - Team 1
-- University Student Records Security System
-- Phase 2: Roles, Permissions, and RLS

-- Create group roles for different university users

-- Create group roles only if they do not already exist

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_role') THEN
        CREATE ROLE student_role NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'instructor_role') THEN
        CREATE ROLE instructor_role NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'registrar_role') THEN
        CREATE ROLE registrar_role NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dba_admin') THEN
        CREATE ROLE dba_admin NOLOGIN;
    END IF;
END
$$;

-- Verify the roles exist
SELECT rolname, rolcanlogin
FROM pg_roles
WHERE rolname IN (
    'student_role',
    'instructor_role',
    'registrar_role',
    'dba_admin'
)
ORDER BY rolname;

-- ============================================
-- Phase 2: Verify Test User Accounts
-- ============================================

SELECT
    rolname AS username,
    rolcanlogin AS can_login,
    rolsuper AS is_superuser,
    rolcreatedb AS can_create_database,
    rolcreaterole AS can_create_roles,
    rolbypassrls AS bypasses_rls
FROM pg_roles
WHERE rolname IN (
    'student_1',
    'student_2',
    'instructor_1',
    'instructor_2',
    'registrar_user',
    'db_admin_user'
)
ORDER BY rolname;

-- ============================================
-- Phase 2: Assign User Role Memberships
-- ============================================

-- Assign student accounts
GRANT student_role TO student_1;
GRANT student_role TO student_2;

-- Assign instructor accounts
GRANT instructor_role TO instructor_1;
GRANT instructor_role TO instructor_2;

-- Assign registrar account
GRANT registrar_role TO registrar_user;

-- Assign database administrator account
GRANT dba_admin TO db_admin_user;

-- Verify role memberships
SELECT
    member.rolname AS username,
    parent.rolname AS assigned_role
FROM pg_auth_members membership
JOIN pg_roles parent
    ON membership.roleid = parent.oid
JOIN pg_roles member
    ON membership.member = member.oid
WHERE member.rolname IN (
    'student_1',
    'student_2',
    'instructor_1',
    'instructor_2',
    'registrar_user',
    'db_admin_user'
)
ORDER BY username, assigned_role;

-- ============================================
-- Phase 2: Configure Database Permissions
-- ============================================

-- Allow users to connect to the database
GRANT CONNECT ON DATABASE university_records
TO student_role, instructor_role, registrar_role, dba_admin;

-- Restrict access to academic tables
REVOKE ALL ON SCHEMA academics FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA academics FROM PUBLIC;

-- Allow authorized roles to access the academics schema
GRANT USAGE ON SCHEMA academics
TO student_role, instructor_role, registrar_role, dba_admin;

-- Students: read academic information
GRANT SELECT ON
    academics.students,
    academics.courses,
    academics.enrollments,
    academics.grades
TO student_role;

-- Instructors: read academic information
GRANT SELECT ON
    academics.students,
    academics.courses,
    academics.enrollments,
    academics.grades
TO instructor_role;

-- Instructors: update grades only
GRANT UPDATE (grade, letter_grade, last_updated)
ON academics.grades
TO instructor_role;

-- Registrar: manage academic records
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA academics
TO registrar_role;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA academics
TO registrar_role;

-- Database administrator: full academic access
GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA academics
TO dba_admin;

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA academics
TO dba_admin;

-- Verify table permissions
SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'academics'
  AND grantee IN (
      'student_role',
      'instructor_role',
      'registrar_role',
      'dba_admin'
  )
ORDER BY grantee, table_name, privilege_type;

-- Verify instructor grade update permissions
SELECT
    grantee,
    table_name,
    column_name,
    privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'academics'
  AND table_name = 'grades'
  AND grantee = 'instructor_role'
  AND privilege_type = 'UPDATE'
ORDER BY column_name;

-- Check for unexpected role privileges
SELECT
    rolname,
    rolsuper,
    rolbypassrls
FROM pg_roles
WHERE rolname IN (
    'student_1',
    'student_2',
    'instructor_1',
    'instructor_2',
    'registrar_user'
)
ORDER BY rolname;

-- ============================================
-- Phase 2: Enable Row-Level Security
-- ============================================

ALTER TABLE academics.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE academics.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE academics.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE academics.grades ENABLE ROW LEVEL SECURITY;

-- Verify RLS is enabled
SELECT
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'academics'
ORDER BY tablename;

-- ============================================
-- Phase 2: Student Row-Level Security Policies
-- ============================================

-- Students can view only their own student record
CREATE POLICY student_view_own_record
ON academics.students
FOR SELECT
TO student_role
USING (
    student_id = CASE
        WHEN current_user ~ '^student_[0-9]+$'
        THEN substring(current_user FROM 9)::INTEGER
        ELSE -1
    END
);

-- Students can view the course catalog
CREATE POLICY student_view_courses
ON academics.courses
FOR SELECT
TO student_role
USING (true);

-- Students can view only their own enrollments
CREATE POLICY student_view_own_enrollments
ON academics.enrollments
FOR SELECT
TO student_role
USING (
    student_id = CASE
        WHEN current_user ~ '^student_[0-9]+$'
        THEN substring(current_user FROM 9)::INTEGER
        ELSE -1
    END
);

-- Students can view grades for their own enrollments
CREATE POLICY student_view_own_grades
ON academics.grades
FOR SELECT
TO student_role
USING (
    EXISTS (
        SELECT 1
        FROM academics.enrollments e
        WHERE e.enrollment_id = grades.enrollment_id
          AND e.student_id = CASE
              WHEN current_user ~ '^student_[0-9]+$'
              THEN substring(current_user FROM 9)::INTEGER
              ELSE -1
          END
    )
);

SELECT
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE schemaname = 'academics'
ORDER BY tablename, policyname;

-- ============================================
-- Phase 2: Instructor RLS Policies
-- ============================================

-- Instructors can view their assigned courses
CREATE POLICY instructor_view_courses
ON academics.courses
FOR SELECT TO instructor_role
USING (
    instructor_id = CASE
        WHEN current_user ~ '^instructor_[0-9]+$'
        THEN substring(current_user FROM 12)::INTEGER
        ELSE -1
    END
);

-- Instructors can view enrollments in assigned courses
CREATE POLICY instructor_view_enrollments
ON academics.enrollments
FOR SELECT TO instructor_role
USING (
    course_id IN (
        SELECT course_id
        FROM academics.courses
    )
);

-- Instructors can view students enrolled in their courses
CREATE POLICY instructor_view_students
ON academics.students
FOR SELECT TO instructor_role
USING (
    student_id IN (
        SELECT student_id
        FROM academics.enrollments
    )
);

-- Instructors can view grades in their courses
CREATE POLICY instructor_view_grades
ON academics.grades
FOR SELECT TO instructor_role
USING (
    enrollment_id IN (
        SELECT enrollment_id
        FROM academics.enrollments
    )
);

-- Instructors can update grades in their courses
CREATE POLICY instructor_update_grades
ON academics.grades
FOR UPDATE TO instructor_role
USING (
    enrollment_id IN (
        SELECT enrollment_id
        FROM academics.enrollments
    )
)
WITH CHECK (
    enrollment_id IN (
        SELECT enrollment_id
        FROM academics.enrollments
    )
);

-- ============================================
-- Phase 2: Registrar RLS Policies
-- ============================================

CREATE POLICY registrar_students
ON academics.students
FOR ALL TO registrar_role
USING (true)
WITH CHECK (true);

CREATE POLICY registrar_courses
ON academics.courses
FOR ALL TO registrar_role
USING (true)
WITH CHECK (true);

CREATE POLICY registrar_enrollments
ON academics.enrollments
FOR ALL TO registrar_role
USING (true)
WITH CHECK (true);

CREATE POLICY registrar_grades
ON academics.grades
FOR ALL TO registrar_role
USING (true)
WITH CHECK (true);

-- Verify all RLS policies
SELECT
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE schemaname = 'academics'
ORDER BY tablename, policyname;
