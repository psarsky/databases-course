

# Oracle PL/Sql

widoki, funkcje, procedury, triggery
ćwiczenie

---


Imiona i nazwiska autorów : Dariusz Rozmus, Jakub Psarski

---
<style>
  {
    font-size: 16pt;
  }
</style> 

<style scoped>
 li, p {
    font-size: 14pt;
  }
</style> 

<style scoped>
 pre {
    font-size: 10pt;
  }
</style> 

# Tabele

![](_img/ora-trip1-0.png)


- `Trip`  - wycieczki
	- `trip_id` - identyfikator, klucz główny
	- `trip_name` - nazwa wycieczki
	- `country` - nazwa kraju
	- `trip_date` - data
	- `max_no_places` -  maksymalna liczba miejsc na wycieczkę
- `Person` - osoby
	- `person_id` - identyfikator, klucz główny
	- `firstname` - imię
	- `lastname` - nazwisko


- `Reservation`  - rezerwacje/bilety na wycieczkę
	- `reservation_id` - identyfikator, klucz główny
	- `trip_id` - identyfikator wycieczki
	- `person_id` - identyfikator osoby
	- `status` - status rezerwacji
		- `N` – New - Nowa
		- `P` – Confirmed and Paid – Potwierdzona  i zapłacona
		- `C` – Canceled - Anulowana
- `Log` - dziennik zmian statusów rezerwacji 
	- `log_id` - identyfikator, klucz główny
	- `reservation_id` - identyfikator rezerwacji
	- `log_date` - data zmiany
	- `status` - status


```sql
CREATE SEQUENCE s_person_seq
	START WITH 1
	INCREMENT BY 1;

CREATE TABLE person
(
	person_id int NOT NULL
		CONSTRAINT pk_person
			PRIMARY KEY,
	firstname varchar(50),
	lastname  varchar(50)
)

ALTER TABLE person
	MODIFY person_id INT DEFAULT s_person_seq.nextval;

```


```sql
CREATE SEQUENCE s_trip_seq
	START WITH 1
	INCREMENT BY 1;

CREATE TABLE trip
(
	trip_id       int NOT NULL
		CONSTRAINT pk_trip
			PRIMARY KEY,
	trip_name     varchar(100),
	country       varchar(50),
	trip_date     date,
	max_no_places int
);

ALTER TABLE trip
	MODIFY trip_id INT DEFAULT s_trip_seq.nextval;
```


```sql
CREATE SEQUENCE s_reservation_seq
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE reservation
(
    reservation_id int NOT NULL
        CONSTRAINT pk_reservation
            PRIMARY KEY,
    trip_id        int,
    person_id      int,
    status         char(1)
);

ALTER TABLE reservation
    MODIFY reservation_id INT DEFAULT s_reservation_seq.nextval;


ALTER TABLE reservation
    ADD CONSTRAINT reservation_fk1 FOREIGN KEY
        (person_id) REFERENCES person (person_id);

ALTER TABLE reservation
    ADD CONSTRAINT reservation_fk2 FOREIGN KEY
        (trip_id) REFERENCES trip (trip_id);

ALTER TABLE reservation
    ADD CONSTRAINT reservation_chk1 CHECK
        (status IN ('N', 'P', 'C'));

```


```sql
CREATE SEQUENCE s_log_seq
	START WITH 1
	INCREMENT BY 1;


CREATE TABLE log
(
	log_id         int  NOT NULL
		CONSTRAINT pk_log
			PRIMARY KEY,
	reservation_id int  NOT NULL,
	log_date       date NOT NULL,
	status         char(1)
);

ALTER TABLE log
	MODIFY log_id INT DEFAULT s_log_seq.nextval;

ALTER TABLE log
	ADD CONSTRAINT log_chk1 CHECK
		(status IN ('N', 'P', 'C'))
enable;

ALTER TABLE log
	ADD CONSTRAINT log_fk1 FOREIGN KEY
		(reservation_id) REFERENCES reservation (reservation_id);
```


---
# Dane


Należy wypełnić  tabele przykładowymi danymi 
- 4 wycieczki
- 10 osób
- 10 rezerwacji

Dane testowe powinny być różnorodne (wycieczki w przyszłości, wycieczki w przeszłości, rezerwacje o różnym statusie itp.) tak, żeby umożliwić testowanie napisanych procedur.

W razie potrzeby należy zmodyfikować dane tak żeby przetestować różne przypadki.


```sql
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
```

proszę pamiętać o zatwierdzeniu transakcji

---
# Zadanie 0 - modyfikacja danych, transakcje

Należy zmodyfikować model danych tak żeby rezerwacja mogła dotyczyć kilku miejsc/biletów na wycieczkę
- do tabeli reservation należy dodać pole
	- no_tickets
- do tabeli log należy dodac pole
	- no_tickets
	
Należy zmodyfikować zestaw danych testowych

Należy przeprowadzić kilka eksperymentów związanych ze wstawianiem, modyfikacją i usuwaniem danych
oraz wykorzystaniem transakcji

Skomentuj dzialanie transakcji. Jak działa polecenie `commit`, `rollback`?.
Co się dzieje w przypadku wystąpienia błędów podczas wykonywania transakcji? Porównaj sposób programowania operacji wykorzystujących transakcje w Oracle PL/SQL ze znanym ci systemem/językiem MS Sqlserver T-SQL

pomocne mogą być materiały dostępne tu:
https://upel.agh.edu.pl/mod/folder/view.php?id=311899
w szczególności dokument: `1_ora_modyf.pdf`


```sql
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

```
Transakcja - mechanizm grupujący operacje na danych w jednostki. Jednostka może zostać wykonana 
jedynie w całości albo wcale, co zapewnia spójność danych w bazie. 

Polecenia zarządzające transakcjami:
- `COMMIT` - zatwierdza zmiany dokonane w ramach bieżącej transakcji - dopiero po wykonaniu tego 
polecenia zmiany zostają utrwalone.
- `ROLLBACK` - cofa zmiany dokonane w ramach bieżącej transakcji, przywracając stan do momentu po 
wykonaniu ostatniego polecenia `COMMIT`.

Wystąpienie błędu podczas transakcji powoduje jej unieważnienie.

---
# Zadanie 1 - widoki


Tworzenie widoków. Należy przygotować kilka widoków ułatwiających dostęp do danych. Należy zwrócić uwagę na strukturę kodu (należy unikać powielania kodu)

Widoki:
-   `vw_reservation`
	- widok łączy dane z tabel: `trip`,  `person`,  `reservation`
	- zwracane dane:  `reservation_id`,  `country`, `trip_date`, `trip_name`, `firstname`, `lastname`, `status`, `trip_id`, `person_id`, `no_tickets`
-   `vw_trip` 
	- widok pokazuje liczbę wolnych miejsc na każdą wycieczkę
	- zwracane dane: `trip_id`, `country`, `trip_date`, `trip_name`, `max_no_places`, `no_available_places` (liczba wolnych miejsc)
-   `vw_available_trip`
	- podobnie jak w poprzednim punkcie, z tym że widok pokazuje jedynie dostępne wycieczki (takie które są w przyszłości i są na nie wolne miejsca)


Proponowany zestaw widoków można rozbudować wedle uznania/potrzeb
- np. można dodać nowe/pomocnicze widoki, funkcje
- np. można zmienić def. widoków, dodając nowe/potrzebne pola

# Zadanie 1  - rozwiązanie

```sql
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

```
```sql
SELECT * FROM VW_AVAILABLE_TRIP
```
![](_img/vw_available_trip.png)

```sql
SELECT * FROM VW_RESERVATION
```
![](_img/vw_reservation.png)

```sql
SELECT * FROM VW_TRIP
```
![](_img/vw_trip.png)


---
# Zadanie 2  - funkcje


Tworzenie funkcji pobierających dane/tabele. Podobnie jak w poprzednim przykładzie należy przygotować kilka funkcji ułatwiających dostęp do danych

Funkcje:
- `f_trip_participants`
	- zadaniem funkcji jest zwrócenie listy uczestników wskazanej wycieczki
	- parametry funkcji: `trip_id`
	- funkcja zwraca podobny zestaw danych jak widok  `vw_reservation`
-  `f_person_reservations`
	- zadaniem funkcji jest zwrócenie listy rezerwacji danej osoby 
	- parametry funkcji: `person_id`
	- funkcja zwraca podobny zestaw danych jak widok `vw_reservation`
-  `f_available_trips_to`
	- zadaniem funkcji jest zwrócenie listy wycieczek do wskazanego kraju, dostępnych w zadanym okresie czasu (od `date_from` do `date_to`)
	- parametry funkcji: `country`, `date_from`, `date_to`


Funkcje powinny zwracać tabelę/zbiór wynikowy. Należy rozważyć dodanie kontroli parametrów, (np. jeśli parametrem jest `trip_id` to można sprawdzić czy taka wycieczka istnieje). Podobnie jak w przypadku widoków należy zwrócić uwagę na strukturę kodu

Czy kontrola parametrów w przypadku funkcji ma sens?
- jakie są zalety/wady takiego rozwiązania?

Proponowany zestaw funkcji można rozbudować wedle uznania/potrzeb
- np. można dodać nowe/pomocnicze funkcje/procedury

# Zadanie 2  - rozwiązanie

```sql
-- Definicja typu uczestnika wycieczki
CREATE OR REPLACE TYPE trip_participants AS OBJECT
(
    reservation_id int,
    person_id      int,
    firstname      varchar(50),
    lastname       varchar(50),
    status         char(1),
    no_tickets     int
);

CREATE OR REPLACE TYPE trip_participants_table IS TABLE OF trip_participants;

-- f_trip_participants - zwraca listę uczestników wskazanej wycieczki
CREATE OR REPLACE FUNCTION f_trip_participants(trip_id int)
RETURN trip_participants_table
	AS
    result trip_participants_table;
valid  int;
BEGIN
	SELECT COUNT(*)
	INTO valid
	FROM trip t
	WHERE t.trip_id = f_trip_participants.trip_id;

	IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid trip ID');
END IF;

SELECT trip_participants(r.reservation_id, r.person_id, p.firstname, p.lastname, r.status,
						 r.no_tickets) BULK COLLECT
    INTO result
    FROM reservation r
             INNER JOIN person p ON r.person_id = p.person_id
    WHERE r.trip_id = f_trip_participants.trip_id
      AND r.status = 'P';
RETURN result;
END;


-- Definicja typu rezerwacji
CREATE OR REPLACE TYPE reservation_type AS OBJECT
(
    reservation_id int,
    trip_name      varchar(100),
    status         char(1),
    no_tickets     int
);

CREATE OR REPLACE TYPE reservation_table IS TABLE OF reservation_type;

-- f_person_reservations - zwraca listę rezerwacji danej osoby
CREATE OR REPLACE FUNCTION f_person_reservations(person_id int)
RETURN reservation_table
	AS
    result reservation_table;
valid  int;
BEGIN
	SELECT COUNT(*)
	INTO valid
	FROM person p
	WHERE p.person_id = f_person_reservations.person_id;

	IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid person ID');
END IF;

SELECT reservation_type(r.reservation_id, t.trip_name, r.status, r.no_tickets) BULK COLLECT
    INTO result
    FROM reservation r
             INNER JOIN trip t ON r.trip_id = t.trip_id
    WHERE r.person_id = f_person_reservations.person_id;
RETURN result;
END;


-- Definicja typu wycieczki
CREATE OR REPLACE TYPE trip_type AS OBJECT
(
    trip_id             int,
    country             varchar(50),
    trip_date           date,
    trip_name           varchar(100),
    no_available_places int
);

CREATE OR REPLACE TYPE trip_table IS TABLE OF trip_type;

-- f_available_trips_to - zwraca listę wycieczek do wskazanego kraju dostępnych w zadanym okresie
CREATE OR REPLACE FUNCTION f_available_trips_to(country varchar, date_from date, date_to date)
RETURN trip_table
	AS
    result trip_table;
valid  int;
BEGIN
	SELECT COUNT(*)
	INTO valid
	FROM trip t
	WHERE t.country = f_available_trips_to.country;

	IF valid = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid country name');
END IF;

SELECT trip_type(v.trip_id, v.country, v.trip_date, v.trip_name, v.no_available_places) BULK COLLECT
    INTO result
    FROM vw_trip v
    WHERE v.no_available_places > 0
      AND v.country = f_available_trips_to.country
      AND v.trip_date BETWEEN date_from AND date_to;
RETURN result;
END;

```
```sql
SELECT * FROM F_TRIP_PARTICIPANTS(4)
```
![](_img/f_trip_participants.png)

```sql
SELECT * FROM F_PERSON_RESERVATIONS(4)
```
![](_img/f_person_reservations.png)

```sql
SELECT * FROM F_AVAILABLE_TRIPS_TO('Polska', SYSDATE, TO_DATE('2025-05-30', 'YYYY-MM-DD'))
```
![](_img/f_available_trips_to.png)

```sql
SELECT * FROM F_AVAILABLE_TRIPS_TO('San Escobar', SYSDATE, TO_DATE('2025-05-30', 'YYYY-MM-DD'))
```
![](_img/f_available_trips_to_err.png)

Kontrola parametrów jest przydatnym rozwiązaniem - w przypadku zdefiniowanych powyżej funkcji 
pozwala zróżnicować sytuację, w której dla podanego parametru zbiór wynikowy jest pusty, od 
sytuacji, w której podany parametr nie występuje w bazie danych. Bez kontroli parametrów funkcje 
w obu sytuacjach zwracają puste tablice, a po wprowadzeniu kontroli zwracają błędy przy podaniu 
parametrów niezgodnych z danymi w bazie (np. nieistniejący identyfikator użytkownika).

W ogólnym przypadku korzyścią płynącą z kontroli parametrów jest również możliwość zdefiniowania
komunikatów wyświetlanych przy wystąpieniu różnych rodzajów błędów związanych z parametrami.

---
# Zadanie 3  - procedury


Tworzenie procedur modyfikujących dane. Należy przygotować zestaw procedur pozwalających na modyfikację danych oraz kontrolę poprawności ich wprowadzania

Procedury:
- `p_add_reservation`
	- zadaniem procedury jest dopisanie nowej rezerwacji
	- parametry: `trip_id`, `person_id`,  `no_tickets`
	- procedura powinna kontrolować czy wycieczka jeszcze się nie odbyła, i czy sa wolne miejsca
	- procedura powinna również dopisywać inf. do tabeli `log`
- `p_modify_reservation_status
	- zadaniem procedury jest zmiana statusu rezerwacji 
	- parametry: `reservation_id`, `status`
	- procedura powinna kontrolować czy możliwa jest zmiana statusu, np. zmiana statusu już anulowanej wycieczki (przywrócenie do stanu aktywnego nie zawsze jest możliwa – może już nie być miejsc)
	- procedura powinna również dopisywać inf. do tabeli `log`
- `p_modify_reservation
	- zadaniem procedury jest zmiana statusu rezerwacji 
	- parametry: `reservation_id`, `no_iickets`
	- procedura powinna kontrolować czy możliwa jest zmiana liczby sprzedanych/zarezerwowanych biletów – może już nie być miejsc
	- procedura powinna również dopisywać inf. do tabeli `log`
- `p_modify_max_no_places`
	- zadaniem procedury jest zmiana maksymalnej liczby miejsc na daną wycieczkę 
	- parametry: `trip_id`, `max_no_places`
	- nie wszystkie zmiany liczby miejsc są dozwolone, nie można zmniejszyć liczby miejsc na wartość poniżej liczby zarezerwowanych miejsc

Należy rozważyć użycie transakcji

Należy zwrócić uwagę na kontrolę parametrów (np. jeśli parametrem jest trip_id to należy sprawdzić czy taka wycieczka istnieje, jeśli robimy rezerwację to należy sprawdzać czy są wolne miejsca itp..)


Proponowany zestaw procedur można rozbudować wedle uznania/potrzeb
- np. można dodać nowe/pomocnicze funkcje/procedury

# Zadanie 3  - rozwiązanie

```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```



---
# Zadanie 4  - triggery


Zmiana strategii zapisywania do dziennika rezerwacji. Realizacja przy pomocy triggerów

Należy wprowadzić zmianę, która spowoduje, że zapis do dziennika będzie realizowany przy pomocy trigerów

Triggery:
- trigger/triggery obsługujące 
	- dodanie rezerwacji
	- zmianę statusu
	- zmianę liczby zarezerwowanych/kupionych biletów
- trigger zabraniający usunięcia rezerwacji

Oczywiście po wprowadzeniu tej zmiany należy "uaktualnić" procedury modyfikujące dane. 

>UWAGA
Należy stworzyć nowe wersje tych procedur (dodając do nazwy dopisek 4 - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu  umożliwienia weryfikacji ich poprawności

Należy przygotować procedury: `p_add_reservation_4`, `p_modify_reservation_status_4` , `p_modify_reservation_4`


# Zadanie 4  - rozwiązanie

```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```



---
# Zadanie 5  - triggery


Zmiana strategii kontroli dostępności miejsc. Realizacja przy pomocy triggerów

Należy wprowadzić zmianę, która spowoduje, że kontrola dostępności miejsc na wycieczki (przy dodawaniu nowej rezerwacji, zmianie statusu) będzie realizowana przy pomocy trigerów

Triggery:
- Trigger/triggery obsługujące: 
	- dodanie rezerwacji
	- zmianę statusu
	- zmianę liczby zakupionych/zarezerwowanych miejsc/biletów

Oczywiście po wprowadzeniu tej zmiany należy "uaktualnić" procedury modyfikujące dane. 

>UWAGA
Należy stworzyć nowe wersje tych procedur (np. dodając do nazwy dopisek 5 - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu  umożliwienia weryfikacji ich poprawności. 

Należy przygotować procedury: `p_add_reservation_5`, `p_modify_reservation_status_5`, `p_modify_reservation_status_5`


# Zadanie 5  - rozwiązanie

```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```

---
# Zadanie 6


Zmiana struktury bazy danych. W tabeli `trip`  należy dodać  redundantne pole `no_available_places`.  Dodanie redundantnego pola uprości kontrolę dostępnych miejsc, ale nieco skomplikuje procedury dodawania rezerwacji, zmiany statusu czy też zmiany maksymalnej liczby miejsc na wycieczki.

Należy przygotować polecenie/procedurę przeliczającą wartość pola `no_available_places` dla wszystkich wycieczek (do jednorazowego wykonania)

Obsługę pola `no_available_places` można zrealizować przy pomocy procedur lub triggerów

Należy zwrócić uwagę na spójność rozwiązania.

>UWAGA
Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6 - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu  umożliwienia weryfikacji ich poprawności. 


- zmiana struktury tabeli

```sql
alter table trip add  
    no_available_places int null
```

- polecenie przeliczające wartość `no_available_places`
	- należy wykonać operację "przeliczenia"  liczby wolnych miejsc i aktualizacji pola  `no_available_places`

# Zadanie 6  - rozwiązanie

```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```



---
# Zadanie 6a  - procedury



Obsługę pola `no_available_places` należy zrealizować przy pomocy procedur
- procedura dodająca rezerwację powinna aktualizować pole `no_available_places` w tabeli trip
- podobnie procedury odpowiedzialne za zmianę statusu oraz zmianę maksymalnej liczby miejsc na wycieczkę
- należy przygotować procedury oraz jeśli jest to potrzebne, zaktualizować triggery oraz widoki



>UWAGA
Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6a - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu  umożliwienia weryfikacji ich poprawności. 
- może  być potrzebne wyłączenie 'poprzednich wersji' triggerów 


# Zadanie 6a  - rozwiązanie

```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```



---
# Zadanie 6b -  triggery


Obsługę pola `no_available_places` należy zrealizować przy pomocy triggerów
- podczas dodawania rezerwacji trigger powinien aktualizować pole `no_available_places` w tabeli trip
- podobnie, podczas zmiany statusu rezerwacji
- należy przygotować trigger/triggery oraz jeśli jest to potrzebne, zaktualizować procedury modyfikujące dane oraz widoki


>UWAGA
Należy stworzyć nowe wersje tych widoków/procedur/triggerów (np. dodając do nazwy dopisek 6b - od numeru zadania). Poprzednie wersje procedur należy pozostawić w celu  umożliwienia weryfikacji ich poprawności. 
- może  być potrzebne wyłączenie 'poprzednich wersji' triggerów 



# Zadanie 6b  - rozwiązanie


```sql

-- wyniki, kod, zrzuty ekranów, komentarz ...

```


# Zadanie 7 - podsumowanie

Porównaj sposób programowania w systemie Oracle PL/SQL ze znanym ci systemem/językiem MS Sqlserver T-SQL

```sql

-- komentarz ...

```