-- CSCE 4355 - Team 1
-- University Student Records Security System
-- Phase 1: Database Setup

-- Run this script inside the university_records database.

-- Create the required schemas
CREATE SCHEMA IF NOT EXISTS academics;
CREATE SCHEMA IF NOT EXISTS security;
CREATE SCHEMA IF NOT EXISTS audit;

-- Verify that the schemas exist
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('academics', 'security', 'audit')
ORDER BY schema_name;

-- ============================================
-- Phase 1: Create Academic Tables
-- ============================================

-- 1. Students
CREATE TABLE IF NOT EXISTS academics.students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    major VARCHAR(100),
    enrollment_year INTEGER NOT NULL
);

-- 2. Instructors
CREATE TABLE IF NOT EXISTS academics.instructors (
    instructor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(100)
);

-- 3. Courses
CREATE TABLE IF NOT EXISTS academics.courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER NOT NULL CHECK (credits > 0),
    instructor_id INTEGER REFERENCES academics.instructors(instructor_id)
);

-- 4. Enrollments
CREATE TABLE IF NOT EXISTS academics.enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL
        REFERENCES academics.students(student_id),
    course_id INTEGER NOT NULL
        REFERENCES academics.courses(course_id),
    enrollment_date DATE DEFAULT CURRENT_DATE,
    UNIQUE (student_id, course_id)
);

-- 5. Grades
CREATE TABLE IF NOT EXISTS academics.grades (
    grade_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER UNIQUE NOT NULL
        REFERENCES academics.enrollments(enrollment_id),
    grade NUMERIC(5,2) CHECK (grade BETWEEN 0 AND 100),
    letter_grade VARCHAR(2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verify all five tables exist
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('academics', 'audit')
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

-- ============================================
-- Phase 1: Insert Sample Data
-- ============================================

-- Insert 10 students
INSERT INTO academics.students
(first_name, last_name, email, major, enrollment_year)
VALUES
('James', 'Wilson', 'james.wilson@example.com', 'Computer Science', 2023),
('Emily', 'Johnson', 'emily.johnson@example.com', 'Biology', 2022),
('Michael', 'Brown', 'michael.brown@example.com', 'Mathematics', 2024),
('Sarah', 'Davis', 'sarah.davis@example.com', 'Computer Science', 2023),
('Daniel', 'Miller', 'daniel.miller@example.com', 'Engineering', 2022),
('Olivia', 'Anderson', 'olivia.anderson@example.com', 'Business', 2024),
('David', 'Thomas', 'david.thomas@example.com', 'Physics', 2023),
('Sophia', 'Jackson', 'sophia.jackson@example.com', 'Chemistry', 2022),
('William', 'White', 'william.white@example.com', 'Computer Science', 2024),
('Ava', 'Harris', 'ava.harris@example.com', 'Mathematics', 2023);

-- Insert 3 instructors
INSERT INTO academics.instructors
(first_name, last_name, email, department)
VALUES
('Robert', 'Smith', 'robert.smith@example.com', 'Computer Science'),
('Linda', 'Taylor', 'linda.taylor@example.com', 'Mathematics'),
('Jennifer', 'Moore', 'jennifer.moore@example.com', 'Science');

-- Insert 5 courses
INSERT INTO academics.courses
(course_code, course_name, credits, instructor_id)
VALUES
('CS101', 'Introduction to Programming', 3, 1),
('CS201', 'Database Systems', 3, 1),
('MATH101', 'College Algebra', 3, 2),
('MATH201', 'Calculus I', 4, 2),
('SCI101', 'General Science', 3, 3);

-- Insert 13 enrollments
INSERT INTO academics.enrollments
(student_id, course_id)
VALUES
(1, 1), (1, 2),
(2, 5),
(3, 3), (3, 4),
(4, 1), (4, 2),
(5, 4),
(6, 5),
(7, 5),
(8, 5),
(9, 1),
(10, 3);

-- Insert 13 grades
INSERT INTO academics.grades
(enrollment_id, grade, letter_grade)
VALUES
(1, 95, 'A'),
(2, 91, 'A'),
(3, 87, 'B'),
(4, 90, 'A'),
(5, 85, 'B'),
(6, 92, 'A'),
(7, 88, 'B'),
(8, 78, 'C'),
(9, 94, 'A'),
(10, 83, 'B'),
(11, 89, 'B'),
(12, 96, 'A'),
(13, 81, 'B');

-- Verify record counts
SELECT 'students' AS table_name, COUNT(*) FROM academics.students
UNION ALL
SELECT 'instructors', COUNT(*) FROM academics.instructors
UNION ALL
SELECT 'courses', COUNT(*) FROM academics.courses
UNION ALL
SELECT 'enrollments', COUNT(*) FROM academics.enrollments
UNION ALL
SELECT 'grades', COUNT(*) FROM academics.grades;

-- ============================================
-- Phase 1: Verify Table Relationships
-- ============================================

-- Display students, their courses, instructors, and grades
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_code,
    c.course_name,
    i.first_name || ' ' || i.last_name AS instructor_name,
    g.grade,
    g.letter_grade
FROM academics.students s
JOIN academics.enrollments e
    ON s.student_id = e.student_id
JOIN academics.courses c
    ON e.course_id = c.course_id
JOIN academics.instructors i
    ON c.instructor_id = i.instructor_id
JOIN academics.grades g
    ON e.enrollment_id = g.enrollment_id
ORDER BY s.student_id, c.course_code;