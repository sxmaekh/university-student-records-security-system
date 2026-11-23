# University Student Records Security System

**CSCE 4355 – Database Administration | Team 1**

## Project Overview

This project implements a secure university student records database using PostgreSQL 18 and pgAdmin 4.

The system manages students, instructors, courses, enrollments, and grades while demonstrating database administration techniques, including role-based access control, row-level security, auditing, performance optimization, backup and recovery, and database monitoring.

The entire project, including the initial project proposal, database design, implementation, testing, documentation, and GitHub repository management, was completed independently by Sameeha Alikhan.

## Technologies Used

- PostgreSQL 18
- pgAdmin 4
- SQL / PL/pgSQL
- PostgreSQL command-line utilities
- Git and GitHub
- GitHub Desktop

## Database Structure

The project uses three PostgreSQL schemas:

- `academics` – Stores university academic records.
- `security` – Reserved for security-related organization.
- `audit` – Stores database change history.

The `academics` schema contains five tables:

1. `students`
2. `instructors`
3. `courses`
4. `enrollments`
5. `grades`

## Project Phases

### Phase 1: Database Design and Setup

- Designed the university student records database architecture.
- Created the required PostgreSQL schemas.
- Created five academic tables.
- Established primary keys, foreign keys, and database constraints.
- Inserted sample student, instructor, course, enrollment, and grade records.
- Verified database schemas, tables, relationships, and record counts.

### Phase 2: Roles, Permissions, and Row-Level Security

- Created database roles for students, instructors, registrars, and administrators.
- Configured role memberships and database permissions.
- Implemented row-level security policies to restrict access to academic records.
- Tested student access to individual records.
- Tested instructor access to assigned courses and grades.
- Verified authorized and unauthorized database operations.
- Tested registrar permissions and checked for unnecessary elevated privileges.

### Phase 3: Database Auditing

- Created audit tables for student and grade changes.
- Developed PL/pgSQL audit functions.
- Implemented triggers for INSERT, UPDATE, and DELETE operations.
- Recorded database changes, including usernames, timestamps, and old/new values.
- Tested student record modifications.
- Tested grade modifications.
- Verified audit trigger functionality and saved audit records.

### Phase 4: Performance Optimization

- Analyzed database query execution using `EXPLAIN ANALYZE`.
- Established baseline query performance measurements.
- Created three indexes to improve database lookup efficiency.
- Compared query execution before and after indexing.
- Examined query execution plans and PostgreSQL index usage statistics.
- Documented performance test results.

In the recorded tests, query execution time decreased from **0.506 ms to 0.332 ms**, representing an approximately **34.4% improvement**. PostgreSQL continued using sequential scans because the sample dataset was small. This measured difference does not establish that the new indexes caused the improvement.

### Phase 5: Backup and Recovery

- Created a PostgreSQL database backup using `pg_dump`.
- Used PostgreSQL's custom backup archive format.
- Verified the backup file and its contents.
- Created a separate database for recovery testing.
- Restored the backup using `pg_restore`.
- Verified restored academic records.
- Confirmed the restoration of audit triggers, indexes, and row-level security policies.
- Documented the backup and recovery process with screenshots.

### Phase 6: Monitoring and Maintenance

- Monitored active PostgreSQL database connections.
- Checked database size and storage usage.
- Reviewed table activity and statistics.
- Checked for long-running queries.
- Checked for blocked database sessions.
- Executed `VACUUM` and `ANALYZE` maintenance operations.
- Verified maintenance timestamps and table statistics.
- Captured screenshots of database monitoring and maintenance results.

## Repository Structure

```text
university-student-records-security-system/
├── README.md
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_roles_permissions_rls.sql
│   ├── 03_audit_triggers.sql
│   ├── 04_performance_optimization.sql
│   ├── 05_1_security_tests.sql
│   ├── 05_2_university_records_restore_test.sql
│   └── 06_monitoring_maintenance.sql
├── screenshots/
├── backups/
└── report/
```

## Setup Instructions

1. Install PostgreSQL 18 and pgAdmin 4.
2. Create a PostgreSQL database named `university_records`.
3. Connect to `university_records` using pgAdmin 4.
4. Create the required PostgreSQL login accounts with appropriate privileges.
5. Execute the following SQL scripts in order:

```text
01_database_setup.sql
02_roles_permissions_rls.sql
03_audit_triggers.sql
04_performance_optimization.sql
05_1_security_tests.sql
06_monitoring_maintenance.sql
```

6. Create a database backup using `pg_dump`.
7. Restore the backup into a separate database named `university_records_restore_test` using `pg_restore`.
8. Connect to `university_records_restore_test` and execute `05_2_university_records_restore_test.sql` to verify restored records and security features.

**Important:** PostgreSQL login roles must be created before assigning permissions. Run intentional permission-denied security tests separately, and execute `VACUUM` commands outside transaction blocks.

## Testing and Verification

The project includes testing and verification of:

- Database schemas, tables, and sample records
- Primary and foreign key relationships
- User roles and permissions
- Row-level security policies
- Authorized and unauthorized database operations
- Student and grade audit triggers
- Index creation and query performance
- Database backup and restoration
- Active database connections
- Long-running queries and blocked sessions
- Database maintenance operations

Supporting screenshots are available in the `screenshots/` directory.

## Backup and Recovery Results

The database was backed up using PostgreSQL's `pg_dump` utility in custom archive format.

The backup was successfully restored into a separate database named `university_records_restore_test`.

The restored database was verified to contain:

- 10 students
- 3 instructors
- 5 courses
- 13 enrollments
- 13 grades
- 2 audit triggers
- 3 performance indexes
- 13 row-level security policies

Database backups containing records and sensitive credentials are not included in the public repository. PostgreSQL login roles must be provisioned separately because database-specific backups do not include cluster-wide roles.

## Project Proposal and Documentation

The initial CSCE 4355 Team 1 project proposal was independently prepared by Sameeha Alikhan.

The proposal established the project's objectives, database security focus, technical approach, and planned implementation phases.

Sameeha Alikhan also independently completed the SQL implementation, database testing, performance evaluation, backup and recovery verification, monitoring, screenshot evidence collection, and GitHub project documentation.

## Individual Contributions

**Sameeha Alikhan (sa2494)**

**Role: Project Lead, Database Designer, Developer, Database Administrator, Tester, and Documentation Author**

Completed 100% of the project work independently, including:

- Developed and wrote the original project proposal.
- Planned the project objectives, technical requirements, and implementation phases.
- Designed the PostgreSQL database architecture.
- Created all database schemas, tables, relationships, and constraints.
- Prepared and inserted sample academic records.
- Developed and executed the SQL implementation scripts.
- Configured database roles, permissions, and row-level security.
- Implemented and tested database access restrictions.
- Developed audit functions, triggers, and audit tables.
- Tested and verified database auditing functionality.
- Created performance indexes and evaluated query execution.
- Conducted performance testing and documented results.
- Created and verified database backups.
- Performed database restoration and recovery testing.
- Monitored database connections, queries, and table activity.
- Performed database maintenance using `VACUUM` and `ANALYZE`.
- Troubleshot SQL execution and PostgreSQL configuration issues.
- Captured and organized project screenshots as evidence.
- Created and organized the GitHub repository.
- Prepared the README and technical project documentation.
- Completed implementation, verification, and final project preparation.

**All technical implementation, testing, and documentation work was completed by Sameeha Alikhan without contributions from the other team members.**

## Team

**CSCE 4355 – Team 1**

**Project Work Completed By:**

Sameeha Alikhan (sa2494)

The project was assigned as a team project; however, all project development, implementation, testing, and documentation were completed independently by Sameeha Alikhan.

## Project Status

**Database implementation and testing completed.**

All six technical phases have been implemented and tested. Final documentation and presentation materials are completed.

- Final Project Report: [report/Team1_Final_Project_GitHub_And_Video_Demo.pdf](https://github.com/sxmaekh/university-student-records-security-system/blob/main/report/Team1_Final_Project_Report.pdf)
- Final Project Video Demonstration: [Team 1 CSCE 4355 Final Project Video Submission](https://youtu.be/kuMauPw4mVs?si=bxiw3twldpH39EgL) 
