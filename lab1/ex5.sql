CREATE OR REPLACE TRIGGER tr_check_availability
    BEFORE INSERT
    ON RESERVATION
    FOR EACH ROW
DECLARE
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
    WHERE TRIP_ID = :NEW.TRIP_ID
      AND STATUS != 'C';

    -- Sprawdzenie dostępności miejsc
    IF v_total_tickets + :new.NO_TICKETS > v_max_tickets THEN
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
    FOR UPDATE
    ON RESERVATION
    COMPOUND TRIGGER

    -- Zmienna globalna (widoczna dla całego triggera)
    TYPE ReservationChange IS RECORD
                              (
                                  reservation_id int,
                                  trip_id        int,
                                  new_no_tickets int,
                                  old_no_tickets int
                              );

    TYPE ChangeTable IS TABLE OF ReservationChange INDEX BY PLS_INTEGER;
    changes ChangeTable;
    idx PLS_INTEGER := 0;

BEFORE EACH ROW IS
BEGIN
    IF :NEW.NO_TICKETS <> :OLD.NO_TICKETS THEN
        idx := idx + 1;
        changes(idx).reservation_id := :NEW.RESERVATION_ID;
        changes(idx).trip_id := :NEW.TRIP_ID;
        changes(idx).new_no_tickets := :NEW.NO_TICKETS;
        changes(idx).old_no_tickets := :OLD.NO_TICKETS;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS
    v_total_tickets NUMBER;
    v_max_tickets   NUMBER;
BEGIN
    FOR i IN 1 .. changes.COUNT
        LOOP
            SELECT MAX_NO_PLACES
            INTO v_max_tickets
            FROM TRIP
            WHERE TRIP_ID = changes(i).trip_id;

            SELECT COALESCE(SUM(NO_TICKETS), 0)
            INTO v_total_tickets
            FROM RESERVATION
            WHERE TRIP_ID = changes(i).trip_id
              AND RESERVATION_ID <> changes(i).reservation_id
              AND STATUS != 'C';

            IF v_total_tickets + changes(i).new_no_tickets > v_max_tickets THEN
                RAISE_APPLICATION_ERROR(-20002,
                                        'Nie można zmienić liczby biletów - brak miejsc!');
            END IF;
        END LOOP;
END AFTER STATEMENT;
END tr_update_ticket_count;
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
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
/
