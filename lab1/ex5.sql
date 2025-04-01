CREATE OR REPLACE TRIGGER tr_check_availability
    AFTER INSERT OR UPDATE
    ON RESERVATION
    FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_total_tickets NUMBER;
    v_max_tickets   NUMBER;
BEGIN
    -- Pobranie maksymalnej liczby miejsc na wycieczkę
    SELECT t.MAX_NO_PLACES
    INTO v_max_tickets
    FROM TRIP t
    WHERE TRIP_ID = :NEW.TRIP_ID;

    -- Pobranie liczby już zarezerwowanych miejsc (bez aktualnej rezerwacji)
    SELECT COALESCE(SUM(NO_TICKETS), 0)
    INTO v_total_tickets
    FROM RESERVATION
    WHERE TRIP_ID = :NEW.TRIP_ID;

    -- Sprawdzenie dostępności miejsc
    IF v_total_tickets > v_max_tickets THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Brak miejsc na wycieczkę!');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER tr_log_reservation
    AFTER INSERT
    ON RESERVATION
    FOR EACH ROW
BEGIN
    -- Wstawienie loga
    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
    VALUES (:NEW.RESERVATION_ID, SYSDATE, :NEW.STATUS, :NEW.NO_TICKETS);
END;
/

CREATE OR REPLACE TRIGGER tr_update_ticket_count
    BEFORE UPDATE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    -- Jeśli ktoś zmienia liczbę biletów, sprawdź dostępność
    IF :NEW.NO_TICKETS <> :OLD.NO_TICKETS THEN
        DECLARE
            v_total_tickets NUMBER;
            v_max_tickets   NUMBER;
        BEGIN
            -- Pobranie maksymalnej liczby miejsc
            SELECT MAX_NO_PLACES
            INTO v_max_tickets
            FROM TRIP
            WHERE TRIP_ID = :NEW.TRIP_ID;

            -- Pobranie liczby już zarezerwowanych miejsc
            SELECT COALESCE(SUM(NO_TICKETS), 0)
            INTO v_total_tickets
            FROM RESERVATION
            WHERE TRIP_ID = :NEW.TRIP_ID
              AND RESERVATION_ID <> :NEW.RESERVATION_ID;

            -- Sprawdzenie dostępności miejsc
            IF v_total_tickets + :NEW.NO_TICKETS > v_max_tickets THEN
                RAISE_APPLICATION_ERROR(-20002, 'Nie można zmienić liczby biletów - brak miejsc!');
            END IF;
        END;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE p_add_reservation_5(
    trip_id IN INT,
    person_id IN INT,
    no_tickets IN INT,
    status IN CHAR
)
    IS
BEGIN
    -- Wstawienie rezerwacji (sprawdzenie miejsc zrobi trigger)
    INSERT INTO RESERVATION (TRIP_ID, PERSON_ID, STATUS, NO_TICKETS)
    VALUES (p_add_reservation_5.trip_id, p_add_reservation_5.person_id, p_add_reservation_5.status,
            p_add_reservation_5.no_tickets);
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_5(
    reservation_id IN INT,
    status IN CHAR
)
    IS
BEGIN
    -- Aktualizacja statusu (trigger sprawdzi poprawność zmiany)
    UPDATE RESERVATION
    SET STATUS = p_modify_reservation_status_5.status
    WHERE RESERVATION_ID = p_modify_reservation_status_5.reservation_id;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE p_modify_reservation_5(
    reservation_id IN INT,
    no_tickets IN INT
)
    IS
BEGIN
    -- Aktualizacja liczby miejsc w rezerwacji (walidacja miejsc będzie w triggerze)
    UPDATE RESERVATION
    SET NO_TICKETS = p_modify_reservation_5.no_tickets
    WHERE RESERVATION_ID = p_modify_reservation_5.reservation_id;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/
