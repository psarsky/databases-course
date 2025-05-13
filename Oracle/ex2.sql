-- Definicja typu uczestnika wycieczki
CREATE OR REPLACE TYPE trip_participants AS OBJECT
(
    reservation_id int,
    person_id      int,
    firstname      varchar(50),
    lastname       varchar(50),
    status         char(1),
    no_tickets     int
);

CREATE OR REPLACE TYPE trip_participants_table IS TABLE OF trip_participants;

-- f_trip_participants - zwraca listę uczestników wskazanej wycieczki
CREATE OR REPLACE FUNCTION f_trip_participants(trip_id int)
    RETURN trip_participants_table
AS
    result trip_participants_table;
    valid  int;
BEGIN
    SELECT COUNT(*)
    INTO valid
    FROM trip t
    WHERE t.trip_id = f_trip_participants.trip_id;

    IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid trip ID');
    END IF;

    SELECT trip_participants(r.reservation_id, r.person_id, p.firstname, p.lastname, r.status,
                             r.no_tickets) BULK COLLECT
    INTO result
    FROM reservation r
             INNER JOIN person p ON r.person_id = p.person_id
    WHERE r.trip_id = f_trip_participants.trip_id
      AND r.status = 'P';
    RETURN result;
END;


-- Definicja typu rezerwacji
CREATE OR REPLACE TYPE reservation_type AS OBJECT
(
    reservation_id int,
    trip_name      varchar(100),
    status         char(1),
    no_tickets     int
);

CREATE OR REPLACE TYPE reservation_table IS TABLE OF reservation_type;

-- f_person_reservations - zwraca listę rezerwacji danej osoby
CREATE OR REPLACE FUNCTION f_person_reservations(person_id int)
    RETURN reservation_table
AS
    result reservation_table;
    valid  int;
BEGIN
    SELECT COUNT(*)
    INTO valid
    FROM person p
    WHERE p.person_id = f_person_reservations.person_id;

    IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid person ID');
    END IF;

    SELECT reservation_type(r.reservation_id, t.trip_name, r.status, r.no_tickets) BULK COLLECT
    INTO result
    FROM reservation r
             INNER JOIN trip t ON r.trip_id = t.trip_id
    WHERE r.person_id = f_person_reservations.person_id;
    RETURN result;
END;


-- Definicja typu wycieczki
CREATE OR REPLACE TYPE trip_type AS OBJECT
(
    trip_id             int,
    country             varchar(50),
    trip_date           date,
    trip_name           varchar(100),
    no_available_places int
);

CREATE OR REPLACE TYPE trip_table IS TABLE OF trip_type;

-- f_available_trips_to - zwraca listę wycieczek do wskazanego kraju dostępnych w zadanym okresie
CREATE OR REPLACE FUNCTION f_available_trips_to(country varchar, date_from date, date_to date)
    RETURN trip_table
AS
    result trip_table;
    valid  int;
BEGIN
    SELECT COUNT(*)
    INTO valid
    FROM trip t
    WHERE t.country = f_available_trips_to.country;

    IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid country name');
    END IF;

    SELECT trip_type(v.trip_id, v.country, v.trip_date, v.trip_name, v.no_available_places) BULK COLLECT
    INTO result
    FROM vw_trip v
    WHERE v.no_available_places > 0
      AND v.country = f_available_trips_to.country
      AND v.trip_date BETWEEN date_from AND date_to;
    RETURN result;
END;