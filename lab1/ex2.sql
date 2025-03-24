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


CREATE OR REPLACE FUNCTION f_trip_participants(trip_id int)
    RETURN trip_participants_table
AS
    result trip_participants_table;
BEGIN
--     IF f_trip_participants.trip_id NOT IN (SELECT t.trip_id FROM trip t) THEN
--         RAISE ...?;
--     END IF;
    SELECT trip_participants(r.reservation_id, r.person_id, p.firstname, p.lastname, r.status,
                             r.no_tickets) BULK COLLECT
    INTO result
    FROM reservation r
             INNER JOIN person p ON r.person_id = p.person_id
    WHERE r.trip_id = f_trip_participants.trip_id
      AND r.status = 'P';
    RETURN result;
END;