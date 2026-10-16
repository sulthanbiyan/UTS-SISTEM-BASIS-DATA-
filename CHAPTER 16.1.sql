DROP TABLE IF EXISTS Advert CASCADE;
DROP TABLE IF EXISTS Newspaper CASCADE;
DROP TABLE IF EXISTS Viewing CASCADE;
DROP TABLE IF EXISTS Lease CASCADE;
DROP TABLE IF EXISTS PropertyForRent CASCADE;
DROP TABLE IF EXISTS BusinessOwner CASCADE;
DROP TABLE IF EXISTS PrivateOwner CASCADE;
DROP TABLE IF EXISTS Registration CASCADE;
DROP TABLE IF EXISTS Client CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Telephone CASCADE;
DROP TABLE IF EXISTS Branch CASCADE;


-- ---------------------------------------------------------
-- TAHAP 1: DDL SKEMA DREAMHOME (POSTGRESQL)
-- ---------------------------------------------------------

CREATE TABLE Branch (
    branchNo VARCHAR(5) NOT NULL,
    street   VARCHAR(50),
    city     VARCHAR(30),
    postcode VARCHAR(10),
    mgrStaffNo VARCHAR(5),
    CONSTRAINT pk_branch PRIMARY KEY (branchNo)
);

CREATE TABLE Telephone (
    telNo    VARCHAR(15) NOT NULL,
    branchNo VARCHAR(5)  NOT NULL,
    CONSTRAINT pk_telephone PRIMARY KEY (telNo),
    CONSTRAINT fk_telephone_branch FOREIGN KEY (branchNo)
        REFERENCES Branch (branchNo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Staff (
    staffNo           VARCHAR(5)   NOT NULL,
    fName             VARCHAR(30)  NOT NULL,
    lName             VARCHAR(30)  NOT NULL,
    position          VARCHAR(30),
    sex               CHAR(1),
    DOB               DATE,
    salary            DECIMAL(10,2),
    supervisorStaffNo VARCHAR(5),
    branchNo          VARCHAR(5)   NOT NULL,
    CONSTRAINT pk_staff PRIMARY KEY (staffNo),
    CONSTRAINT fk_staff_branch FOREIGN KEY (branchNo)
        REFERENCES Branch (branchNo) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_staff_supervisor FOREIGN KEY (supervisorStaffNo)
        REFERENCES Staff (staffNo) ON DELETE SET NULL ON UPDATE CASCADE
);

ALTER TABLE Branch 
    ADD CONSTRAINT fk_branch_mgrstaff FOREIGN KEY (mgrStaffNo)
        REFERENCES Staff (staffNo) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE Client (
    clientNo      VARCHAR(5)   NOT NULL,
    fName         VARCHAR(30)  NOT NULL,
    lName         VARCHAR(30)  NOT NULL,
    telNo         VARCHAR(15),
    prefType      VARCHAR(10),
    maxRent       DECIMAL(8,2),
    email         VARCHAR(50),
    CONSTRAINT pk_client PRIMARY KEY (clientNo)
);

CREATE TABLE Registration (
    clientNo   VARCHAR(5) NOT NULL,
    branchNo   VARCHAR(5) NOT NULL,
    staffNo    VARCHAR(5) NOT NULL,
    dateJoined DATE       NOT NULL,
    CONSTRAINT pk_registration PRIMARY KEY (clientNo, branchNo),
    CONSTRAINT fk_reg_client FOREIGN KEY (clientNo)
        REFERENCES Client (clientNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reg_branch FOREIGN KEY (branchNo)
        REFERENCES Branch (branchNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reg_staff FOREIGN KEY (staffNo)
        REFERENCES Staff (staffNo) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE PrivateOwner (
    ownerNo VARCHAR(5)   NOT NULL,
    fName   VARCHAR(30)  NOT NULL,
    lName   VARCHAR(30)  NOT NULL,
    address VARCHAR(100) NOT NULL,
    telNo   VARCHAR(15),
    email   VARCHAR(50),
    CONSTRAINT pk_privateowner PRIMARY KEY (ownerNo)
);

CREATE TABLE BusinessOwner (
    ownerNo      VARCHAR(5)   NOT NULL,
    businessName VARCHAR(50)  NOT NULL,
    businessType VARCHAR(30),
    address      VARCHAR(100) NOT NULL,
    telNo        VARCHAR(15),
    contactName  VARCHAR(50),
    CONSTRAINT pk_businessowner PRIMARY KEY (ownerNo)
);

CREATE TABLE PropertyForRent (
    propertyNo VARCHAR(5)    NOT NULL,
    street     VARCHAR(50)   NOT NULL,
    city       VARCHAR(30)   NOT NULL,
    postcode   VARCHAR(10),
    type       VARCHAR(10)   NOT NULL,
    rooms      INT           NOT NULL,
    rent       DECIMAL(8,2)  NOT NULL,
    ownerNo    VARCHAR(5)    NOT NULL,
    staffNo    VARCHAR(5),
    branchNo   VARCHAR(5)    NOT NULL,
    CONSTRAINT pk_propertyforrent PRIMARY KEY (propertyNo),
    CONSTRAINT fk_pfr_branch FOREIGN KEY (branchNo)
        REFERENCES Branch (branchNo) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pfr_staff FOREIGN KEY (staffNo)
        REFERENCES Staff (staffNo) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Lease (
    leaseNo       VARCHAR(5)   NOT NULL,
    clientNo      VARCHAR(5)   NOT NULL,
    propertyNo    VARCHAR(5)   NOT NULL,
    paymentMethod VARCHAR(15),
    deposit       DECIMAL(8,2),
    paid          BOOLEAN      DEFAULT FALSE,
    rentStart     DATE         NOT NULL,
    rentFinish    DATE         NOT NULL,
    duration      INT,
    CONSTRAINT pk_lease PRIMARY KEY (leaseNo),
    CONSTRAINT fk_lease_client FOREIGN KEY (clientNo)
        REFERENCES Client (clientNo) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_lease_property FOREIGN KEY (propertyNo)
        REFERENCES PropertyForRent (propertyNo) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Viewing (
    clientNo   VARCHAR(5) NOT NULL,
    propertyNo VARCHAR(5) NOT NULL,
    viewDate   DATE       NOT NULL,
    comment    TEXT,
    CONSTRAINT pk_viewing PRIMARY KEY (clientNo, propertyNo, viewDate),
    CONSTRAINT fk_viewing_client FOREIGN KEY (clientNo)
        REFERENCES Client (clientNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_viewing_property FOREIGN KEY (propertyNo)
        REFERENCES PropertyForRent (propertyNo) ON DELETE CASCADE ON UPDATE CASCADE
);


-- ---------------------------------------------------------
-- TAHAP 2: INPUT DATA SAMPEL
-- ---------------------------------------------------------

INSERT INTO Branch (branchNo, street, city, postcode) VALUES 
('B003', '16 Argyll St', 'Glasgow', 'G11 5NW'),
('B005', '22 Deer Rd', 'London', 'SW1 4EH');

INSERT INTO Staff (staffNo, fName, lName, position, sex, DOB, salary, branchNo) VALUES 
('SL21', 'John', 'White', 'Manager', 'M', '1965-10-01', 30000.00, 'B003'),
('SG14', 'David', 'Ford', 'Deputy', 'M', '1958-03-24', 18000.00, 'B003');

INSERT INTO Client (clientNo, fName, lName, telNo, prefType, maxRent, email) VALUES 
('CR76', 'John', 'Kay', '0207-774-5632', 'Flat', 425.00, 'john.kay@gmail.com');

INSERT INTO PrivateOwner (ownerNo, fName, lName, address, telNo, email) VALUES 
('CO46', 'Joe', 'Keogh', '2 Ferguson Rd, Aberdeen', '01224-861212', 'jkeogh@gmail.com');

INSERT INTO PropertyForRent (propertyNo, street, city, postcode, type, rooms, rent, ownerNo, staffNo, branchNo) VALUES 
('PA14', '16 Holhead', 'Aberdeen', 'AB7 5SU', 'House', 6, 650.00, 'CO46', 'SL21', 'B003');

INSERT INTO Lease (leaseNo, clientNo, propertyNo, paymentMethod, deposit, paid, rentStart, rentFinish, duration) VALUES 
('L101', 'CR76', 'PA14', 'Visa', 500.00, TRUE, '2026-01-01', '2026-12-31', 12);


-- ---------------------------------------------------------
-- TAHAP 3: MENAMPILKAN HASIL AKHIR (JOIN ALL DATA)
-- ---------------------------------------------------------

SELECT 
    l.leaseNo,
    c.fName || ' ' || c.lName AS client_name,
    p.propertyNo,
    p.street || ', ' || p.city AS property_address,
    p.rent,
    b.branchNo,
    b.city AS branch_city,
    s.fName || ' ' || s.lName AS staff_name
FROM Lease l
JOIN Client c ON l.clientNo = c.clientNo
JOIN PropertyForRent p ON l.propertyNo = p.propertyNo
JOIN Branch b ON p.branchNo = b.branchNo
LEFT JOIN Staff s ON p.staffNo = s.staffNo;