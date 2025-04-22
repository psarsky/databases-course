CREATE OR REPLACE TRIGGER trg_add_reservation
    AFTER INSERT
    ON RESERVATION
    FOR EACH ROW
BEGIN
    INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
    VALUES (:NEW.RESERVATION_ID, SYSDATE, :NEW.STATUS, :NEW.NO_TICKETS);
END;
/


CREATE OR REPLACE TRIGGER trg_modify_reservation
    AFTER UPDATE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    IF :OLD.STATUS != :NEW.STATUS OR :OLD.NO_TICKETS != :NEW.NO_TICKETS THEN
        INSERT INTO LOG (RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
        VALUES (:NEW.RESERVATION_ID, SYSDATE, :NEW.STATUS, :NEW.NO_TICKETS);
    END IF;
END;
/


CREATE OR REPLACE TRIGGER trg_prevent_delete_reservation
    BEFORE DELETE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Nie można usunąć rezerwacji!');
END;
/


CREATE OR REPLACE PROCEDURE p_add_reservation_4(
    trip_id IN int,
    person_id IN int,
    no_tickets IN int,
    status IN char
)
    IS
    v_total_tickets int; -- Suma już zarezerwowanych biletów
    v_max_tickets   int; -- Maksymalna liczba miejsc na wycieczkę
    v_trip_date     date; -- Data wycieczki
    v_log_date      date; -- Data log-a
    v_trip_exist    int; -- Czy wycieczka istnieje
    v_error_message varchar2(4000); -- Komunikat błędu
BEGIN
    v_log_date := SYSDATE;

    -- Sprawdzenie, czy wycieczka istnieje
    SELECT COUNT(*)
    INTO v_trip_exist
    FROM trip
    WHERE trip.trip_id = p_add_reservation_4.trip_id;

    IF v_trip_exist = 0 THEN
        v_error_message := 'Invalid trip ID';
        GOTO error_log;
    END IF;

    -- Pobranie sumy już zarezerwowanych biletów
    SELECT COALESCE(SUM(no_tickets), 0)
    INTO v_total_tickets
    FROM TABLE (f_trip_participants(trip_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT max_no_places, trip_date
    INTO v_max_tickets, v_trip_date
    FROM trip
    WHERE trip.trip_id = p_add_reservation_4.trip_id;

    -- Sprawdzenie, czy wycieczka jest w przyszłości
    IF v_trip_date < v_log_date THEN
        v_error_message := 'Cannot add a reservation for a past trip';
        GOTO error_log;
    END IF;

    -- Sprawdzenie, czy są wolne miejsca
    IF v_total_tickets + no_tickets > v_max_tickets THEN
        v_error_message := 'Trip fully booked';
        GOTO error_log;
    END IF;

    -- Dodanie rezerwacji do tabeli
    INSERT INTO reservation (trip_id, person_id, no_tickets, status)
    VALUES (p_add_reservation_4.trip_id, p_add_reservation_4.person_id, p_add_reservation_4.no_tickets,
            p_add_reservation_4.status);

    -- **Brak ręcznego logowania - obsłuży to trigger**

    RETURN;

    --  Sekcja logowania błędu
    <<error_log>>
    INSERT
    INTO LOG (reservation_id, log_date, status, no_tickets)
    VALUES (S_RESERVATION_SEQ.nextval, v_log_date, 'E', no_tickets);

    RAISE_APPLICATION_ERROR(-20000, v_error_message);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);

END;


CREATE OR REPLACE PROCEDURE p_modify_reservation_status_4(
    reservation_id IN int,
    status IN char
)
    IS
    v_trip_date  date;
    v_no_tickets int;
    valid        int;
BEGIN
    -- Sprawdzenie podanego ID
    SELECT COUNT(*)
    INTO valid
    FROM reservation r
    WHERE r.reservation_id = p_modify_reservation_status_4.reservation_id;

    IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid reservation ID');
    END IF;

    -- Pobranie liczby miejsc i statusu rezerwacji
    SELECT r.no_tickets
    INTO v_no_tickets
    FROM reservation r
    WHERE r.reservation_id = p_modify_reservation_status_4.reservation_id;

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT trip_date
    INTO v_trip_date
    FROM trip
             JOIN reservation ON trip.trip_id = reservation.trip_id
    WHERE reservation.reservation_id = p_modify_reservation_status_4.reservation_id;

    -- Sprawdzenie poprawności statusu
    IF p_modify_reservation_status_4.status NOT IN ('C', 'P', 'N') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid status');
    END IF;

    -- Sprawdzenie warunków dla anulowania rezerwacji
    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cannot modify a past reservation');
    END IF;

    -- Aktualizacja statusu
    UPDATE reservation
    SET status = p_modify_reservation_status_4.status
    WHERE reservation_id = p_modify_reservation_status_4.reservation_id;

    -- **Brak ręcznego logowania - obsłuży to trigger**

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;


CREATE OR REPLACE PROCEDURE p_modify_reservation_4(
    reservation_id IN int,
    no_tickets IN int
)
    IS
    v_total_tickets int; -- Suma już zarezerwowanych biletów
    v_max_tickets   int; -- Maksymalna liczba miejsc na wycieczkę
    v_trip_date     date;
    v_no_tickets    int;
    v_status        char(1);
    v_trip_id       int;
BEGIN
    --Pobranie trip_id, liczby miejsc i statusu
    SELECT r.trip_id, r.no_tickets, r.status
    INTO v_trip_id, v_no_tickets, v_status
    FROM reservation r
    WHERE r.reservation_id = p_modify_reservation_4.reservation_id;

    -- Pobranie sumy już zarezerwowanych miejsc
    SELECT COALESCE(SUM(no_tickets), 0)
    INTO v_total_tickets
    FROM TABLE (f_trip_participants(v_trip_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT t.max_no_places, t.trip_date
    INTO v_max_tickets, v_trip_date
    FROM trip t
             JOIN reservation r ON t.trip_id = r.trip_id
    WHERE r.reservation_id = p_modify_reservation_4.reservation_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot modify a past reservation!');
    END IF;

    IF (p_modify_reservation_4.no_tickets - v_no_tickets + v_total_tickets) > v_max_tickets THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trip fully booked');
    END IF;

    -- Aktualizacja statusu
    UPDATE reservation
    SET no_tickets = p_modify_reservation_4.no_tickets
    WHERE reservation_id = p_modify_reservation_4.reservation_id;

    -- **Brak ręcznego logowania - obsłuży to trigger**

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
