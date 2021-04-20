CREATE TABLE Country(
    Name            varchar(50) primary key,
    ID              int,
    CountryCode     varchar(4),
    Population      int
);

CREATE TABLE Person(
    PersonID        int primary key,
    FirstName       varchar(50),
    LastName        varChar(50),
    State           varchar(50),
    ZipCode         smallint,
    ResidingCountry varchar(50),
    FOREIGN KEY (ResidingCountry) REFERENCES Country(Name)
);

CREATE TABLE CountryStatistics(
    CountryID       int,
    Deaths          int,
    Cases           int,
    Recovered       int,
    Active          int,
    DeathsPer100    float,
    RecoveredPer100 float
);

CREATE TABLE IndividualStatistics(
    Person          int,
    ActiveCase      boolean,
    PreviousCase    boolean,
    Recovered       boolean,
    FOREIGN KEY (Person) REFERENCES Person(PersonID)
);

CREATE TABLE Vaccine(
    Person          int,
    Vaccinated      boolean,
    VaccineReceived varchar(30),
    DoseNumber      tinyint,
    Symptoms        boolean,
    FOREIGN KEY (Person) REFERENCES IndividualStatistics(Person)
);