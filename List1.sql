DROP TABLE Nabywa;
DROP TABLE RobiZakupy;
DROP TABLE Asortyment;
DROP TABLE Produkt;
DROP TABLE Klient;
DROP TABLE Sklep;
 
CREATE TABLE Klient (
	id_klienta INT IDENTITY(1,1) CONSTRAINT kl_pk PRIMARY KEY,
	imie VARCHAR(20), 
	nazwisko VARCHAR(20) 
);

CREATE TABLE Sklep (
	id_sklepu INT IDENTITY(1,1) CONSTRAINT sk_pk PRIMARY KEY,
	nazwa VARCHAR(20),
);

CREATE TABLE RobiZakupy (
	id_zakupu INT IDENTITY(1,1) CONSTRAINT rz_pk PRIMARY KEY,
	sklep INT CONSTRAINT rz_ids_fk REFERENCES Sklep (id_sklepu),
	klient INT CONSTRAINT rz_idk_fk REFERENCES Klient(id_klienta),
	data DATETIME CONSTRAINT rz_da_nn NOT NULL,
	czas SMALLDATETIME CONSTRAINT rz_cz_nn NOT NULL
);

CREATE TABLE Produkt (
	id_produktu INT IDENTITY(1,1) CONSTRAINT pr_pk PRIMARY KEY,
	nazwa VARCHAR(20),
);

CREATE TABLE Asortyment (
	id_prod INT IDENTITY(1,1) CONSTRAINT as_pk PRIMARY KEY,
	produkt INT CONSTRAINT as_idp_fk REFERENCES Produkt (id_produktu),
	sklep INT CONSTRAINT as_ids_fk REFERENCES Sklep (id_sklepu),
	cena MONEY CONSTRAINT nb_ce_nn NOT NULL,
	UNIQUE (sklep, produkt),
	CHECK(cena > 0)
);

CREATE TABLE Nabywa (
	id_nabycia INT IDENTITY(1,1) CONSTRAINT nb_pk PRIMARY KEY,
	id_produktu INT CONSTRAINT nb_pr_fk REFERENCES Asortyment(id_prod),
	id_zakupu INT CONSTRAINT nb_za_fk REFERENCES RobiZakupy(id_zakupu),
	ilosc INT CONSTRAINT nb_il_nn NOT NULL,
	CHECK(ilosc > 0),
	UNIQUE(id_produktu, id_zakupu)
);

INSERT INTO Klient (imie, nazwisko)
VALUES('Jan', 'Kowalski');

INSERT INTO Sklep
VALUES('Biedronka');

INSERT INTO Produkt
VALUES('Bu³ka');

INSERT INTO Asortyment 
VALUES(1, 1, 0.50);

INSERT INTO RobiZakupy
VALUES(1, 1, '2019-01-01', '2019-01-01 00:00:00');

INSERT INTO Nabywa
VALUES(1, 1, 2);

INSERT INTO Nabywa
VALUES(1, 1, 2);


INSERT INTO Asortyment
VALUES(1, 1, 0.5);

INSERT INTO Asortyment
VALUES(1, 2, -0.5);

INSERT INTO Nabywa
VALUES(1, 2, 0);
