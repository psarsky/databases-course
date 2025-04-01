CREATE OR REPLACE TRIGGER trg_add_reservation
AFTER INSERT ON RESERVATION
FOR EACH ROW
DECLARE
    v_log_id NUMBER;
    v_log_date DATE;
BEGIN
    SELECT s_log_seq.NEXTVAL, SYSDATE INTO v_log_id, v_log_date FROM dual;
    INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
    VALUES (v_log_id, :NEW.RESERVATION_ID, v_log_date, :NEW.STATUS, :NEW.NO_TICKETS);
END;
/

CREATE OR REPLACE TRIGGER trg_modify_reservation_status
AFTER UPDATE OF STATUS ON RESERVATION
FOR EACH ROW
DECLARE
    v_log_id NUMBER;
    v_log_date DATE;
BEGIN
    IF :OLD.STATUS != :NEW.STATUS THEN
        SELECT s_log_seq.NEXTVAL, SYSDATE INTO v_log_id, v_log_date FROM dual;
        INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
        VALUES (v_log_id, :NEW.RESERVATION_ID, v_log_date, :NEW.STATUS, :NEW.NO_TICKETS);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_modify_reservation_tickets
AFTER UPDATE OF NO_TICKETS ON RESERVATION
FOR EACH ROW
DECLARE
    v_log_id NUMBER;
    v_log_date DATE;
BEGIN
    IF :OLD.NO_TICKETS != :NEW.NO_TICKETS THEN
        SELECT s_log_seq.NEXTVAL, SYSDATE INTO v_log_id, v_log_date FROM dual;
        INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
        VALUES (v_log_id, :NEW.RESERVATION_ID, v_log_date, :NEW.STATUS, :NEW.NO_TICKETS);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_prevent_delete_reservation
BEFORE DELETE ON RESERVATION
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Nie można usunąć rezerwacji!');
END;
____________________________________________________
CREATE OR REPLACE PROCEDURE p_add_reservation_4(
  trip_id IN INT,
  person_id IN INT,
  no_tickets IN INT,
  status IN CHAR
)
IS
  v_reservation_id NUMBER;
  v_total_tickets NUMBER;
  v_max_tickets NUMBER;
  v_trip_date DATE;
  v_trip_exist NUMBER;
BEGIN
  -- Pobranie nowego ID z sekwencji
  SELECT s_reservation_seq.NEXTVAL INTO v_reservation_id FROM dual;

  -- Sprawdzenie, czy wycieczka istnieje
  SELECT COUNT(*) INTO v_trip_exist FROM TRIP WHERE TRIP_ID = p_add_reservation_4.trip_id;

  IF v_trip_exist = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Błąd: Wycieczka o podanym ID nie istnieje!');
  END IF;

  -- Pobranie sumy już zarezerwowanych biletów
  SELECT COALESCE(SUM(NO_TICKETS), 0)
  INTO v_total_tickets
  FROM TABLE(f_trip_participants(trip_id));

  -- Pobranie maksymalnej liczby miejsc i daty wycieczki
  SELECT MAX_NO_PLACES, trip_date
  INTO v_max_tickets, v_trip_date
  FROM TRIP
  WHERE TRIP_ID = p_add_reservation_4.trip_id;

  -- Sprawdzenie, czy wycieczka jest w przyszłości
  IF v_trip_date < SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20002, 'Błąd: Nie można rezerwować na przeszłą wycieczkę!');
  END IF;

  -- Sprawdzenie, czy są wolne miejsca
  IF v_total_tickets + no_tickets > v_max_tickets THEN
    RAISE_APPLICATION_ERROR(-20003, 'Błąd: Brak miejsc na wycieczkę!');
  END IF;

  -- Dodanie rezerwacji
  INSERT INTO RESERVATION (reservation_id, trip_id, person_id, no_tickets, status)
  VALUES (v_reservation_id, trip_id, person_id, no_tickets, status);

  -- **Brak ręcznego logowania - obsłuży to trigger**

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,SQLERRM);
END;
_________________________________________________________________
CREATE OR REPLACE PROCEDURE p_modify_reservation_status_4(
    reservation_id IN INT,
    status IN CHAR
)
IS
    v_total_tickets NUMBER;
    v_max_tickets NUMBER;
    v_trip_date DATE;
    v_no_tickets NUMBER;
    v_status CHAR(1);
    v_trip_id NUMBER;
BEGIN
    --Pobranie trip_id
    SELECT RESERVATION.TRIP_ID
    INTO v_trip_id
    FROM RESERVATION
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_status_4.reservation_id;

    -- Pobranie liczby miejsc i statusu rezerwacji
    SELECT NO_TICKETS, RESERVATION.STATUS
    INTO v_no_tickets, v_status
    FROM RESERVATION
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_status_4.reservation_id;

    -- Pobranie sumy już zarezerwowanych biletów
    SELECT COALESCE(SUM(NO_TICKETS), 0)
    INTO v_total_tickets
    FROM TABLE(f_trip_participants(v_trip_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT MAX_NO_PLACES, trip_date
    INTO v_max_tickets, v_trip_date
    FROM TRIP
    JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_status_4.reservation_id;

    -- Sprawdzenie poprawności statusu
    IF p_modify_reservation_status_4.status NOT IN ('C', 'P', 'N') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Błąd: Niepoprawny status!');
    END IF;

    -- Sprawdzenie warunków dla anulowania rezerwacji
    IF p_modify_reservation_status_4.status = 'C' THEN
        IF v_trip_date < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20002, 'Błąd: Nie można zmieniać rezerwacji na przeszłą wycieczkę!');
        END IF;

        IF v_total_tickets + v_no_tickets > v_max_tickets THEN
            RAISE_APPLICATION_ERROR(-20003, 'Błąd: Brak miejsc na wycieczkę!');
        END IF;
    END IF;

    -- Aktualizacja statusu
    UPDATE RESERVATION
    SET STATUS = p_modify_reservation_status_4.status
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_status_4.reservation_id;

    -- **Brak ręcznego logowania - obsłuży to trigger**

    COMMIT;
    RETURN;
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,SQLERRM);
END;
_________________________________________________________________________________
CREATE OR REPLACE PROCEDURE p_modify_reservation_4(
    reservation_id IN INT,
    no_tickets IN INT
)
IS
    v_total_tickets NUMBER; -- Suma już zarezerwowanych biletów
    v_max_tickets NUMBER; -- Maksymalna liczba miejsc na wycieczkę
    v_trip_date DATE;
    v_no_tickets NUMBER;
    v_trip_id NUMBER;
BEGIN
    --Pobranie trip_id
    SELECT RESERVATION.TRIP_ID
    INTO v_trip_id
    FROM RESERVATION
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_4.reservation_id;

    -- Pobranie liczby miejsc
    SELECT RESERVATION.NO_TICKETS
    INTO v_no_tickets
    FROM RESERVATION
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_4.reservation_id;

    -- Pobranie sumy już zarezerwowanych biletów
    SELECT COALESCE(SUM(NO_TICKETS), 0)
    INTO v_total_tickets
    FROM TABLE(f_trip_participants(v_trip_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT MAX_NO_PLACES, trip_date
    INTO v_max_tickets, v_trip_date
    FROM TRIP
    JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_4.reservation_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: Nie można zmieniać rezerwacji na przeszłą wycieczkę!');
    END IF;

    IF (no_tickets - v_no_tickets + v_total_tickets) > v_max_tickets THEN
        RAISE_APPLICATION_ERROR(-20003, 'Błąd: Brak wystarczającej liczby miejsc na wycieczkę!');
    END IF;

    -- Aktualizacja liczby miejsc w rezerwacji
    UPDATE RESERVATION
    SET NO_TICKETS = p_modify_reservation_4.no_tickets
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_4.reservation_id;

    COMMIT;
    RETURN;
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,SQLERRM);
END;
/
