-- person

CREATE SEQUENCE s_person_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE person
(
    person_id int NOT NULL
        CONSTRAINT pk_person
            PRIMARY KEY,
    firstname varchar(50),
    lastname  varchar(50)
);

ALTER TABLE person
    MODIFY person_id INT DEFAULT s_person_seq.nextval;

-- trip

CREATE SEQUENCE s_trip_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE trip
(
    trip_id       int NOT NULL
        CONSTRAINT pk_trip
            PRIMARY KEY,
    trip_name     varchar(100),
    country       varchar(50),
    trip_date     date,
    max_no_places int
);

ALTER TABLE trip
    MODIFY trip_id INT DEFAULT s_trip_seq.nextval;

-- reservation

CREATE SEQUENCE s_reservation_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE reservation
(
    reservation_id int NOT NULL
        CONSTRAINT pk_reservation
            PRIMARY KEY,
    trip_id        int,
    person_id      int,
    status         char(1)
);

ALTER TABLE reservation
    MODIFY reservation_id INT DEFAULT s_reservation_seq.nextval;


ALTER TABLE reservation
    ADD CONSTRAINT reservation_fk1 FOREIGN KEY
        (person_id) REFERENCES person (person_id);

ALTER TABLE reservation
    ADD CONSTRAINT reservation_fk2 FOREIGN KEY
        (trip_id) REFERENCES trip (trip_id);

ALTER TABLE reservation
    ADD CONSTRAINT reservation_chk1 CHECK
        (status IN ('N', 'P', 'C'));

-- log

CREATE SEQUENCE s_log_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE log
(
    log_id         int  NOT NULL
        CONSTRAINT pk_log
            PRIMARY KEY,
    reservation_id int  NOT NULL,
    log_date       date NOT NULL,
    status         char(1)
);

ALTER TABLE log
    MODIFY log_id INT DEFAULT s_log_seq.nextval;

ALTER TABLE log
    ADD CONSTRAINT log_chk1 CHECK
        (status IN ('N', 'P', 'C'))
        enable;

ALTER TABLE log
    ADD CONSTRAINT log_fk1 FOREIGN KEY
        (reservation_id) REFERENCES reservation (reservation_id);
