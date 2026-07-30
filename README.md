# Hospital Database Management System (Oracle SQL)

A relational database modeling core hospital operations — physicians, nurses,
patients, departments, appointments, rooms, procedures, prescriptions, and
stays — plus a set of 35+ analytical SQL queries answering real
operational questions (staffing, room availability, compliance checks,
billing, etc.).

## Tech
- **Database:** Oracle SQL (tested against ORCLPDB / Oracle 19c+ syntax:
  `FETCH FIRST n ROWS ONLY`, `DATE` literals, named constraints)
- **Contents:** DDL (table definitions), DML (seed data), and a query bank

## Repository structure
```
hospital-database-management-system/
├── README.md
├── LICENSE
├── sql/
│   ├── 01_schema_and_data.sql   # DDL + seed data (run this first)
│   └── 02_queries.sql           # 35+ analytical queries
└── docs/
    ├── ERD.png                  # entity-relationship diagram
    └── table_reference.docx     # column-by-column table documentation
```

## How to run
1. Connect to an Oracle schema (e.g. `ORCLPDB` via SQL*Plus, SQL Developer, or DBeaver).
2. Run `sql/01_schema_and_data.sql` — it drops any existing copies of these tables first, then creates them and loads sample data.
3. Run any query from `sql/02_queries.sql` individually to explore the data.

## Schema overview

**15 tables**, organized around three core entities (physicians, nurses,
patients) and their relationships to hospital infrastructure:

- **People:** `physician`, `nurse`, `patient`
- **Organization:** `department`, `affiliated_with` (physician ↔ department)
- **Facilities:** `block`, `room`, `stay` (patient ↔ room over time)
- **Care events:** `appointment`, `undergoes` (patient procedures),
  `prescribes` (medication), `on_call` (nurse scheduling)
- **Reference data:** `procedures`, `medication`, `trained_in`
  (physician certifications)

Every table has a declared **primary key**, and every relationship is
enforced with a **foreign key** — e.g. `appointment.physician` references
`physician.employeeid`, `room.blockfloor/blockcode` references `block`,
`stay.patient` references `patient.ssn`, etc. Dates are stored as native
`DATE` columns rather than free-text strings, so date comparisons
(certification expiry checks, appointment scheduling) are reliable.

## ER Diagram
![Hospital Database ER Diagram](docs/ERD.png)

## Example queries

A few of the more interesting ones from `02_queries.sql`:

- **Compliance check** — physicians who performed a procedure they were
  never certified for (query 29), and physicians who performed a
  procedure *after* their certification had expired (query 31).
- **Capacity planning** — available/unavailable rooms broken down by
  block and floor, and which floor has the most available rooms
  (queries 21–25).
- **Continuity of care** — patients who were prescribed medication by
  their own primary care physician vs. a different one (query 34).
- **Billing** — patients who underwent a procedure costing more than
  $5,000, along with their primary care physician (query 35).

## Notes on this version

This is a cleaned-up version of the original project. Fixes made:
- Added `PRIMARY KEY` / `FOREIGN KEY` constraints to every table (the
  original only had `NOT NULL`)
- Made column names consistent across the schema and every query
  (e.g. `blockfloor` everywhere; `undergoes.assistingnurse` instead of a
  DDL/query mismatch between `ingnurse` and `assistingnurse`)
- Renamed the `procedure` table to `procedures` (avoids Oracle's
  reserved-word ambiguity, and matches what the original queries
  already assumed)
- Converted date columns from `VARCHAR2` to native `DATE`
- Fixed several `INSERT` statements that had syntax errors (missing
  semicolons, references to undeclared columns)
- Split `stay.patient_room` (a single text column mixing two IDs) into
  proper `patient` and `room` foreign key columns

## Possible next steps
- Add a few `VIEW`s for common lookups (e.g. current room occupancy)
- Add an index on frequently-joined columns (`appointment.patient`,
  `undergoes.patient`)
- Add a trigger to auto-flag a room `unavailable` when a `stay` begins
