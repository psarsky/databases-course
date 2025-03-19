-- Dodanie pola no_tickets do reservation oraz log
ALTER TABLE reservation
    ADD no_tickets INT CHECK (no_tickets > 0);
ALTER TABLE log
    ADD no_tickets INT CHECK (no_tickets > 0);

-- Aktualizacja istniejących danych
BEGIN
    UPDATE reservation SET no_tickets = 1 WHERE reservation_id IS NOT NULL;
    UPDATE log SET no_tickets = 1 WHERE log_id IS NOT NULL;
    COMMIT;
END;

CREATE OR REPLACE VIEW vw_reservation AS
SELECT
    reservation_id, country, trip_date, trip_name, firstname, lastname, status, TRIP.trip_id, RESERVATION.person_id, no_tickets
FROM
    PERSON
    JOIN RESERVATION ON PERSON.PERSON_ID = RESERVATION.PERSON_ID
    JOIN TRIP ON RESERVATION.TRIP_ID = TRIP.TRIP_ID;

-- SELECT TRIP_ID, COUNT(*) AS COUNT
-- FROM RESERVATION
-- WHERE STATUS = 'N' OR STATUS = 'P'
-- GROUP BY TRIP_ID;


CREATE OR REPLACE VIEW vw_trip AS
SELECT TRIP.trip_id, country, trip_date, trip_name, (TRIP.MAX_NO_PLACES-W1.COUNT) no_available_places
FROM TRIP
JOIN (
    SELECT TRIP_ID, COUNT(*) AS COUNT
    FROM RESERVATION
    WHERE STATUS = 'N' OR STATUS = 'P'
    GROUP BY TRIP_ID) W1 ON TRIP.TRIP_ID = W1.TRIP_ID;

CREATE OR REPLACE VIEW vw_available_trip AS
SELECT TRIP.trip_id, country, trip_date, trip_name, (TRIP.MAX_NO_PLACES-W1.COUNT) no_available_places
FROM TRIP
JOIN (
    SELECT TRIP_ID, COUNT(*) AS COUNT
    FROM RESERVATION
    WHERE STATUS = 'N' OR STATUS = 'P'
    GROUP BY TRIP_ID) W1 ON TRIP.TRIP_ID = W1.TRIP_ID
WHERE TRIP.MAX_NO_PLACES-W1.COUNT > 0 AND TRIP_DATE > SYSDATE
