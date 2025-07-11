--DATABASE SCHEMA
CREATE TABLE Department (
    dnum INT PRIMARY KEY,
    dname VARCHAR(50) NOT NULL,
    location VARCHAR(50),
    managerID INT,
    managerHiringDate DATE,
);
CREATE TABLE Employee (
    ssn INT PRIMARY KEY,
    gender CHAR(1),
    dob DATE,
    fname VARCHAR(50),
    lname VARCHAR(50),
    dnum INT,
    supervisor_ssn INT,
    CONSTRAINT fk_employee_department FOREIGN KEY (dnum) REFERENCES Department(dnum),
    CONSTRAINT fk_supervisor FOREIGN KEY (supervisor_ssn) REFERENCES Employee(ssn)
);
CREATE TABLE Dependent (
    name VARCHAR(50) PRIMARY KEY,
    gender CHAR(1),
    dob DATE,
    essn INT,
    CONSTRAINT fk_dependent_employee FOREIGN KEY (essn) REFERENCES Employee(ssn)
        ON DELETE CASCADE
);
CREATE TABLE Project (
    pnum INT PRIMARY KEY,
    pname VARCHAR(50),
    location VARCHAR(50),
    dnum INT,
    CONSTRAINT fk_project_department FOREIGN KEY (dnum) REFERENCES Department(dnum)
);
CREATE TABLE Work (
    essn INT,
    pnum INT,
    workingHours DECIMAL(5,2),
    PRIMARY KEY (essn, pnum),
    CONSTRAINT fk_work_employee FOREIGN KEY (essn) REFERENCES Employee(ssn),
    CONSTRAINT fk_work_project FOREIGN KEY (pnum) REFERENCES Project(pnum)
);
--ADD FOREIGN KEY managerID IN Department TABLE
ALTER TABLE Department
ADD CONSTRAINT fk_manager FOREIGN KEY (managerID) REFERENCES Employee(ssn);
--INSERT DATA INTO TABLES
INSERT INTO Department (dnum, dname, location, managerID, managerHiringDate)
VALUES
(1, 'Engineering', 'Cairo', NULL, NULL),
(2, 'Marketing', 'Alexandria', NULL, NULL),
(3, 'HR', 'Giza', NULL, NULL);
INSERT INTO Employee (ssn, gender, dob, fname, lname, dnum, supervisor_ssn)
VALUES
(101, 'M', '1980-05-15', 'Ahmed', 'Zaki', 1, NULL),        
(102, 'F', '1990-08-22', 'Sara', 'Nabil', 1, 101),
(103, 'M', '1985-12-10', 'Omar', 'Hassan', 2, NULL),       
(104, 'F', '1992-03-18', 'Laila', 'Kamal', 2, 103),
(105, 'M', '1988-07-30', 'Mostafa', 'Ali', 3, NULL);       
INSERT INTO Dependent (name, gender, dob, essn)
VALUES
('Mona Zaki', 'F', '2010-04-12', 101),
('Youssef Ahmed', 'M', '2015-09-20', 101),
('Leila Omar', 'F', '2018-01-01', 103),
('Samir Omar', 'M', '2020-06-30', 103),
('Nada Mostafa', 'F', '2016-11-15', 105);
INSERT INTO Project (pnum, pname, location, dnum)
VALUES
(201, 'Website Redesign', 'Cairo', 1),    
(202, 'Ad Campaign', 'Alexandria', 2),    
(203, 'Employee Training', 'Giza', 3);    
INSERT INTO Work (essn, pnum, workingHours)
VALUES
(101, 201, 20.0),    
(102, 201, 35.0),    
(103, 202, 25.0),    
(104, 202, 30.0),    
(105, 203, 40.0),    
(102, 203, 10.0);    




UPDATE Department SET managerID = 101 WHERE dnum = 1;
UPDATE Department SET managerID = 103 WHERE dnum = 2;
UPDATE Department SET managerID = 105 WHERE dnum = 3;

UPDATE Department SET managerHiringDate = '2015-01-10' WHERE managerID = 101;
UPDATE Department SET managerHiringDate = '2017-05-01' WHERE managerID = 103;
UPDATE Department SET managerHiringDate = '2018-11-23' WHERE managerID = 105;

--DML
SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM Dependent;
--UPDATE Employee Department
UPDATE Employee SET dnum = 3 WHERE ssn = 101;

--DELETE A Dependent RECORD
DELETE FROM Dependent
WHERE essn = 101;

--RETRIVE ALL EMPLOYEES WORKING ON A SPECIFIC DEPARTMENT
SELECT * FROM Employee
WHERE dnum = 3;
--FIND ALL EMPLOYEES AND ALL THERE WORKING PROJECTS WITH WORKING HOURS
SELECT * FROM Work;