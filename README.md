# Hospital Database Management System (Oracle SQL)

A normalized Oracle SQL database modeling hospital operations — physicians, patients, appointments, rooms, procedures, and prescriptions — with 15 tables, full referential integrity, and 35+ analytical queries.

## Repository structure
```
hospital-database-management-system/
├── README.md
├── LICENSE.txt
├── sql/
│   ├── 01_schema_and_data.sql   # DDL + seed data (run this first)
│   └── 02_queries.sql           # 35+ analytical queries
└── docs/
    ├── ERD.png                  # entity-relationship diagram
    └── table_reference.docx     # column-by-column documentation
```

## How to run
1. Connect to an Oracle schema (e.g. `ORCLPDB`) via SQL*Plus, SQL Developer, or DBeaver.
2. Run `sql/01_schema_and_data.sql` to create the tables and load sample data.
3. Run any query from `sql/02_queries.sql` to explore the data.

## Schema
**15 tables** covering people (`physician`, `nurse`, `patient`), organization (`department`, `affiliated_with`), facilities (`block`, `room`, `stay`), care events (`appointment`, `undergoes`, `prescribes`, `on_call`), and reference data (`procedures`, `medication`, `trained_in`). Every table has a primary key, and every relationship is enforced with a foreign key. Dates use native `DATE` columns.

## ER Diagram
![Hospital Database ER Diagram](docs/ERD.png)

## Example queries
- **Compliance:** physicians who performed a procedure outside their certification, or after it expired
- **Capacity:** room availability by block and floor
- **Continuity of care:** patients prescribed medication by their own primary care physician
- **Billing:** patients who underwent procedures costing over $5,000

## About this version
Cleaned up from the original project: added PK/FK constraints on every table, fixed column name mismatches, converted date columns from text to `DATE`, and corrected several broken `INSERT` statements.
