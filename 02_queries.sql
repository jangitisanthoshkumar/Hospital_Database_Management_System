/* =====================================================================
   HOSPITAL DATABASE MANAGEMENT SYSTEM - ANALYTICAL QUERIES
   Corrected version: rewritten to match 01_schema_and_data.sql
   (fixed table/column name mismatches, the "innerjoin" typo, and
   queries that referenced non-existent columns such as
   undergoes.assistingnurse when the DDL said "ingnurse", or a
   "date_" column when the table just had "date")
   ===================================================================== */

-- 1. Nurses who are not yet registered
SELECT * FROM nurse
WHERE registered = 'f';

-- 2. Nurses who are head of their department
SELECT * FROM nurse
WHERE position = 'Head Nurse';

-- 3. Physicians who are the head of each department
SELECT p.name AS physician_name, d.name AS department_name
FROM physician p
JOIN department d ON p.employeeid = d.head;

-- 4. Number of patients who have taken an appointment with at least one physician
SELECT COUNT(DISTINCT patient) AS patient_count
FROM appointment;

-- 5. Floor and block that room number 212 belongs to
SELECT blockfloor, blockcode, roomnumber
FROM room
WHERE roomnumber = 212;

-- 6. Number of available rooms
SELECT COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f';

-- 7. Number of unavailable rooms
SELECT COUNT(*) AS unavailable_rooms
FROM room
WHERE unavailable = 't';

-- 8. Physicians and the department they are primarily affiliated with
SELECT p.employeeid, aw.department, p.name AS physician_name, d.name AS department_name
FROM physician p
JOIN affiliated_with aw ON p.employeeid = aw.physician
JOIN department d ON aw.department = d.department_id
WHERE aw.primaryaffiliation = 't';

-- 9. Physicians who are trained for a special treatment (procedure)
--    method 1: subquery
SELECT employeeid, name
FROM physician
WHERE employeeid IN (SELECT DISTINCT physician FROM trained_in);

--    method 2: join, also showing which procedure
SELECT p.employeeid, p.name, pr.code, pr.name AS procedure_name
FROM physician p
JOIN trained_in ti ON p.employeeid = ti.physician
JOIN procedures pr ON ti.treatment = pr.code;

-- 10. Physicians (with department) who are not yet primarily affiliated
SELECT p.name AS physician_name, d.name AS department_name
FROM physician p
JOIN affiliated_with aw ON p.employeeid = aw.physician
JOIN department d ON aw.department = d.department_id
WHERE aw.primaryaffiliation = 'f';

-- 11. Physicians who are not trained/specialized in any procedure
SELECT name AS not_specialized_physicians
FROM physician
WHERE employeeid NOT IN (SELECT DISTINCT physician FROM trained_in);

-- 12. Patients with the physician who provides their primary care
SELECT p.name AS patient_name, ph.name AS primary_care_physician
FROM patient p
JOIN physician ph ON p.pcp = ph.employeeid;

-- 13. Patients and the number of distinct physicians they've had appointments with
SELECT p.name AS patient_name, COUNT(DISTINCT a.physician) AS physicians_seen
FROM patient p
JOIN appointment a ON p.ssn = a.patient
GROUP BY p.name;

-- 14. Number of unique patients who had an appointment in examination room C
SELECT examinationroom, COUNT(DISTINCT patient) AS patient_count
FROM appointment
WHERE examinationroom = 'C'
GROUP BY examinationroom;

-- 15. Patients and the room number where they are/were staying
SELECT p.name AS patient_name, s.room AS roomnumber
FROM patient p
JOIN stay s ON p.ssn = s.patient;

-- 16. Nurses and the rooms (via stay) where they assisted a procedure
SELECT n.employeeid AS nurse_id, n.name AS nurse_name, s.room AS room_no
FROM nurse n
JOIN undergoes u ON n.employeeid = u.assistingnurse
JOIN stay s ON u.stay = s.stayid;

-- 17. Patients with an appointment on 25 Apr 2008, plus physician, nurse, room
SELECT p.name AS patient_name,
       ph.name AS physician_name,
       n.name AS nurse_name,
       a.examinationroom
FROM patient p
JOIN appointment a ON p.ssn = a.patient
LEFT JOIN physician ph ON a.physician = ph.employeeid
LEFT JOIN nurse n ON a.prepnurse = n.employeeid
WHERE a.start_dt = DATE '2008-04-25';

-- 18. Patients and physicians for procedures that needed no assisting nurse
SELECT p.name AS patient_name, ph.name AS physician_name
FROM patient p
JOIN undergoes u ON p.ssn = u.patient
JOIN physician ph ON u.physicianassist = ph.employeeid
WHERE u.assistingnurse IS NULL;

-- 19. Patients, their treating physician, and prescribed medication
SELECT p.ssn, p.name AS patient_name, ph.name AS treating_physician, m.name AS medicine_name
FROM patient p
JOIN prescribes pr ON p.ssn = pr.patient
JOIN medication m ON pr.medication = m.code
JOIN physician ph ON pr.physician = ph.employeeid;

-- 20. Patients who had an appointment, plus physician and any prescribed medication
SELECT p.ssn,
       p.name AS patient_name,
       ph.name AS physician_name,
       m.name AS medicine_name
FROM patient p
LEFT JOIN appointment a ON p.ssn = a.patient
LEFT JOIN prescribes pr ON a.patient = pr.patient
LEFT JOIN physician ph ON pr.physician = ph.employeeid
LEFT JOIN medication m ON pr.medication = m.code;

-- 21. Number of available rooms in each block
SELECT blockcode AS block_no, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockcode;

-- 22. Number of available rooms on each floor
SELECT blockfloor AS floor_no, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockfloor;

-- 23. Number of available rooms per block, per floor
SELECT blockcode, blockfloor, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockcode, blockfloor
ORDER BY 1, 2;

-- 24. Number of unavailable rooms per block, per floor
SELECT blockcode, blockfloor, COUNT(*) AS unavailable_rooms
FROM room
WHERE unavailable = 't'
GROUP BY blockcode, blockfloor
ORDER BY 1, 2;

-- 25. Floor with the maximum number of available rooms
SELECT blockfloor, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockfloor
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY;

-- 26. Floor with the minimum number of available rooms
SELECT blockfloor, COUNT(*) AS available_rooms
FROM room
WHERE unavailable = 'f'
GROUP BY blockfloor
HAVING COUNT(*) = (
    SELECT MIN(cnt) FROM (
        SELECT COUNT(*) AS cnt
        FROM room
        WHERE unavailable = 'f'
        GROUP BY blockfloor
    )
)
ORDER BY blockfloor;

-- 27. Patients with their block, floor, and room number
SELECT p.ssn AS patient_id,
       p.name AS patient_name,
       r.blockfloor,
       r.blockcode,
       r.roomnumber
FROM patient p
JOIN stay s ON p.ssn = s.patient
JOIN room r ON s.room = r.roomnumber;

-- 28. Nurses and the block(s) where they are on call
SELECT n.employeeid AS nurse_id,
       n.name AS nurse_name,
       oc.blockcode
FROM nurse n
LEFT JOIN on_call oc ON n.employeeid = oc.nurse;

-- 29. Physicians who performed a procedure they are NOT certified for
SELECT ph.name AS physician_name, u.procedure_code
FROM physician ph
JOIN undergoes u ON ph.employeeid = u.physicianassist
LEFT JOIN trained_in ti
       ON u.physicianassist = ti.physician
      AND u.procedure_code = ti.treatment
WHERE ti.treatment IS NULL;

-- 30. Same as above, with patient name, procedure name, and date of procedure
SELECT p.name AS patient_name,
       ph.name AS physician_name,
       u.date_undergone AS date_of_procedure,
       pr.name AS procedure_name,
       pr.code AS procedure_code
FROM physician ph
JOIN undergoes u ON ph.employeeid = u.physicianassist
LEFT JOIN trained_in ti
       ON u.physicianassist = ti.physician
      AND u.procedure_code = ti.treatment
LEFT JOIN patient p ON u.patient = p.ssn
LEFT JOIN procedures pr ON u.procedure_code = pr.code
WHERE ti.treatment IS NULL;

-- 31. Physicians who performed a procedure after their certification expired
SELECT DISTINCT ph.employeeid, ph.name AS physician_name, ph.position
FROM physician ph
JOIN undergoes u ON ph.employeeid = u.physicianassist
JOIN trained_in ti
     ON u.physicianassist = ti.physician
    AND u.procedure_code = ti.treatment
WHERE u.date_undergone > ti.certificationexpires;

-- 32. Same as above, with more detail: position, procedure, date, patient, expiry date
SELECT ph.employeeid,
       ph.name AS physician_name,
       ph.position,
       pr.name AS procedure_name,
       u.date_undergone AS date_of_procedure,
       p.name AS patient_name,
       ti.certificationexpires
FROM physician ph
JOIN undergoes u ON ph.employeeid = u.physicianassist
JOIN patient p ON u.patient = p.ssn
JOIN trained_in ti
     ON u.physicianassist = ti.physician
    AND u.procedure_code = ti.treatment
JOIN procedures pr ON ti.treatment = pr.code
WHERE u.date_undergone > ti.certificationexpires;

-- 33. Nurses who have ever been on call for the block containing room 122
SELECT DISTINCT n.employeeid, n.name AS nurse_name
FROM nurse n
JOIN on_call oc ON n.employeeid = oc.nurse
JOIN room r ON oc.blockfloor = r.blockfloor AND oc.blockcode = r.blockcode
WHERE r.roomnumber = 122;

-- 34. Patients prescribed medication by their own primary care physician
SELECT DISTINCT p.name AS patient_name, ph.name AS physician_name
FROM patient p
JOIN prescribes pr ON p.ssn = pr.patient
JOIN physician ph ON pr.physician = ph.employeeid
WHERE p.pcp = pr.physician;

-- 35. Patients who underwent a procedure costing more than $5,000, with their PCP
SELECT DISTINCT p.ssn, ph.employeeid AS physician_id,
       p.name AS patient_name,
       ph.name AS primary_care_physician
FROM patient p
JOIN undergoes u ON p.ssn = u.patient
JOIN procedures pr ON u.procedure_code = pr.code
JOIN physician ph ON p.pcp = ph.employeeid
WHERE pr.cost > 5000;

-- 36. Patients with 2+ appointments prepped by a registered nurse, with their PCP
SELECT a.patient AS patient_id, p.name AS patient_name, ph.name AS physician_name
FROM patient p
JOIN appointment a ON p.ssn = a.patient
JOIN nurse n ON a.prepnurse = n.employeeid
JOIN physician ph ON p.pcp = ph.employeeid
WHERE n.registered = 't'
GROUP BY a.patient, p.name, ph.name
HAVING COUNT(a.start_dt) >= 2;

-- 37. Patients whose PCP is not the head of any department, with that PCP's name
SELECT p.name AS patient_name,
       ph.name AS primary_care_physician_name
FROM patient p
JOIN physician ph ON p.pcp = ph.employeeid
WHERE p.pcp NOT IN (SELECT head FROM department);
