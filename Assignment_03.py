import sqlite3
import pandas as pd

# (A) Import Data
data = pd.read_csv('students.csv')
data['StudentID'] = data.index + 1
data['FacultyAdvisor'] = [''] * len(data.index)
data['isDeleted'] = [0] * len(data.index)
data = data[['StudentID', 'FirstName', 'LastName', 'GPA', 'Major',      # Restructuring Data to Match Student Table
             'FacultyAdvisor', 'Address', 'City', 'State', 'ZipCode',
             'MobilePhoneNumber', 'isDeleted']]

# Insert values into Student table
conn = sqlite3.connect('StudentDB.sqlite')
cursor = conn.cursor()
for idx, row in data.iterrows():
    cursor.execute('''
        INSERT INTO Student (StudentID, FirstName, LastName, GPA, Major, FacultyAdvisor, Address, City,
                            State, ZipCode, MobilePhoneNumber, isDeleted)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        ''', tuple(row))

conn.commit()
conn.close()

# Function to display students and attributes
def displayStudents():
    connF = sqlite3.connect('StudentDB.sqlite')
    cursorF = connF.cursor()
    cursorF.execute("SELECT * FROM Student WHERE isDeleted = 0")
    for row in cursorF.fetchall():
        print(row)
    return

# Function to check if ID is both a valid number and if it already exists
def checkID(element, exist=True):
    connF = sqlite3.connect('StudentDB.sqlite')
    cursorF = connF.cursor()
    if not element.isdigit():
        raise ValueError('Not a valid input.')
    element = int(element)
    cursorF.execute("SELECT StudentID FROM Student")
    if element in [row[0] for row in cursorF.fetchall()]:
        if exist:
            raise ValueError('Student already exists.')
    else:
        if not exist:
            raise ValueError('Student does not exist.')
    return element

# Function to determine if string input is a float
def checkOnlyFloat(element):
    try:
        float(element)
    except ValueError:
        raise ValueError('Not a valid input.')
    return float(element)

# Function to determine if string input is purely numeric
def checkOnlyNumeric(element):
    if not element.isdigit():
        raise ValueError('Not a valid input.')
    return int(element)

# Function to determine if string input is purely characters
def checkOnlyCharacter(element):
    if any(char.isdigit() for char in element):
        raise ValueError('Not a valid input.')
    return element

# Function to determine if input is a string
def checkString(element):
    if not isinstance(element, str):
        raise ValueError('Not a valid input.')
    return element


'''
Function to present user with options to interact with
database, no return type
:parameters None
'''
def options():
    connF = sqlite3.connect('StudentDB.sqlite')
    cursorF = connF.cursor()
    while True:
        print("Please Select an Option")
        print("1. Display all students")
        print("2. Add new student to database")
        print("3. Update existing student")
        print("4. Delete existing student")
        print("5. Search students by features")
        print("6. Exit")
        option = int(input())

        # Display All Students
        if option == 1:
            displayStudents()
            print('\n' * 4)
            continue

        # Add New Student
        if option == 2:
            stID, firstName, lastName, = checkID(input('Student ID: ')), checkOnlyCharacter(input('First Name: ')), checkOnlyCharacter(input('Last Name: '))
            gpa, major, advisor = checkOnlyFloat(input('GPA: ')), checkOnlyCharacter(input('Major: ')), checkOnlyCharacter(input('Faculty Advisor: '))
            address, city, state = checkString(input('Address: ')), checkOnlyCharacter(input('City: ')), checkOnlyCharacter(input('State: '))
            zipC, mpn, isDel = checkString(input('Zip Code: ')), checkString(input('Mobile Phone Number: ')), 0
            newStudent = (stID, firstName, lastName, gpa, major, advisor, address, city, state, zipC, mpn, isDel)
            cursorF.execute("INSERT INTO Student VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", newStudent)
            connF.commit()
            print('\n' * 4, newStudent[1],newStudent[2],"added to database.", '\n')
            continue

        # Update Student
        if option == 3:
            stID = checkID(input("Enter student ID to update: "),exist=False)
            print("What would you like to update?")
            print('\n',"1. Major",'\n',"2. Advisor",'\n', "3. Mobile Phone Number",'\n', "4. All")
            new_option = input()
            if new_option == '1':
                major = checkOnlyCharacter(input('Updated Major: '))
                cursorF.execute("UPDATE Student SET Major = ? WHERE StudentID = ?", (major,stID))
                connF.commit()
                print('\n' * 4, 'Student major updated.', '\n')
                continue
            if new_option == '2':
                advisor = checkOnlyCharacter(input('Updated Advisor: '))
                cursorF.execute("UPDATE Student SET FacultyAdvisor = ? WHERE StudentID = ?", (advisor,stID))
                connF.commit()
                print('\n'*4, 'Student advisor updated.', '\n')
                continue
            if new_option == '3':
                mpn = checkString(input('Updated Mobile Phone Number: '))
                cursorF.execute("UPDATE Student SET MobilePhoneNumber = ? WHERE StudentID = ?", (mpn, stID))
                connF.commit()
                print('\n' * 4, 'Student mobile number updated.', '\n')
                continue
            if new_option == '4':
                major = checkOnlyCharacter(input('Updated Major: '))
                advisor = checkOnlyCharacter(input('Updated Advisor: '))
                mpn = checkString(input('Updated Mobile Phone Number: '))
                cursorF.execute("UPDATE Student SET Major = ?, FacultyAdvisor = ?, MobilePhoneNumber = ? WHERE StudentID = ?", (major, advisor,mpn,stID))
                connF.commit()
                print('\n' * 4, 'Student major, advisor, mobile number updated.', '\n')
                continue
            else:
                print('Not a valid input', '\n')
                continue

        # Delete Student
        if option == 4:
            stID = checkID(input('Enter student ID to delete: '),exist=False)
            cursorF.execute("UPDATE Student SET isDeleted = ? WHERE StudentID = ?", (1,stID))
            connF.commit()
            print('Student deleted.', '\n')
            continue

        # Search Students By Features
        if option == 5:
            print("You can query students by 1. Major, 2. GPA, 3. City, 4. State, and 5. Advisor")
            new_option = input()
            if new_option == '1':
                major = checkOnlyCharacter(input('Which major would you like to select: '))
                cursorF.execute("SELECT * FROM Student WHERE Major = ?", (major,))
                for row in cursorF.fetchall():
                    print(row)
                print('\n' * 4)
                continue
            if new_option == '2':
                gpa = checkOnlyFloat(input('Which GPA would you like to select: '))
                cursorF.execute("SELECT * FROM Student WHERE GPA = ?", (gpa,))
                for row in cursorF.fetchall():
                    print(row)
                print('\n' * 4)
                continue
            if new_option == '3':
                city = checkOnlyCharacter(input('Which city would you like to select: '))
                cursorF.execute("SELECT * FROM Student WHERE City = ?", (city,))
                for row in cursorF.fetchall():
                    print(row)
                print('\n' * 4)
                continue
            if new_option == '4':
                state = checkOnlyCharacter(input('Which state would you like to select: '))
                cursorF.execute("SELECT * FROM Student WHERE State = ?", (state,))
                for row in cursorF.fetchall():
                    print(row)
                print('\n' * 4)
                continue
            if new_option == '5':
                advisor = checkOnlyCharacter(input('Which advisor would you like to select: '))
                cursorF.execute("SELECT * FROM Student WHERE FacultyAdvisor = ?", (advisor,))
                for row in cursorF.fetchall():
                    print(row)
                print('\n' * 4)
                continue
            else:
                print('Not a valid input')
                print('\n' * 4)
                continue

        # Exit
        if option == 6:
            break

    connF.close()
    return


if __name__ == "__main__":
    options()
