CREATE OR REPLACE PROCEDURE p_add_reservation(
  trip_id IN INT,
  person_id IN INT,
  no_tickets IN INT,
  status IN CHAR
)
IS
  v_reservation_id NUMBER; -- ID rezerwacji
  v_log_id NUMBER; -- ID log-a
  v_total_tickets NUMBER;  -- Suma już zarezerwowanych biletów
  v_max_tickets NUMBER;    -- Maksymalna liczba miejsc na wycieczkę
  v_trip_date DATE;        -- Data wycieczki
  v_log_date DATE; -- Data log-a
  v_trip_exist NUMBER; -- Czy wycieczka istnieje
  v_error_message VARCHAR2(4000); -- Komunikat błędu
BEGIN
  -- Pobranie nowego ID z sekwencji
  SELECT s_reservation_seq.NEXTVAL INTO v_reservation_id FROM dual;
  SELECT s_log_seq.NEXTVAL INTO v_log_id FROM dual;
  SELECT SYSDATE INTO v_log_date FROM dual;

  -- Sprawdzenie, czy wycieczka istnieje
  SELECT COUNT(*) INTO v_trip_exist FROM TRIP WHERE trip.TRIP_ID = p_add_reservation.trip_id;

  IF v_trip_exist = 0 THEN
    v_error_message := 'Błąd: Wycieczka o podanym ID nie istnieje!';
    GOTO rollback_and_log;
  END IF;

  -- Pobranie sumy już zarezerwowanych biletów
  SELECT COALESCE(SUM(NO_TICKETS), 0)
  INTO v_total_tickets
  FROM TABLE(f_trip_participants(trip_id));

  -- Pobranie maksymalnej liczby miejsc i daty wycieczki
  SELECT MAX_NO_PLACES, trip_date
  INTO v_max_tickets, v_trip_date
  FROM trip
  WHERE trip.trip_id = p_add_reservation.trip_id;

  -- Sprawdzenie, czy wycieczka jest w przyszłości
  IF v_trip_date < SYSDATE THEN
    v_error_message := 'Błąd: Nie można rezerwować na przeszłą wycieczkę!';
    GOTO rollback_and_log;
  END IF;

  -- Sprawdzenie, czy są wolne miejsca
  IF v_total_tickets + no_tickets > v_max_tickets THEN
    v_error_message := 'Błąd: Brak miejsc na wycieczkę!';
    GOTO rollback_and_log;
  END IF;

  -- Dodanie rezerwacji do tabeli
  INSERT INTO RESERVATION (reservation_id, trip_id, person_id, no_tickets, status)
  VALUES (v_reservation_id, trip_id, person_id, no_tickets, status);

  -- Logowanie poprawnej rezerwacji
  INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
  VALUES (v_log_id, v_reservation_id, v_log_date, status, no_tickets);

  COMMIT;
  RETURN;

  --  Sekcja rollback i logowania błędu
  <<rollback_and_log>>
  ROLLBACK;
  INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
  VALUES (v_log_id, v_reservation_id, v_log_date, 'ERROR', no_tickets);

  RAISE_APPLICATION_ERROR(-20000, v_error_message);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
      RAISE_APPLICATION_ERROR(-20000, v_error_message);
END;
______________________________________________________________________________________________________________
CREATE OR REPLACE PROCEDURE p_modify_reservation_status(
    reservation_id IN INT,
    status IN CHAR
)
IS
    v_total_tickets NUMBER;
    v_max_tickets NUMBER;
    v_trip_date DATE;
    v_no_tickets NUMBER;
    v_status CHAR(1);
    v_log_id NUMBER;
    v_log_date DATE;
BEGIN
    -- Pobranie liczby miejsc i statusu rezerwacji
    SELECT NO_TICKETS, STATUS
    INTO v_no_tickets, v_status
    FROM RESERVATION
    WHERE RESERVATION_ID = p_modify_reservation_status.reservation_id;

    -- Pobranie sumy już zarezerwowanych biletów
    SELECT COALESCE(SUM(NO_TICKETS), 0)
    INTO v_total_tickets
    FROM TABLE(f_trip_participants(p_modify_reservation_status.reservation_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT MAX_NO_PLACES, trip_date
    INTO v_max_tickets, v_trip_date
    FROM TRIP
    JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation_status.reservation_id;

    -- Sprawdzenie poprawności statusu
    IF p_modify_reservation_status.status NOT IN ('C', 'P', 'N') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Błąd: Niepoprawny status!');
    END IF;

    -- Sprawdzenie warunków dla anulowania rezerwacji
    IF p_modify_reservation_status.status = 'C' THEN
        IF v_trip_date < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20002, 'Błąd: Nie można zmieniać rezerwacji na przeszłą wycieczkę!');
        END IF;

        IF v_total_tickets + v_no_tickets > v_max_tickets THEN
            RAISE_APPLICATION_ERROR(-20003, 'Błąd: Brak miejsc na wycieczkę!');
        END IF;
    END IF;

    -- Aktualizacja statusu
    UPDATE RESERVATION
    SET STATUS = p_modify_reservation_status.status
    WHERE RESERVATION_ID = p_modify_reservation_status.reservation_id;

    -- Dodanie wpisu do logów
    SELECT s_log_seq.NEXTVAL, SYSDATE INTO v_log_id, v_log_date FROM dual;
    INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
    VALUES (v_log_id, p_modify_reservation_status.reservation_id, v_log_date, p_modify_reservation_status.status, v_no_tickets);

    COMMIT;
    RETURN;

EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
END;
_____________________________________________________________________________________________________________________________
CREATE OR REPLACE PROCEDURE p_modify_reservation(
    reservation_id IN INT,
    no_tickets IN INT
)
IS
    v_total_tickets NUMBER; -- Suma już zarezerwowanych biletów
    v_max_tickets NUMBER; -- Maksymalna liczba miejsc na wycieczkę
    v_trip_date DATE;
    v_no_tickets NUMBER;
    v_status CHAR(1);
    v_log_id NUMBER;
    v_log_date DATE;
BEGIN
    -- Pobranie liczby miejsc
    SELECT NO_TICKETS, STATUS
    INTO v_no_tickets, v_status
    FROM RESERVATION
    WHERE RESERVATION_ID = p_modify_reservation.reservation_id;

    -- Pobranie sumy już zarezerwowanych biletów
    SELECT COALESCE(SUM(NO_TICKETS), 0)
    INTO v_total_tickets
    FROM TABLE(f_trip_participants(p_modify_reservation.reservation_id));

    -- Pobranie maksymalnej liczby miejsc i daty wycieczki
    SELECT MAX_NO_PLACES, trip_date
    INTO v_max_tickets, v_trip_date
    FROM TRIP
    JOIN RESERVATION ON TRIP.TRIP_ID = RESERVATION.TRIP_ID
    WHERE RESERVATION.RESERVATION_ID = p_modify_reservation.reservation_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Błąd: Nie można zmieniać rezerwacji na przeszłą wycieczkę!');
    END IF;

    IF p_modify_reservation.no_tickets - v_no_tickets + v_total_tickets > v_max_tickets THEN
        RAISE_APPLICATION_ERROR(-20003, 'Błąd: Brak wystarczającej liczby miejsc na wycieczkę!');
    end if;

    -- Aktualizacja statusu
    UPDATE RESERVATION
    SET NO_TICKETS = p_modify_reservation.no_tickets
    WHERE RESERVATION_ID = p_modify_reservation.reservation_id;

    -- Dodanie wpisu do logów
    SELECT s_log_seq.NEXTVAL, SYSDATE INTO v_log_id, v_log_date FROM dual;
    INSERT INTO LOG (log_id, RESERVATION_ID, LOG_DATE, STATUS, NO_TICKETS)
    VALUES (v_log_id, p_modify_reservation.reservation_id, v_log_date, v_status, p_modify_reservation.no_tickets);

    COMMIT;
    RETURN;

EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
END;
