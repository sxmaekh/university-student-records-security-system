# University Student Records Security System

**CSCE 4355 – Database Administration | Team 1**

## Project Overview

This project implements a secure university student records database using PostgreSQL 18 and pgAdmin 4.

The system manages students, instructors, courses, enrollments, and grades while demonstrating database administration techniques, including role-based access control, row-level security, auditing, performance optimization, backup and recovery, and database monitoring.

## Technologies Used

- PostgreSQL 18
- pgAdmin 4
- SQL / PL/pgSQL
- Git and GitHub

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
- Created database schemas and academic tables.
- Established primary keys, foreign keys, and constraints.
- Inserted sample university records.
- Verified table relationships and record counts.

### Phase 2: Roles, Permissions, and Row-Level Security
- Created student, instructor, registrar, and administrator roles.
- Configured role-based permissions.
- Implemented row-level security policies.
- Tested authorized and unauthorized database access.

### Phase 3: Database Auditing
- Created student and grade audit tables.
- Implemented PL/pgSQL audit functions.
- Created triggers for INSERT, UPDATE, and DELETE operations.
- Verified audit records containing usernames, timestamps, and old/new data.

### Phase 4: Performance Optimization
- Analyzed query execution plans using `EXPLAIN ANALYZE`.
- Created indexes for common database relationships.
- Compared query execution before and after indexing.
- Reviewed PostgreSQL index usage statistics.

Because the sample dataset is small, indexing only produced an inconsequential performance improvement in the tested query.

### Phase 5: Backup and Recovery
- Created a PostgreSQL database backup using `pg_dump`.
- Verified backup archive contents.
- Restored the backup into a separate test database.
- Verified restored academic records, audit triggers, indexes, and security policies.

### Phase 6: Monitoring and Maintenance
- Monitored active database connections.
- Checked database size and table statistics.
- Checked for long-running queries and blocked sessions.
- Performed `VACUUM` and `ANALYZE` maintenance.
- Verified maintenance timestamps and table statistics.

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
3. Connect to the database using pgAdmin.
4. Execute the SQL scripts in the following order:

```text
01_database_setup.sql
02_roles_permissions_rls.sql
03_audit_triggers.sql
05_1_security_tests.sql
05_2_university_records_restore_test.sql
06_monitoring_maintenance.sql
```

**Important:** Review the scripts before running them. The security setup requires the appropriate PostgreSQL login roles, and the security tests contain intentional permission-denied operations. Run those tests separately. Execute `VACUUM` commands outside transaction blocks.

## Testing and Verification

The project includes tests for:

- Database schemas, tables, and sample records
- User roles and permissions
- Row-level security
- Authorized and unauthorized updates
- Student and grade audit triggers
- Index creation and query performance
- Backup restoration
- Database monitoring and maintenance

Supporting screenshots are available in the `screenshots/` directory.

## Backup and Recovery

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

## Team

**CSCE 4355 – Team 1**
**Sameeha Alikhan | sa2494**

## Project Status

**Implementation and testing completed.**

All six technical phases have been implemented and tested. Final documentation and presentation materials are being prepared. 
