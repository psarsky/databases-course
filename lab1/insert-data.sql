BEGIN
    INSERT INTO trip(trip_name, country, trip_date, max_no_places)
    VALUES ('Wycieczka do Paryza', 'Francja', TO_DATE('2023-09-12', 'YYYY-MM-DD'), 3);

    INSERT INTO trip(trip_name, country, trip_date, max_no_places)
    VALUES ('Piekny Krakow', 'Polska', TO_DATE('2025-05-03', 'YYYY-MM-DD'), 2);

    INSERT INTO trip(trip_name, country, trip_date, max_no_places)
    VALUES ('Znow do Francji', 'Francja', TO_DATE('2025-05-01', 'YYYY-MM-DD'), 3);

    INSERT INTO trip(trip_name, country, trip_date, max_no_places)
    VALUES ('Hel', 'Polska', TO_DATE('2025-05-01', 'YYYY-MM-DD'), 2);

    -- person
    INSERT INTO person(firstname, lastname)
    VALUES ('Jan', 'Nowak');

    INSERT INTO person(firstname, lastname)
    VALUES ('Jan', 'Kowalski');

    INSERT INTO person(firstname, lastname)
    VALUES ('Anna', 'Nowakowska');

    INSERT INTO person(firstname, lastname)
    VALUES ('Krzysztof', 'Nowak');

    INSERT INTO person(firstname, lastname)
    VALUES ('Natalia', 'Kamińska');

    INSERT INTO person(firstname, lastname)
    VALUES ('Alfred', 'Dąbrowski');

    INSERT INTO person(firstname, lastname)
    VALUES ('Mścisław', 'Kiełbasa');

    INSERT INTO person(firstname, lastname)
    VALUES ('Bogumił', 'Bąk');

    INSERT INTO person(firstname, lastname)
    VALUES ('Marian', 'Paździoch');

    INSERT INTO person(firstname, lastname)
    VALUES ('Bogumiła', 'Gwóźdź');

    -- reservation
    -- trip1
    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (1, 1, 'P');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (1, 2, 'N');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (1, 3, 'N');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (1, 4, 'C');

-- trip 2
    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (2, 4, 'P');

-- trip 3
    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (3, 5, 'P');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (3, 6, 'N');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (3, 7, 'C');

-- trip 4
    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (4, 9, 'P');

    INSERT INTO reservation(trip_id, person_id, status)
    VALUES (4, 10, 'P');

    COMMIT;
END;