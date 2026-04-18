-- Drop the database if it exists 
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'finalProject') 
BEGIN 
ALTER DATABASE finalProject SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
DROP DATABASE finalProject; 
END 
GO 

CREATE DATABASE finalProject  
go 

USE finalProject  
go 

-- Ambulances (formerly vehicles) 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_ambulances_driver_id') 
ALTER TABLE ambulances DROP CONSTRAINT fk_ambulances_driver_id;
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_ambulances_pickup_location') 
ALTER TABLE ambulances DROP CONSTRAINT fk_ambulances_pickup_location; 

-- Visits 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_visits_driver_id') 
ALTER TABLE visits DROP CONSTRAINT fk_visits_driver_id; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_visits_doctor_id') 
ALTER TABLE visits DROP CONSTRAINT fk_visits_doctor_id; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_visits_hospital_id') 
ALTER TABLE visits DROP CONSTRAINT fk_visits_hospital_id; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_visits_pickup_location') 
ALTER TABLE visits DROP CONSTRAINT fk_visits_pickup_location; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_visits_patient_id') 
ALTER TABLE visits DROP CONSTRAINT fk_visits_patient_id; 

-- Doctors 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_doctors_hospital_id') 
ALTER TABLE doctors DROP CONSTRAINT fk_doctors_hospital_id; 
 
-- Doctor ER Visit Bridge 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_doctors_visits_doctor_id') 
ALTER TABLE doctors_visits DROP CONSTRAINT fk_doctors_visits_doctor_id; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_doctors_visits_visit_id') 
ALTER TABLE doctors_visits DROP CONSTRAINT fk_doctors_visits_visit_id; 

-- EMT Visits 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_emt_visits_emt_visits_emt_id') 
ALTER TABLE emts_visits DROP CONSTRAINT fk_emt_visits_emt_visits_emt_id; 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_emt_visits_emt_visits_visit_id') 
ALTER TABLE emts_visits DROP CONSTRAINT fk_emt_visits_emt_visits_visit_id; 

-- Drop Bridge Tables First 
DROP TABLE IF EXISTS doctors_visits; 
DROP TABLE IF EXISTS emts_visits; 

-- Drop Core Tables in Dependency-Safe Order 
DROP TABLE IF EXISTS ambulances; 
DROP TABLE IF EXISTS visits; 
DROP TABLE IF EXISTS doctors; 
DROP TABLE IF EXISTS patients; 
DROP TABLE IF EXISTS emts; 
DROP TABLE IF EXISTS drivers; 
DROP TABLE IF EXISTS hospitals; 
DROP TABLE IF EXISTS locations; 

DROP FUNCTION IF EXISTS f_num_doctor_visits
DROP PROCEDURE IF EXISTS p_add_visit
DROP TRIGGER IF EXISTS t_update_dotor_visits


CREATE TABLE hospitals ( 
    hospital_id INT IDENTITY NOT NULL, 
    hospital_name VARCHAR(50) NOT NULL, 
    hospital_street VARCHAR(75) NOT NULL, 
    hospital_city VARCHAR(50) NOT NULL, 
    hospital_state VARCHAR(2) NOT NULL, 
    hospital_zip INT NOT NULL, 
CONSTRAINT pk_hospitals_hospital_id PRIMARY KEY (hospital_id)); 

CREATE TABLE locations ( 
    location_id INT IDENTITY NOT NULL, 
    location_street VARCHAR(100) NOT NULL, 
    location_city VARCHAR(50) NOT NULL, 
    location_state VARCHAR(2) NOT NULL, 
    location_zip INT NOT NULL, 
    CONSTRAINT pk_locations_location_id PRIMARY KEY (location_id)); 

CREATE TABLE drivers ( 
    driver_id INT IDENTITY NOT NULL, 
    driver_firstname VARCHAR(50) NOT NULL, 
    driver_lastname VARCHAR(50) NOT NULL, 
    driver_email VARCHAR(50) NOT NULL, 
    driver_hire_date DATE NOT NULL, 
    CONSTRAINT pk_drivers_driver_id PRIMARY KEY (driver_id), 
    CONSTRAINT u_drivers_driver_email UNIQUE (driver_email)); 
 
CREATE TABLE ambulances ( 
    vehicle_vin VARCHAR(8) NOT NULL, 
    vehicle_make VARCHAR(30) NOT NULL, 
    vehicle_model VARCHAR(30) NOT NULL, 
    vehicle_driver_id INT NOT NULL,
    CONSTRAINT pk_ambulances_vehicle_vin PRIMARY KEY (vehicle_vin)); 

CREATE TABLE patients ( 
    patient_id INT IDENTITY NOT NULL, 
    patient_firstname VARCHAR(50) NOT NULL, 
    patient_lastname VARCHAR(50) NOT NULL, 
    patient_email VARCHAR(50) NOT NULL, 
    CONSTRAINT pk_patients_patient_id PRIMARY KEY (patient_id), 
    CONSTRAINT u_patients_patient_email UNIQUE (patient_email)); 

CREATE TABLE doctors ( 
    doctor_id INT IDENTITY NOT NULL, 
    doctor_firstname VARCHAR(50) NOT NULL, 
    doctor_lastname VARCHAR(50) NOT NULL, 
    doctor_email VARCHAR(50) NOT NULL, 
    doctor_hire_date DATE NOT NULL, 
    doctor_department VARCHAR(50) NOT NULL, 
    doctor_hospital_id INT NOT NULL,
    doctor_visit_count INT NULL DEFAULT 0, 
    CONSTRAINT pk_doctors_doctor_id PRIMARY KEY (doctor_id), 
    CONSTRAINT u_doctors_doctor_email UNIQUE (doctor_email)); 

CREATE TABLE visits ( 
    visit_id INT IDENTITY NOT NULL, 
    visit_date DATETIME NOT NULL, 
    visit_reason VARCHAR(100) NOT NULL, 
    visit_notes VARCHAR(250) NULL, 
    visit_driver_id INT NOT NULL, 
    visit_doctor_id INT NOT NULL, 
    visit_hospital_id INT NOT NULL, 
    visit_pickup_location INT NOT NULL, 
    visit_patient_id INT NOT NULL, 
    CONSTRAINT pk_visits_visit_id PRIMARY KEY (visit_id)); 

CREATE TABLE doctors_visits ( 
    doctor_visit_id INT IDENTITY NOT NULL, 
    doctor_visit_doctor_id INT NOT NULL, 
    doctor_visit_visit_id INT NOT NULL, 
    CONSTRAINT pk_doctors_visits_doctor_visit_id PRIMARY KEY (doctor_visit_id)); 

CREATE TABLE emts ( 
    emt_id INT IDENTITY NOT NULL, 
    emt_firstname VARCHAR(50) NOT NULL, 
    emt_lastname VARCHAR(50) NOT NULL, 
    emt_email VARCHAR(50) NOT NULL, 
    emt_hire_date DATE NOT NULL, 
    CONSTRAINT pk_emts_emt_id PRIMARY KEY (emt_id), 
    CONSTRAINT u_emts_emt_email UNIQUE (emt_email)); 

CREATE TABLE emts_visits ( 
    emt_visit_id INT IDENTITY NOT NULL, 
    emt_visit_emt_id INT NOT NULL, 
    emt_visit_visit_id INT NOT NULL, 
    CONSTRAINT pk_emts_visits_emt_visit_id PRIMARY KEY (emt_visit_id)); 

 

-- Ambulances (formerly vehicles) 
ALTER TABLE ambulances ADD
    CONSTRAINT fk_ambulances_driver_id FOREIGN KEY (vehicle_driver_id) REFERENCES drivers(driver_id); 
 
-- Visits 
ALTER TABLE visits ADD
    CONSTRAINT fk_visits_driver_id FOREIGN KEY (visit_driver_id) REFERENCES drivers(driver_id), 
    CONSTRAINT fk_visits_doctor_id FOREIGN KEY (visit_doctor_id) REFERENCES doctors(doctor_id), 
    CONSTRAINT fk_visits_hospital_id FOREIGN KEY (visit_hospital_id) REFERENCES hospitals(hospital_id), 
    CONSTRAINT fk_visits_pickup_location FOREIGN KEY (visit_pickup_location) REFERENCES locations(location_id), 
    CONSTRAINT fk_visits_patient_id FOREIGN KEY (visit_patient_id) REFERENCES patients(patient_id); 

-- Doctors 
ALTER TABLE doctors ADD
    CONSTRAINT fk_doctors_hospital_id FOREIGN KEY (doctor_hospital_id) REFERENCES hospitals(hospital_id); 
 
-- Doctors_Patients bridge table 
ALTER TABLE doctors_visits ADD 
    CONSTRAINT fk_doctors_visits_doctor_id FOREIGN KEY (doctor_visit_doctor_id) REFERENCES doctors(doctor_id), 
    CONSTRAINT fk_doctors_visits_visit_id FOREIGN KEY (doctor_visit_visit_id) REFERENCES visits(visit_id); 

-- EMTs_Visits bridge table 
ALTER TABLE emts_visits ADD
    CONSTRAINT fk_emt_visits_emt_visits_emt_id FOREIGN KEY (emt_visit_emt_id) REFERENCES emts(emt_id), 
    CONSTRAINT fk_emt_visits_emt_visits_visit_id FOREIGN KEY (emt_visit_visit_id) REFERENCES visits(visit_id); 
GO


--Function, Stored Procedure, and Trigger
CREATE FUNCTION f_num_doctor_visits (@doctor_id INT) 
    RETURNS INT AS BEGIN
        RETURN(SELECT COUNT(*) FROM visits WHERE visit_doctor_id = @doctor_id)
END
GO

CREATE PROCEDURE p_add_visit
    @visit_date DATETIME,
    @visit_reason VARCHAR(100),
    @visit_notes VARCHAR(250),
    @visit_driver_id INT,
    @visit_doctor_id INT,
    @visit_hospital_id INT,
    @visit_pickup_location INT,
    @visit_patient_id INT
AS
BEGIN
    INSERT INTO visits (visit_date, visit_reason, visit_notes, visit_driver_id, visit_doctor_id, visit_hospital_id, visit_pickup_location, visit_patient_id) VALUES 
        (@visit_date, @visit_reason, @visit_notes, @visit_driver_id, @visit_doctor_id, @visit_hospital_id, @visit_pickup_location, @visit_patient_id)
END
GO

CREATE TRIGGER t_update_dotor_visits
ON visits
AFTER INSERT
AS
BEGIN
    DECLARE @doctor_id INT
    DECLARE @visit_count INT
    SELECT @doctor_id = visit_doctor_id FROM inserted
    SET @visit_count = dbo.f_num_doctor_visits(@doctor_id)
    UPDATE doctors
    SET doctor_visit_count = @visit_count
        WHERE doctor_id = @doctor_id
END
GO

--INSERTING EXAMPLE DATA
INSERT INTO hospitals (hospital_name, hospital_street, hospital_city, hospital_state, hospital_zip)VALUES 
    ('Crouse Hospital', '736 Irving Ave', 'Syracuse', 'NY', 13210),
    ('St Joseph Health Hospital', '301 Prospect Ave', 'Syracuse', 'NY', 13203),
    ('Syracuse VA Medical Center', '800 Irving Ave', 'Syracuse', 'NY', 13210)

INSERT INTO doctors (doctor_firstname, doctor_lastname, doctor_email, doctor_hire_date, doctor_department, doctor_hospital_id)VALUES 
    ('Rafe', 'Burns', 'rburns03@syr.edu', '05-05-2025', 'Cardiology', 1),
    ('Aaron', 'Rofe', 'arofe@syr.edu', '02-03-2023', 'Neurology', 2),
    ('Ricky', 'Wan', 'rwan@syr.edu', '04-02-2021', 'Pediatrician', 3)

INSERT INTO drivers (driver_firstname, driver_lastname, driver_email, driver_hire_date) VALUES
    ('Joel', 'Barnes', 'jbarnes@syr.edu', '06-03-2019'),
    ('Arya', 'Patil', 'apatil@syr.edu', '04-30-2023')

INSERT INTO ambulances (vehicle_vin, vehicle_make, vehicle_model, vehicle_driver_id) VALUES
    ('XFH-234', 'Ford', 'Chassis Cab', 1),
    ('LKJ-789', 'Ford', 'Transit Cargo Van', 2)

INSERT INTO locations (location_street, location_city, location_state, location_zip) VALUES
    ('900 Irving Ave', 'Syracuse', 'NY', 13244),
    ('500 Franklin St', 'Syracuse', 'NY', 13202),
    ('307 Clinton St', 'Syracuse', 'NY', 13202),
    ('3422 Erie Blvd', 'Syracuse', 'NY', 13214)

INSERT INTO patients (patient_firstname, patient_lastname, patient_email) VALUES
    ('Kyle', 'McCord', 'kylemccord@gmail.com'),
    ('JJ', 'Starling', 'jjstar@yahoo.com'),
    ('Eddie', 'Lampkin', 'elampkin@hotmail.com'),
    ('Jim', 'Brown', 'jimbrown@gmail.com'),
    ('Ernie', 'Davis', 'edavis@yahoo.com')

INSERT INTO emts (emt_firstname, emt_lastname, emt_email, emt_hire_date) VALUES
    ('Jim', 'Boeheim', 'jimb@gmail.com', '04-03-1976'),
    ('Fran', 'Brown', 'fran@yahoo.com', '11-28-2023'),
    ('Red', 'Autry', 'redautry@syr.edu', '03-08-2023')

--EXAMPLES OF USING THE STORED PROCEDURE TO INSERT DATA INTO THE VISITS TABLE
EXEC p_add_visit    
    @visit_date = '05-04-2025',
    @visit_reason = 'Broken Arm',
    @visit_notes = 'Slipped on ice',
    @visit_driver_id = 1,
    @visit_doctor_id = 1,
    @visit_hospital_id = 1,
    @visit_pickup_location = 1,
    @visit_patient_id = 1;
EXEC p_add_visit    
    @visit_date = '05-04-2025',
    @visit_reason = 'Broken ankle',
    @visit_notes = 'Was playing basketball',
    @visit_driver_id = 2,
    @visit_doctor_id = 2,
    @visit_hospital_id = 2,
    @visit_pickup_location = 4,
    @visit_patient_id = 2;
EXEC p_add_visit    
    @visit_date = '05-04-2025',
    @visit_reason = 'Concussion',
    @visit_notes = 'Fell down stairs',
    @visit_driver_id = 1,
    @visit_doctor_id = 3,
    @visit_hospital_id = 1,
    @visit_pickup_location = 2,
    @visit_patient_id = 3;
EXEC p_add_visit    
    @visit_date = '05-04-2025',
    @visit_reason = 'Torn ACL',
    @visit_notes = 'Was playing football',
    @visit_driver_id = 2,
    @visit_doctor_id = 1,
    @visit_hospital_id = 3,
    @visit_pickup_location = 3,
    @visit_patient_id = 4;

INSERT INTO doctors_visits (doctor_visit_doctor_id, doctor_visit_visit_id) VALUES
    (1,1),
    (2,2),
    (3,3),
    (1,4)

-- CHECK TO SEE IF VISITS INSERTED PROPERLY
-- ALSO CHECK TO SEE IF FUNCTION AND TRIGGER UPDATED doctor_visit_count
SELECT * FROM visits
SELECT * FROM doctors
