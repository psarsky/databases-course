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

-- Wstawienie nowej rezerwacji
BEGIN
    INSERT INTO reservation (trip_id, person_id, status, no_tickets)
    VALUES (3, 3, 'N', 2);

    INSERT INTO log (reservation_id, log_date, status, no_tickets)
    VALUES (3, SYSDATE, 'N', 2);

    COMMIT;
END;

-- Wstawienie rezerwacji z symulowanym błędem i rollback
BEGIN
    INSERT INTO reservation (trip_id, person_id, status, no_tickets)
    VALUES (4, 2, 'N', 1);

    -- Symulacja błędu
    RAISE_APPLICATION_ERROR(-20001, 'Error');

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
-- Rezerwacja nie została dodana

BEGIN
    -- Modyfikacja istniejącej rezerwacji
    UPDATE reservation
    SET trip_id    = 4,
        person_id  = 4,
        status     = 'C',
        no_tickets = 5
    WHERE reservation_id = 11;

    -- Aktualizacja logów związanych z tą rezerwacją
    UPDATE log
    SET reservation_id = 11,
        log_date       = SYSDATE,
        status         = 'C',
        no_tickets     = 5
    WHERE log_id = 1;
    COMMIT;
END;

BEGIN
    -- Usunięcie wpisu w tabeli log
    DELETE
    FROM log
    WHERE reservation_id = 11;

    -- Usunięcie rezerwacji
    DELETE
    FROM reservation
    WHERE reservation_id = 11;

    COMMIT;
END;

-- Ustawienie odpowiednich wartości sekwencji dla reservation i log
ALTER SEQUENCE s_reservation_seq RESTART START WITH 11;
ALTER SEQUENCE s_log_seq RESTART START WITH 1;
