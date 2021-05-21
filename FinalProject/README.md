# Final Project README 

## Please read for instructions on how to run the Shiny Application in R 

### How To Run Application
* Open a session in RStudio or R terminal
* Make sure you have installed the shiny library to R by using 
```r
install.packages("shiny")
library(shiny)
```
* After the necessary packages are installed, run the following command to open the application

```r
runGitHub("CPSC408", "<YOUR USER NAME>")
```
* If the previous command does not work try two of the following options
    * Running with my username "npeverett"
    * Download the app.r file and install all of the necessary packages. There will be a "Run App" button at the top right hand corner of your RStudio session. **Be sure to use the Run App button. Do not try to just run the file itself or run the last `shinyApp(ui,server)` code as it will not load dependencies from Shiny to run the application**


### Known Bugs
There are a couple of bugs within this application that are known and need fixing 

#### On the Covid Statistics Tab
There are no known bugs on this tab, however, you may notice that the y-axis data is in scientific notation which can be annoying to read. If you would like to change this option run the following command in your R terminal `options(scipen=100000)` 

There are also only 500 individuals in the database and these individuals only have a chance of being vaccinated. On top of this chance, the 500 are spread across multiple countries so it should not be surprising that some countries have little to no vaccination data. This is not a bug. 

#### On the Data Viewer Tab
There are a couple of known bugs on this tab.

* R is constantly attempting to read the users input in the tables and columns in an Observe state which can cause the queries to run multiple times or run while something was previously selected but then was deleted. This is why deleting or adding a value to the select input can sometimes cause the application to crash. Try to run the same query again in a new session if this happens.
* There is also a bug with joining all of the tables together since the JOIN query needs to be created dynamically, there is sometimes an issue with the Observe function not reading an input in time and trying to send the query without being updated causing an error or a crash. 
* Trying to JOIN together Country and Vaccine does not produce data despite the JOIN query being correct and I have not been able to determine why this is. It should not crash, it just will not produce any data. Please refer to the Covid Statistics tab to look at the Vaccine and Country data.

#### On the SQL Interface Tab
Enter the input that you would like in the form of a tuple without the parenthesis. For example, in Country I would enter *"ReneGermanLand", 4125, "RGLA", 1521591* and then enter. Be sure to encapsulate string values in a double quotes. For conditions, be sure to start with the operator you would like. For example, in Delete Record, be sure to say ` > 500000000 ` if you want to delete records with population greater than that value. 

* When creating a new record, the same issue with Observe can happen. Despite being able to properly insert a new record, the Observe function will run the query more than one time which means we will get a duplicate key error the second time it tries to run it even though you only click the button once. The status message may say "Failed to Create Record" however if the input was correct, be sure to check the data viewer tab to see if the record is there, because chances are it is. 
* This can happen with update and delete as well, but the error seems to be less common in these operations

#### Closing the Database Connection
If you put any code after the `shinyApp(ui,server)` the application will break which means you will be opening many connections to the database given the application is bound to crash with the Observe bug at least once or twice. If you receive an error about too many instances open, please run the following command to clear the connections
`lapply(dbListConnections(RMySQL::MySQL()), dbDisconnect)`. This is also commented at the bottom of the app.r file.

### Conclusion
That is the information and known bugs regarding this application. If you have an error that was not listed here, or issues accessing the application or database itself, please send me an email so we can solve the problem. 
