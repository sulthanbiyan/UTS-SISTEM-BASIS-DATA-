-- ============================================================
-- BAB 6: EXERCISES 6.10 & 6.11
-- Database: PostgreSQL
-- ============================================================

-- 1. Aktifkan modul btree_gist untuk mendukung constraint EXCLUDE (Overlap Date Check)
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 2. Bersihkan tabel jika sudah ada sebelumnya
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Room CASCADE;
DROP TABLE IF EXISTS Guest CASCADE;
DROP TABLE IF EXISTS Hotel CASCADE;

-- ------------------------------------------------------------
-- SOAL 6.10: Membuat Tabel Hotel
-- ------------------------------------------------------------
CREATE TABLE Hotel (
    hotelNo VARCHAR(10) NOT NULL,
    hotelName VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    CONSTRAINT pk_hotel PRIMARY KEY (hotelNo)
);

-- ------------------------------------------------------------
-- SOAL 6.11: Membuat Tabel Room, Guest, dan Booking
-- ------------------------------------------------------------

-- A. Tabel Room
CREATE TABLE Room (
    roomNo INT NOT NULL,
    hotelNo VARCHAR(10) NOT NULL,
    type VARCHAR(10) NOT NULL,
    price DECIMAL(7, 2) NOT NULL,
    CONSTRAINT pk_room PRIMARY KEY (roomNo, hotelNo),
    CONSTRAINT fk_room_hotel FOREIGN KEY (hotelNo) 
        REFERENCES Hotel(hotelNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_room_type CHECK (type IN ('Single', 'Double', 'Family')), -- (a) type
    CONSTRAINT chk_room_price CHECK (price BETWEEN 10.00 AND 100.00),       -- (b) price £10-£100
    CONSTRAINT chk_room_no CHECK (roomNo BETWEEN 1 AND 100)                  -- (c) roomNo 1-100
);

-- B. Tabel Guest
CREATE TABLE Guest (
    guestNo VARCHAR(10) NOT NULL,
    guestName VARCHAR(100) NOT NULL,
    guestAddress VARCHAR(200) NOT NULL,
    CONSTRAINT pk_guest PRIMARY KEY (guestNo)
);

-- C. Tabel Booking
CREATE TABLE Booking (
    hotelNo VARCHAR(10) NOT NULL,
    guestNo VARCHAR(10) NOT NULL,
    dateFrom DATE NOT NULL,
    dateTo DATE NOT NULL,
    roomNo INT NOT NULL,
    CONSTRAINT pk_booking PRIMARY KEY (hotelNo, guestNo, dateFrom),
    CONSTRAINT fk_booking_room FOREIGN KEY (roomNo, hotelNo) 
        REFERENCES Room(roomNo, hotelNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_booking_guest FOREIGN KEY (guestNo) 
        REFERENCES Guest(guestNo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_dates CHECK (dateTo > dateFrom),
    CONSTRAINT chk_date_from_future CHECK (dateFrom > CURRENT_DATE),        -- (d) dateFrom > today
    CONSTRAINT chk_date_to_future CHECK (dateTo > CURRENT_DATE),            -- (d) dateTo > today
    
    -- (e) Mencegah double-booking pada kamar dan hotel yang sama
    CONSTRAINT no_double_booking EXCLUDE USING gist (
        hotelNo WITH =,
        roomNo WITH =,
        daterange(dateFrom, dateTo, '[)') WITH &&
    ),
    
    -- (f) Mencegah jadwal menginap berbenturan untuk tamu yang sama
    CONSTRAINT no_guest_overlap EXCLUDE USING gist (
        guestNo WITH =,
        daterange(dateFrom, dateTo, '[)') WITH &&
    )
);

-- ============================================================
-- INSERT DATA SAMPEL (PENGUJIAN VALIDASI)
-- ============================================================

-- 1. Insert Data Sampel Hotel
INSERT INTO Hotel (hotelNo, hotelName, city) VALUES
('H01', 'Grosvenor Hotel', 'London'),
('H02', 'Grand Palace Hotel', 'Manchester'),
('H03', 'Ocean View Resort', 'Brighton');

-- 2. Insert Data Sampel Room
INSERT INTO Room (roomNo, hotelNo, type, price) VALUES
(1, 'H01', 'Single', 45.00),
(2, 'H01', 'Double', 75.00),
(10, 'H01', 'Family', 95.00),
(1, 'H02', 'Double', 80.00),
(50, 'H03', 'Family', 99.99);

-- 3. Insert Data Sampel Guest
INSERT INTO Guest (guestNo, guestName, guestAddress) VALUES
('G01', 'Ahmad Rizki', 'Jl. Sudirman No. 12, Jakarta'),
('G02', 'Siti Aminah', 'Jl. Murni No. 45, Bandung'),
('G03', 'Budi Santoso', 'Jl. Merdeka No. 88, Surabaya');

-- 4. Insert Data Sampel Booking (Tanggal Harus Lebih Besar Dari Hari Ini)
INSERT INTO Booking (hotelNo, guestNo, dateFrom, dateTo, roomNo) VALUES
('H01', 'G01', CURRENT_DATE + INTERVAL '5 days', CURRENT_DATE + INTERVAL '10 days', 1),
('H01', 'G02', CURRENT_DATE + INTERVAL '12 days', CURRENT_DATE + INTERVAL '15 days', 1),
('H02', 'G03', CURRENT_DATE + INTERVAL '3 days', CURRENT_DATE + INTERVAL '7 days', 1);

-- ============================================================
-- VERIFIKASI DAN TAMPILKAN SELURUH DATA (SELECT)
-- ============================================================

SELECT * FROM Hotel;
SELECT * FROM Room;
SELECT * FROM Guest;
SELECT * FROM Booking;