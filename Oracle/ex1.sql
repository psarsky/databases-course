-- Widok pozwala zaprezentować jakie osoby są zarezerwowane na dane wycieczki i poprzez jakie rezerwacje
CREATE OR REPLACE VIEW vw_reservation AS
SELECT reservation_id,
       country,
       trip_date,
       trip_name,
       firstname,
       lastname,
       status,
       TRIP.trip_id,
       RESERVATION.person_id,
       no_tickets
FROM PERSON
         JOIN RESERVATION ON PERSON.PERSON_ID = RESERVATION.PERSON_ID
         JOIN TRIP ON RESERVATION.TRIP_ID = TRIP.TRIP_ID;

-- Widok umożliwia sprawdzenie ile jest wolnych miejsc na daną wycieczkę, zakładając że rezerwacje o statusie C nie zajmują miejsc,
-- a o statusach N i P zajmują
CREATE OR REPLACE VIEW vw_trip AS
SELECT TRIP.trip_id, country, trip_date, trip_name, (TRIP.MAX_NO_PLACES - W1.COUNT) no_available_places
FROM TRIP
         JOIN (SELECT TRIP_ID, COUNT(*) AS COUNT
               FROM RESERVATION
               WHERE STATUS = 'N'
                  OR STATUS = 'P'
               GROUP BY TRIP_ID) W1 ON TRIP.TRIP_ID = W1.TRIP_ID;

-- Widok korzysta z widoku vw_trip i na jego podstawie wyświetla jedynie wycieczki, które są w przyszłości
-- i mają wolne miejsca
CREATE OR REPLACE VIEW vw_available_trip AS
SELECT *
FROM vw_trip
WHERE no_available_places > 0
  AND TRIP_DATE > SYSDATE
