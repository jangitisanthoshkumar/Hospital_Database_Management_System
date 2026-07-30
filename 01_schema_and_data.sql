/* =====================================================================
   HOSPITAL DATABASE MANAGEMENT SYSTEM - SCHEMA + SEED DATA
   Corrected version: consistent naming, PK/FK constraints, DATE types
   Target: Oracle SQL (ORCLPDB)
   =====================================================================
   Fixes applied vs. original project files:
   1. Consistent column names across DDL/DML/queries
      (blockfloor everywhere, not "blockkfloor" in one table only;
       ingnurse -> assistingnurse; date_ -> a real DATE column)
   2. Table "procedure" renamed to "procedures" (PROCEDURE is a
      reserved/ambiguous word in Oracle and the original project
      itself mixed "procedure" and "procedures" in different files)
   3. Primary keys and foreign keys added on every table
   4. Dates stored as DATE instead of VARCHAR
   5. Broken INSERT statements fixed (missing/misplaced semicolons,
      undeclared columns, invalid BIT/CURRENT_DATE() column defs)
   6. stay.patient_room (a single VARCHAR mixing two values) split
      into two real FK columns: patient and room
   ===================================================================== */

-- Clean slate (ignore errors if tables don't exist yet)
DROP TABLE undergoes PURGE;
DROP TABLE on_call PURGE;
DROP TABLE stay PURGE;
DROP TABLE prescribes PURGE;
DROP TABLE medication PURGE;
DROP TABLE affiliated_with PURGE;
DROP TABLE trained_in PURGE;
DROP TABLE procedures PURGE;
DROP TABLE appointment PURGE;
DROP TABLE room PURGE;
DROP TABLE patient PURGE;
DROP TABLE department PURGE;
DROP TABLE nurse PURGE;
DROP TABLE physician PURGE;
DROP TABLE block PURGE;

-- =====================================================================
-- 1. BLOCK  (physical hospital block: floor + code)
-- =====================================================================
CREATE TABLE block (
    blockfloor  INTEGER NOT NULL,
    blockcode   INTEGER NOT NULL,
    CONSTRAINT pk_block PRIMARY KEY (blockfloor, blockcode)
);

INSERT ALL
    INTO block VALUES (1,1) INTO block VALUES (1,2) INTO block VALUES (1,3)
    INTO block VALUES (2,1) INTO block VALUES (2,2) INTO block VALUES (2,3)
    INTO block VALUES (3,1) INTO block VALUES (3,2) INTO block VALUES (3,3)
    INTO block VALUES (4,1) INTO block VALUES (4,2) INTO block VALUES (4,3)
SELECT * FROM dual;

-- =====================================================================
-- 2. PHYSICIAN
-- =====================================================================
CREATE TABLE physician (
    employeeid INTEGER      NOT NULL,
    name       VARCHAR2(30) NOT NULL,
    position   VARCHAR2(30) NOT NULL,
    ssn        INTEGER      NOT NULL,
    CONSTRAINT pk_physician PRIMARY KEY (employeeid),
    CONSTRAINT uq_physician_ssn UNIQUE (ssn)
);

INSERT INTO physician (employeeid,name,position,ssn) VALUES (1,'John Dorian','Staff Internist',111111111);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (2,'Elliot Reid','Attending Physician',222222222);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (3,'Christopher Turk','Surgical Attending Physician',333333333);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (4,'Percival Cox','Senior Attending Physician',444444444);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (5,'Bob Kelso','Head Chief of Medicine',555555555);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (6,'Todd Quinlan','Surgical Attending Physician',666666666);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (7,'John Wen','Surgical Attending Physician',777777777);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (8,'Keith Dudemeister','MD Resident',888888888);
INSERT INTO physician (employeeid,name,position,ssn) VALUES (9,'Molly Clock','Attending Psychiatrist',999999999);

-- =====================================================================
-- 3. NURSE
-- =====================================================================
CREATE TABLE nurse (
    employeeid INTEGER      NOT NULL,
    name       VARCHAR2(30) NOT NULL,
    position   VARCHAR2(20) NOT NULL,
    registered VARCHAR2(1)  NOT NULL,
    ssn        INTEGER      NOT NULL,
    CONSTRAINT pk_nurse PRIMARY KEY (employeeid),
    CONSTRAINT uq_nurse_ssn UNIQUE (ssn),
    CONSTRAINT ck_nurse_registered CHECK (registered IN ('t','f'))
);

INSERT INTO nurse (employeeid,name,position,registered,ssn) VALUES (101,'Carla Espinosa','Head Nurse','t',111111110);
INSERT INTO nurse (employeeid,name,position,registered,ssn) VALUES (102,'Laverne Roberts','Nurse','t',222222220);
INSERT INTO nurse (employeeid,name,position,registered,ssn) VALUES (103,'Paul Flowers','Nurse','f',333333330);

-- =====================================================================
-- 4. DEPARTMENT
-- =====================================================================
CREATE TABLE department (
    department_id INTEGER      NOT NULL,
    name          VARCHAR2(30) NOT NULL,
    head          INTEGER      NOT NULL,
    CONSTRAINT pk_department PRIMARY KEY (department_id),
    CONSTRAINT fk_department_head FOREIGN KEY (head) REFERENCES physician(employeeid)
);

INSERT INTO department (department_id,name,head) VALUES (1,'General Medicine',4);
INSERT INTO department (department_id,name,head) VALUES (2,'Surgery',7);
INSERT INTO department (department_id,name,head) VALUES (3,'Psychiatry',9);

-- =====================================================================
-- 5. PATIENT
-- =====================================================================
CREATE TABLE patient (
    ssn         INTEGER      NOT NULL,
    name        VARCHAR2(30) NOT NULL,
    address     VARCHAR2(40) NOT NULL,
    phone       VARCHAR2(15) NOT NULL,
    insuranceid INTEGER      NOT NULL,
    pcp         INTEGER      NOT NULL,
    CONSTRAINT pk_patient PRIMARY KEY (ssn),
    CONSTRAINT fk_patient_pcp FOREIGN KEY (pcp) REFERENCES physician(employeeid)
);

INSERT INTO patient (ssn,name,address,phone,insuranceid,pcp) VALUES (100000001,'John Smith','42 Foobar Lane','555-0256',68476213,1);
INSERT INTO patient (ssn,name,address,phone,insuranceid,pcp) VALUES (100000002,'Grace Ritchie','37 Snafu Drive','555-0512',36546321,2);
INSERT INTO patient (ssn,name,address,phone,insuranceid,pcp) VALUES (100000003,'Random J. Patient','101 Omgbbq Street','555-1204',65465421,2);
INSERT INTO patient (ssn,name,address,phone,insuranceid,pcp) VALUES (100000004,'Dennis Doe','1100 Foobaz Avenue','555-2048',68421879,3);

-- =====================================================================
-- 6. ROOM
-- =====================================================================
CREATE TABLE room (
    roomnumber  INTEGER     NOT NULL,
    roomtype    VARCHAR2(10) NOT NULL,
    blockfloor  INTEGER     NOT NULL,
    blockcode   INTEGER     NOT NULL,
    unavailable VARCHAR2(1) NOT NULL,
    CONSTRAINT pk_room PRIMARY KEY (roomnumber),
    CONSTRAINT fk_room_block FOREIGN KEY (blockfloor, blockcode) REFERENCES block(blockfloor, blockcode),
    CONSTRAINT ck_room_unavailable CHECK (unavailable IN ('t','f'))
);

INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (101,'Single',1,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (102,'Single',1,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (103,'Single',1,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (111,'Single',1,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (112,'Single',1,2,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (113,'Single',1,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (121,'Single',1,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (122,'Single',1,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (123,'Single',1,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (201,'Single',2,1,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (202,'Single',2,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (203,'Single',2,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (211,'Single',2,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (212,'Single',2,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (213,'Single',2,2,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (221,'Single',2,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (222,'Single',2,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (223,'Single',2,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (301,'Single',3,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (302,'Single',3,1,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (303,'Single',3,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (311,'Single',3,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (312,'Single',3,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (313,'Single',3,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (321,'Single',3,3,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (322,'Single',3,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (323,'Single',3,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (401,'Single',4,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (402,'Single',4,1,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (403,'Single',4,1,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (411,'Single',4,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (412,'Single',4,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (413,'Single',4,2,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (421,'Single',4,3,'t');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (422,'Single',4,3,'f');
INSERT INTO room (roomnumber,roomtype,blockfloor,blockcode,unavailable) VALUES (423,'Single',4,3,'f');

-- =====================================================================
-- 7. APPOINTMENT
-- =====================================================================
CREATE TABLE appointment (
    appointmentid   INTEGER     NOT NULL,
    patient         INTEGER     NOT NULL,
    prepnurse       INTEGER,
    physician       INTEGER     NOT NULL,
    start_dt        DATE        NOT NULL,
    end_dt          DATE        NOT NULL,
    examinationroom VARCHAR2(1) NOT NULL,
    CONSTRAINT pk_appointment PRIMARY KEY (appointmentid),
    CONSTRAINT fk_appointment_patient   FOREIGN KEY (patient)   REFERENCES patient(ssn),
    CONSTRAINT fk_appointment_prepnurse FOREIGN KEY (prepnurse) REFERENCES nurse(employeeid),
    CONSTRAINT fk_appointment_physician FOREIGN KEY (physician) REFERENCES physician(employeeid)
);

INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (13216584,100000001,101,1,DATE '2008-04-24',DATE '2008-04-24','A');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (26548913,100000002,101,2,DATE '2008-04-24',DATE '2008-04-24','B');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (36549879,100000001,102,1,DATE '2008-04-25',DATE '2008-04-25','A');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (46846589,100000004,103,4,DATE '2008-04-25',DATE '2008-04-25','B');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (59871321,100000004,NULL,4,DATE '2008-04-26',DATE '2008-04-26','C');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (69879231,100000003,103,2,DATE '2008-04-26',DATE '2008-04-26','C');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (76983231,100000001,NULL,3,DATE '2008-04-26',DATE '2008-04-26','C');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (86213939,100000004,102,9,DATE '2008-04-27',DATE '2008-04-21','A');
INSERT INTO appointment (appointmentid,patient,prepnurse,physician,start_dt,end_dt,examinationroom)
VALUES (93216548,100000002,101,2,DATE '2008-04-27',DATE '2008-04-27','B');

-- =====================================================================
-- 8. PROCEDURES  (renamed from "procedure" - reserved/ambiguous word,
--    and the original project itself inconsistently used both
--    "procedure" and "procedures" across files)
-- =====================================================================
CREATE TABLE procedures (
    code INTEGER      NOT NULL,
    name VARCHAR2(30) NOT NULL,
    cost NUMBER(8,2)  NOT NULL,
    CONSTRAINT pk_procedures PRIMARY KEY (code)
);

INSERT INTO procedures (code,name,cost) VALUES (1,'Reverse Rhinopodoplasty',1500);
INSERT INTO procedures (code,name,cost) VALUES (2,'Obtuse Pyloric Recombobulation',3750);
INSERT INTO procedures (code,name,cost) VALUES (3,'Folded Demiophtalmectomy',4500);
INSERT INTO procedures (code,name,cost) VALUES (4,'Complete Walletectomy',10000);
INSERT INTO procedures (code,name,cost) VALUES (5,'Obfuscated Dermogastrotomy',4899);
INSERT INTO procedures (code,name,cost) VALUES (6,'Reversible Pancreomyoplasty',5600);
INSERT INTO procedures (code,name,cost) VALUES (7,'Follicular Demiectomy',25);

-- =====================================================================
-- 9. TRAINED_IN  (physician <-> procedures, with certification dates)
-- =====================================================================
CREATE TABLE trained_in (
    physician            INTEGER NOT NULL,
    treatment             INTEGER NOT NULL,
    certificationdate     DATE    NOT NULL,
    certificationexpires  DATE    NOT NULL,
    CONSTRAINT pk_trained_in PRIMARY KEY (physician, treatment),
    CONSTRAINT fk_trained_in_physician FOREIGN KEY (physician) REFERENCES physician(employeeid),
    CONSTRAINT fk_trained_in_treatment FOREIGN KEY (treatment) REFERENCES procedures(code)
);

INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (3,1,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (3,2,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (3,5,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (3,6,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (3,7,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (6,2,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (6,5,DATE '2007-01-01',DATE '2007-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (6,6,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,1,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,2,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,3,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,4,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,5,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,6,DATE '2008-01-01',DATE '2008-12-31');
INSERT INTO trained_in (physician,treatment,certificationdate,certificationexpires) VALUES (7,7,DATE '2008-01-01',DATE '2008-12-31');

-- =====================================================================
-- 10. AFFILIATED_WITH  (physician <-> department)
-- =====================================================================
CREATE TABLE affiliated_with (
    physician          INTEGER     NOT NULL,
    department         INTEGER     NOT NULL,
    primaryaffiliation VARCHAR2(1) NOT NULL,
    CONSTRAINT pk_affiliated_with PRIMARY KEY (physician, department),
    CONSTRAINT fk_affiliated_with_phys FOREIGN KEY (physician)  REFERENCES physician(employeeid),
    CONSTRAINT fk_affiliated_with_dept FOREIGN KEY (department) REFERENCES department(department_id),
    CONSTRAINT ck_affiliated_with_prim CHECK (primaryaffiliation IN ('t','f'))
);

INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (1,1,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (2,1,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (3,1,'f');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (3,2,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (4,1,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (5,1,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (6,2,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (7,1,'f');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (7,2,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (8,1,'t');
INSERT INTO affiliated_with (physician,department,primaryaffiliation) VALUES (9,3,'t');

-- =====================================================================
-- 11. MEDICATION
-- =====================================================================
CREATE TABLE medication (
    code        INTEGER      NOT NULL,
    name        VARCHAR2(20) NOT NULL,
    brand       VARCHAR2(30),
    description VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_medication PRIMARY KEY (code)
);

INSERT INTO medication (code,name,brand,description) VALUES (1,'Procrastin-X',NULL,'N/A');
INSERT INTO medication (code,name,brand,description) VALUES (2,'Thesisin','Foo Labs','N/A');
INSERT INTO medication (code,name,brand,description) VALUES (3,'Awakin','Bar Laboratories','N/A');
INSERT INTO medication (code,name,brand,description) VALUES (4,'Crescavitin','Baz Industries','N/A');
INSERT INTO medication (code,name,brand,description) VALUES (5,'Melioraurin','Snafu Pharmaceuticals','N/A');

-- =====================================================================
-- 12. PRESCRIBES  (physician prescribes medication to patient)
-- =====================================================================
CREATE TABLE prescribes (
    physician       INTEGER NOT NULL,
    patient         INTEGER NOT NULL,
    medication      INTEGER NOT NULL,
    date_prescribed DATE    NOT NULL,
    appointment     INTEGER,
    dose            INTEGER NOT NULL,
    CONSTRAINT pk_prescribes PRIMARY KEY (physician, patient, medication, date_prescribed),
    CONSTRAINT fk_prescribes_physician   FOREIGN KEY (physician)   REFERENCES physician(employeeid),
    CONSTRAINT fk_prescribes_patient     FOREIGN KEY (patient)     REFERENCES patient(ssn),
    CONSTRAINT fk_prescribes_medication  FOREIGN KEY (medication)  REFERENCES medication(code),
    CONSTRAINT fk_prescribes_appointment FOREIGN KEY (appointment) REFERENCES appointment(appointmentid)
);

INSERT INTO prescribes (physician,patient,medication,date_prescribed,appointment,dose) VALUES (1,100000001,1,DATE '2008-04-24',13216584,5);
INSERT INTO prescribes (physician,patient,medication,date_prescribed,appointment,dose) VALUES (9,100000004,2,DATE '2008-04-27',86213939,10);
INSERT INTO prescribes (physician,patient,medication,date_prescribed,appointment,dose) VALUES (9,100000004,2,DATE '2008-04-30',NULL,5);

-- =====================================================================
-- 13. STAY  (patient's stay in a room)
--     Original project packed "patient" + "room" into a single
--     VARCHAR "patient_room" column - split into two real FK columns.
-- =====================================================================
CREATE TABLE stay (
    stayid     INTEGER NOT NULL,
    patient    INTEGER NOT NULL,
    room       INTEGER NOT NULL,
    start_time DATE    NOT NULL,
    end_time   DATE    NOT NULL,
    CONSTRAINT pk_stay PRIMARY KEY (stayid),
    CONSTRAINT fk_stay_patient FOREIGN KEY (patient) REFERENCES patient(ssn),
    CONSTRAINT fk_stay_room    FOREIGN KEY (room)    REFERENCES room(roomnumber)
);

INSERT INTO stay (stayid,patient,room,start_time,end_time) VALUES (3215,100000001,111,DATE '2008-05-01',DATE '2008-05-04');
INSERT INTO stay (stayid,patient,room,start_time,end_time) VALUES (3216,100000003,123,DATE '2008-05-03',DATE '2008-05-14');
INSERT INTO stay (stayid,patient,room,start_time,end_time) VALUES (3217,100000004,112,DATE '2008-05-02',DATE '2008-05-03');

-- =====================================================================
-- 14. ON_CALL  (nurse on call for a block during a date range)
-- =====================================================================
CREATE TABLE on_call (
    nurse        INTEGER NOT NULL,
    blockfloor   INTEGER NOT NULL,
    blockcode    INTEGER NOT NULL,
    oncall_start DATE    NOT NULL,
    oncall_end   DATE    NOT NULL,
    CONSTRAINT pk_on_call PRIMARY KEY (nurse, blockfloor, blockcode, oncall_start),
    CONSTRAINT fk_on_call_nurse FOREIGN KEY (nurse) REFERENCES nurse(employeeid),
    CONSTRAINT fk_on_call_block FOREIGN KEY (blockfloor, blockcode) REFERENCES block(blockfloor, blockcode)
);

INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (101,1,1,DATE '2008-11-04',DATE '2008-11-04');
INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (101,1,2,DATE '2008-11-04',DATE '2008-11-04');
INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (102,1,3,DATE '2008-11-04',DATE '2008-11-04');
INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (103,1,1,DATE '2008-11-04',DATE '2008-11-04');
INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (103,1,2,DATE '2008-11-04',DATE '2008-11-04');
INSERT INTO on_call (nurse,blockfloor,blockcode,oncall_start,oncall_end) VALUES (103,1,3,DATE '2008-11-04',DATE '2008-11-04');

-- =====================================================================
-- 15. UNDERGOES  (patient undergoes a procedure during a stay)
--     "ingnurse" renamed to "assistingnurse" to match how later
--     queries in the original project referred to it.
-- =====================================================================
CREATE TABLE undergoes (
    patient         INTEGER NOT NULL,
    procedure_code  INTEGER NOT NULL,
    stay            INTEGER NOT NULL,
    date_undergone  DATE    NOT NULL,
    physicianassist INTEGER NOT NULL,
    assistingnurse  INTEGER,
    CONSTRAINT pk_undergoes PRIMARY KEY (patient, procedure_code, stay, date_undergone),
    CONSTRAINT fk_undergoes_patient   FOREIGN KEY (patient)         REFERENCES patient(ssn),
    CONSTRAINT fk_undergoes_procedure FOREIGN KEY (procedure_code)  REFERENCES procedures(code),
    CONSTRAINT fk_undergoes_stay      FOREIGN KEY (stay)            REFERENCES stay(stayid),
    CONSTRAINT fk_undergoes_physassit FOREIGN KEY (physicianassist) REFERENCES physician(employeeid),
    CONSTRAINT fk_undergoes_nurse     FOREIGN KEY (assistingnurse)  REFERENCES nurse(employeeid)
);

INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000001,6,3215,DATE '2008-05-02',3,101);
INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000001,2,3215,DATE '2008-05-03',7,101);
INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000004,1,3217,DATE '2008-05-07',3,102);
INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000004,5,3217,DATE '2008-05-09',6,NULL);
INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000001,7,3217,DATE '2008-05-10',7,101);
INSERT INTO undergoes (patient,procedure_code,stay,date_undergone,physicianassist,assistingnurse) VALUES (100000004,4,3217,DATE '2008-05-13',3,103);

COMMIT;
