import mysql.connector
import pandas as pd

# Connecting to database
conn = mysql.connector.connect(user='everett', host='34.71.168.251', database='CPSC408')
cursor = conn.cursor()

# Reading in file
file_path = input('Enter the updated csv file containing newly generated data: ')
file_path = 'Assignment04/' + file_path
print('Updating...')
data = pd.read_csv(file_path)

# Parse data to variables to pass into SQL statements
toCountry = data.iloc[:,0:4]
toPerson = data.iloc[:,4:10]
toCountryStatistics = data.iloc[:,10:17]
toIndividualStatistics = data.iloc[:,17:21]
toVaccine = data.iloc[:,21:]

# Adding data to Country table
for idx, row in toCountry.iterrows():
    cursor.execute('INSERT INTO Country (Name, ID, CountryCode, Population) VALUES (%s,%s,%s,%s)', tuple(row))
conn.commit()

# Adding data to Person table
for idx,row in toPerson.iterrows():
    cursor.execute('INSERT INTO Person (PersonID, FirstName, LastName, State, ZipCode, ResidingCountry) VALUES (%s,%s,%s,%s,%s,%s)',tuple(row))
conn.commit()

# Adding data to CountryStatistics table
for idx,row in toCountryStatistics.iterrows():
    cursor.execute('''
    INSERT INTO CountryStatistics (CountryID, Deaths, Cases, Recovered, Active, DeathsPer100, RecoveredPer100) 
    VALUES (%s,%s,%s,%s,%s,%s,%s)''', tuple(row))
conn.commit()

# Adding data to IndividualStatistics table
for idx,row in toIndividualStatistics.iterrows():
    cursor.execute('INSERT INTO IndividualStatistics (Person, ActiveCase, PreviousCase, Recovered) VALUES (%s,%s,%s,%s)', tuple(row))
cursor.execute('UPDATE IndividualStatistics SET Recovered = NULL WHERE Recovered = -1')
conn.commit()

# Adding data to Vaccine table
for idx, row in toVaccine.iterrows():
    cursor.execute('INSERT INTO Vaccine (Person, Vaccinated, VaccineReceived, DoseNumber, Symptoms) VALUES(%s,%s,%s,%s,%s)', tuple(row))
cursor.execute('UPDATE Vaccine SET VaccineReceived = NULL WHERE VaccineReceived = "Not Applicable"')
cursor.execute('UPDATE Vaccine SET DoseNumber = NULL WHERE DoseNumber = -1')
cursor.execute('UPDATE Vaccine SET Symptoms = NULL WHERE Symptoms = -1')
conn.commit()

# Close the connection
print('Database updated.')
conn.close()
