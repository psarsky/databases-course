-- 6
-- Widoki
CREATE OR REPLACE VIEW vw_trip_6 AS
SELECT trip_id,
       country,
       trip_date,
       trip_name,
       no_available_places
FROM trip;

CREATE OR REPLACE VIEW vw_available_trip_6 AS
SELECT *
FROM vw_trip_6
WHERE no_available_places > 0
  AND TRIP_DATE > SYSDATE;


-- Funkcje
CREATE OR REPLACE FUNCTION f_available_trips_to_6(country varchar, date_from date, date_to date)
    RETURN trip_table
AS
    result trip_table;
    valid  int;
BEGIN
    SELECT COUNT(*)
    INTO valid
    FROM trip t
    WHERE t.country = f_available_trips_to_6.country;

    IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid country name');
    END IF;

    SELECT trip_type(v.trip_id, v.country, v.trip_date, v.trip_name, v.no_available_places) BULK COLLECT
    INTO result
    FROM vw_trip_6 v
    WHERE v.no_available_places > 0
      AND v.country = f_available_trips_to_6.country
      AND v.trip_date BETWEEN date_from AND date_to;
    RETURN result;
END;


-- Procedury
CREATE PROCEDURE p_modify_max_no_places_6(
    trip_id IN int,
    max_no_places IN int
)
    IS
    v_total_tickets int;
    v_trip_date     date;
BEGIN
    SELECT t.max_no_places - t.no_available_places, trip_date
    INTO v_total_tickets, v_trip_date
    FROM trip t
    WHERE t.trip_id = p_modify_max_no_places_6.trip_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot modify a past trip');
    END IF;

    IF v_total_tickets > p_modify_max_no_places_6.max_no_places THEN
        RAISE_APPLICATION_ERROR(-20003, 'The amount of existing reservations exceeds the given new limit');
    END IF;

    UPDATE trip
    SET max_no_places = p_modify_max_no_places_6.max_no_places
    WHERE trip.trip_id = p_modify_max_no_places_6.trip_id;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/



-- 6a
CREATE OR REPLACE PROCEDURE p_add_reservation_6a(
    trip_id IN int,
    person_id IN int,
    no_tickets IN int,
    status IN char
)
    IS
    v_max_no_places int;
BEGIN
    SELECT no_available_places
    INTO v_max_no_places
    FROM trip t
    WHERE t.trip_id = p_add_reservation_6a.trip_id;

    IF v_max_no_places <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Trip fully booked');
    END IF;

    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS, NO_TICKETS)
    VALUES (p_add_reservation_6a.trip_id, p_add_reservation_6a.person_id, p_add_reservation_6a.status,
            p_add_reservation_6a.no_tickets);

    UPDATE trip SET no_available_places = v_max_no_places - 1 WHERE trip_id = p_add_reservation_6a.trip_id;

    RETURN;
END;
/

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_6a(
    reservation_id IN int,
    status IN char
) IS
    v_status  char(1);
    v_trip_id int;
BEGIN

    SELECT r.status, r.trip_id
    INTO v_status, v_trip_id
    FROM reservation r
    WHERE r.reservation_id = p_modify_reservation_status_6a.reservation_id;

    IF v_status = 'C' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot modify a cancelled reservation');
    ELSIF v_status IN ('N', 'P') AND p_modify_reservation_status_6a.status = 'C' THEN
        UPDATE trip SET no_available_places = no_available_places + 1 WHERE trip_id = v_trip_id;
    END IF;

    UPDATE reservation
    SET status = p_modify_reservation_status_6a.status
    WHERE reservation_id = p_modify_reservation_status_6a.reservation_id;

    RETURN;
END;
/

CREATE OR REPLACE PROCEDURE p_modify_reservation_6a(
    reservation_id IN INT,
    no_tickets IN INT
)
    IS
    v_ticket_diff   int;
    v_max_no_places int;
    v_trip_id       int;
BEGIN
    SELECT t.no_available_places, p_modify_reservation_6a.no_tickets - r.no_tickets, t.trip_id
    INTO v_max_no_places, v_ticket_diff, v_trip_id
    FROM reservation r
             JOIN trip t
                  ON r.trip_id = t.trip_id
    WHERE r.reservation_id = p_modify_reservation_6a.reservation_id;

    IF v_ticket_diff > v_max_no_places THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough available places');
    END IF;

    UPDATE RESERVATION
    SET NO_TICKETS = p_modify_reservation_6a.no_tickets
    WHERE RESERVATION_ID = p_modify_reservation_6a.reservation_id;

    UPDATE trip
    SET no_available_places = no_available_places - v_ticket_diff
    WHERE trip_id = v_trip_id;

    RETURN;
END;
/

ALTER TRIGGER tr_add_reservation_6b DISABLE;
ALTER TRIGGER tr_modify_reservation_tickets_6b DISABLE;
ALTER TRIGGER tr_modify_reservation_status_6b DISABLE;


-- 6b
-- Trigger obsługujący dodanie rezerwacji
CREATE OR REPLACE TRIGGER tr_add_reservation_6b
    BEFORE INSERT
    ON reservation
    FOR EACH ROW
DECLARE
    v_max_no_places int;
BEGIN
    SELECT no_available_places INTO v_max_no_places FROM trip WHERE trip_id = :new.trip_id;

    IF v_max_no_places <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Trip fully booked');
    END IF;

    UPDATE trip SET no_available_places = no_available_places - 1 WHERE trip_id = :new.trip_id;
END;
/

-- Trigger obsługujący zmianę statusu
CREATE OR REPLACE TRIGGER tr_modify_reservation_status_6b
    BEFORE UPDATE OF status
    ON reservation
    FOR EACH ROW
BEGIN
    IF :old.status = 'C' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot modify a cancelled reservation');
    ELSIF :old.status IN ('N', 'P') AND :new.status = 'C' THEN
        UPDATE trip SET no_available_places = no_available_places + 1 WHERE trip_id = :new.trip_id;
    END IF;
END;
/

-- Trigger obsługujący zmianę ilości biletów w rezerwacji
CREATE OR REPLACE TRIGGER tr_modify_reservation_tickets_6b
    AFTER UPDATE OF no_tickets
    ON reservation
    FOR EACH ROW
DECLARE
    v_ticket_diff   int;
    v_max_no_places int;
BEGIN
    SELECT no_available_places INTO v_max_no_places FROM trip WHERE trip_id = :new.trip_id;

    SELECT :new.no_tickets - :old.no_tickets
    INTO v_ticket_diff
    FROM reservation
    WHERE trip_id = :new.trip_id;

    IF v_ticket_diff > v_max_no_places THEN
        RAISE_APPLICATION_ERROR(-20001, 'Not enough available places');
    END IF;

    UPDATE trip
    SET no_available_places = no_available_places - v_ticket_diff
    WHERE trip_id = :new.trip_id;
END;
/
