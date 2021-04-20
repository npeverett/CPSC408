from faker import Faker
import pandas as pd
import random

file_name = input('Please enter the path for the csv file to inject the data: ')
number_records = int(input('Please enter the number of records to be generated: '))
fake = Faker()

# Country Data
country = {}
country['Name'] = [fake.unique.country() for i in range(number_records)]
country['ID'] = range(1, 1+number_records)
country['CountryCode'] = [i[0:4].upper() for i in country['Name']]
country['Population'] = [random.randrange(1000000,1000000000) for _ in range(number_records)]

# Person Data
person = {}
person['PersonID'] = random.sample(range(100,999),number_records)
person['FirstName'] = [fake.unique.first_name() for i in range(number_records)]
person['LastName'] = [fake.unique.last_name() for i in range(number_records)]
person['State'] = [fake.state() for i in range(number_records)]
person['ZipCode'] = [fake.zipcode() for i in range(number_records)]
person['ResidingCountry'] = [random.choice(country['Name']) for i in range(number_records)]

# Country Statistics
countryStats = {}
countryStats['CountryID'] = country['ID']
countryStats['Deaths'] = [random.randint(500000, 10000000) for i in range(number_records)]
countryStats['Cases'] = [random.randint(500000, 10000000) for i in range(number_records)]
countryStats['Recovered'] = [random.randint(500000, 10000000) for i in range(number_records)]
countryStats['Active'] = [random.randint(500000, 10000000) for i in range(number_records)]
countryStats['Deaths_Per_100'] = [random.randint(5000, 10000) for i in range(number_records)]
countryStats['Recovers_Per_100'] = [random.randint(5000, 10000) for i in range(number_records)]

# Individual Statistics
personStats = {}
personStats['Person'] = person['PersonID']
personStats['ActiveCase'] = [random.randrange(0,2) for _ in range(number_records)]
personStats['PreviousCase'] = [random.randrange(0,2) for _ in range(number_records)]
recovered = []
for i in range(number_records):
    if personStats['ActiveCase'][i] == 1:
        recovered.append(0)
    elif personStats['PreviousCase'][i] == 1:
        recovered.append(random.randrange(0,2))
    else:
        recovered.append(-1)
personStats['Recover'] = recovered

# Vaccine
vaccines = ['Moderna', 'Pfizer', 'JohnsonJohnson']
vaccine = {}
vaccine['Patient'] = personStats['Person']
vaccine['Vaccinated'] = [random.randrange(0,2) for _ in range(number_records)]
vaccine['VaccineReceived'] = [random.choice(vaccines) if vaccine['Vaccinated'][i] == 1 else 'Not Applicable' for i in range(number_records)]
doseNumber = []
for i in range(number_records):
    if vaccine['Vaccinated'][i] == 1:
        if 'Moderna' in vaccine['VaccineReceived'][i] or 'Pfizer' in vaccine['VaccineReceived'][i]:
            doseNumber.append(random.randrange(1,3))
        else:
            doseNumber.append(1)
    else:
        doseNumber.append(-1)
vaccine['DoseNumber'] = doseNumber
vaccine['Symptomatic'] = [random.randrange(0,2) if vaccine['Vaccinated'][i] == 1 else -1 for i in range(number_records)]

# Adding data to csv file
merge = {**country, **person, **countryStats, **personStats, **vaccine}
complete_df = pd.DataFrame(merge)
complete_df.to_csv(file_name, index=False)
