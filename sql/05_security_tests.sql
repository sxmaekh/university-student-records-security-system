-- Test student_1 permissions
BEGIN;

SET LOCAL ROLE student_1;

SELECT current_user;

-- Should return only student 1
SELECT student_id, first_name, last_name
FROM academics.students;

-- Should return only student 1's enrollments
SELECT student_id, course_id
FROM academics.enrollments;

-- Should return only student 1's grades
SELECT grade_id, enrollment_id, grade
FROM academics.grades;

ROLLBACK;

-- Test instructor_1 permissions
BEGIN;

SET LOCAL ROLE instructor_1;

SELECT current_user;

-- View assigned courses
SELECT course_id, course_code, course_name
FROM academics.courses
ORDER BY course_id;

-- View students enrolled in assigned courses
SELECT student_id, first_name, last_name
FROM academics.students
ORDER BY student_id;

-- View grades for assigned courses
SELECT grade_id, enrollment_id, grade
FROM academics.grades
ORDER BY grade_id;

ROLLBACK;

-- Test an authorized instructor grade update
BEGIN;

SET LOCAL ROLE instructor_1;

-- Grade 1 belongs to CS101, taught by instructor_1
UPDATE academics.grades
SET grade = 93,
    letter_grade = 'A',
    last_updated = CURRENT_TIMESTAMP
WHERE grade_id = 1
RETURNING grade_id, grade, letter_grade;

ROLLBACK;

-- Test unauthorized instructor grade update
BEGIN;

SET LOCAL ROLE instructor_1;

-- Attempt to update a grade outside assigned courses
UPDATE academics.grades
SET grade = 50,
    letter_grade = 'F',
    last_updated = CURRENT_TIMESTAMP
WHERE grade_id = 3
RETURNING grade_id, grade, letter_grade;

ROLLBACK;

-- ============================================
-- Phase 2: Test Registrar Permissions
-- ============================================

BEGIN;

SET LOCAL ROLE registrar_user;

SELECT current_user;

-- Registrar should see all students
SELECT COUNT(*) AS total_students
FROM academics.students;

-- Registrar should see all courses
SELECT COUNT(*) AS total_courses
FROM academics.courses;

-- Registrar should see all grades
SELECT COUNT(*) AS total_grades
FROM academics.grades;

-- Test authorized student record update
UPDATE academics.students
SET major = 'Information Technology'
WHERE student_id = 1
RETURNING student_id, first_name, major;

ROLLBACK;

-- Verify login accounts do not have elevated privileges
SELECT
    rolname,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
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

-- Produces an error. Run separately. 
BEGIN;

SET LOCAL ROLE student_1;

UPDATE academics.grades
SET grade = 100
WHERE grade_id = 1;

ROLLBACK;

