library(shiny)
library(shinydashboard)
library(shinythemes)
library(DT)
library(dplyr)
library(pool)
library(DBI)
library(stringr)
library(ggplot2)

# -------------------------------------------
# DATABASE CONNECTION
# -------------------------------------------
conn <- dbConnect(
  drv= RMySQL::MySQL(),
  dbname = "CPSC408",
  host= "35.236.39.175",
  username= "everett"
)


# -------------------------------------------
# USER INTERFACE 
# -------------------------------------------

ui <- dashboardPage(
  skin = 'purple',
    
  # Header
  dashboardHeader(title="Covid Database"),
  
  # Sidebard Menu
  dashboardSidebar(
    sidebarMenu(
      menuItem("Database Schema", tabName = "dbschema", icon=icon("th")),
      menuItem("Covid Statistics", tabName = "covid", icon=icon("cog")),
      menuItem("Data Viewer", tabName = "dataview", icon=icon("table")),
      menuItem("SQL Interface", tabName = "sql", icon=icon("refresh"))
    )
  ),

  # Main Body
  dashboardBody(
    tabItems(
      
      # Schema Tab
      tabItem(tabName = "dbschema",
              h2("Database Schema"),
              imageOutput("schemaPhoto")
      ),
      
      
      # Data View Tab
      tabItem(tabName = "dataview",
            column(12,
              fluidRow(
                # ----------------------------------------
                # SELECT SQL
                # ----------------------------------------
                box(
                   h4("View Existing Records"),
                   selectInput('select_table', 'Table', choices = 
                                 dbFetch(dbSendQuery(conn, "SHOW TABLES;")),
                               multiple=TRUE),
                   selectInput('select_column', 'Column', choices = c(),
                               multiple=TRUE),
                   actionButton('select_finish', 'Select Records'),
                   actionButton('select_export', 'Export Query to CSV'),
                   textOutput('export_status'),
                   background = 'yellow', width = 12, height = 300
                 )
              ),
              fluidRow(
                     DT::dataTableOutput('select_grid'),
              )
            )
      ),

      # SQL Tab
      tabItem(tabName= "sql",
              
              # ----------------------------------------
              # CREATE SQL 
              # ----------------------------------------
              fluidRow(
                box(
                  h4("Create a New Record"),
                  selectInput('create_table', 'Table', choices = 
                                dbFetch(dbSendQuery(conn, "SHOW TABLES;"))),
                  textInput('create_value', 'Values'),
                  actionButton('create_finish', 'Add Record'),
                  textOutput("create_status"),
                  background = 'light-blue', width = 10, height= 275
                  
                  )
                ),
              
              # ----------------------------------------  
              # UPDATE SQL
              # ----------------------------------------
              fluidRow(
                box(
                  h4("Update Existing Record"),
                  selectInput('update_table', 'Table', choices = 
                                dbFetch(dbSendQuery(conn, "SHOW TABLES;"))),
                  selectInput('update_column', 'Set', choices = c()),
                  textInput('update_to', "To"),
                  textInput('update_value', 'Where'),
                  actionButton('update_finish', 'Update Record'),
                  textOutput("update_status"),
                  background = 'olive', width = 10, height = 425
                  )
                ),
              
              # ----------------------------------------
              # DELETE SQL
              # ----------------------------------------
              fluidRow(
                box(
                  h4("Delete Existing Record"),
                  selectInput('delete_table', 'Table', choices = 
                                dbFetch(dbSendQuery(conn, "SHOW TABLES;"))),
                  selectInput('delete_column', 'Where', choices = c()),
                  textInput('delete_value', 'Condition'),
                  actionButton('delete_finish', 'Delete Record'),
                  textOutput("delete_status"),
                  background = 'red', width = 10, height = 350
                )
              )
            ),
      
      # COVID Graphs Tab
      tabItem(tabName = 'covid',
              column(12,
                     fluidRow(
                       h4('Covid Statistics per Country')
                     ),
                     
                     fluidRow(
                       selectInput('graph_country', 'Country', choices= dbFetch(dbSendQuery(conn, "SELECT Name FROM Country"))),
                       selectInput('graph_check', 'Information', choices= c('Case Information', 'Vaccine Information'))
                     ),
                     fluidRow(
                       plotOutput('graph_covid_country', width='100%')
                     )
              )
            )
          )
        )
)


# ----------------------------------------
# SERVER FUNCTIONALITY
# ----------------------------------------

server <- function(input, output, session) {
  
  # Render Schema Photo
  output$schemaPhoto <- renderImage({
    list(src="Covid_Schema.png", contentType = "image/png", width= 800, height=500) }, 
    deleteFile=FALSE)
  
  observe({
    
    # -------------------------------------------------------------
    # Graph Statistics
    # -------------------------------------------------------------
    
    # Graph Cases by Country
    if (input$graph_check == 'Case Information'){
      output$graph_covid_country <- renderPlot({
        plot_title <- sprintf("Covid Statistics in %s",input$graph_country)
        plot_data <- dbFetch(dbSendQuery(conn, sprintf("SELECT Cases, Active, Deaths, Recovered FROM CountryStatistics WHERE CountryID = (SELECT ID FROM Country WHERE Name = '%s')", input$graph_country)))
        plot_data <- data.frame(plot_data)
        Statistic <- names(plot_data)
        Value <- c(plot_data[[1]], plot_data[[2]], plot_data[[3]], plot_data[[4]])
        new_data <- data.frame(Statistic, Value)
        
        ggplot(new_data, aes(x=Statistic, y=Value, fill=Statistic)) + geom_bar(stat='identity') + scale_fill_hue(c=40) +
          geom_text(aes(label=Value), position = position_dodge(width=0.9), vjust=-0.5) +
          ggtitle(plot_title) + theme(plot.title= element_text(size = 20, face='bold', margin= margin(10,0,10,0))) +
          theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                panel.background = element_blank(), axis.line = element_line(colour = "black"))
      })
      
    }
    
    # Graph Vaccine Information by Country
    if (input$graph_check == 'Vaccine Information'){
      output$graph_covid_country <- renderPlot({
        plot_title <- sprintf("Vaccine Statistics in %s",input$graph_country)
        vax_query <- sprintf("SELECT Person.ResidingCountry,SUM(Vaccinated) as Vaccinated,SUM(IF(VaccineReceived = 'JohnsonJohnson', 1, 0)) as JohsonJohnson,SUM(IF(VaccineReceived = 'Pfizer', 1, 0)) as Pfizer, SUM(IF(VaccineReceived = 'Moderna', 1, 0)) as Moderna, SUM(IF(Symptoms = 1, 1,0)) as Symptomatic FROM Vaccine JOIN Person on Person.PersonID=Vaccine.Patient GROUP BY Person.ResidingCountry HAVING Person.ResidingCountry = '%s'", input$graph_country)
        plot_data <- dbFetch(dbSendQuery(conn, vax_query))
        plot_data <- data.frame(plot_data)
        Measure <- names(plot_data)[2:length(names(plot_data))]
        if(length(plot_data[[1]]) == 0){
          Value <- c(0,0,0,0,0)
        }
        
        else{
          Value <- c(plot_data[[2]], plot_data[[3]], plot_data[[4]], plot_data[[5]], plot_data[[6]])
        }
        
        new_data <- data.frame(Measure, Value)
        
        ggplot(new_data, aes(x=Measure, y=Value, fill=Measure)) + geom_bar(stat='identity') + scale_fill_hue(c=40) +
          geom_text(aes(label=Value), position = position_dodge(width=0.9), vjust=-0.5) +
          ggtitle(plot_title) + theme(plot.title= element_text(size = 20, face='bold', margin= margin(10,0,10,0))) +
          theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                panel.background = element_blank(), axis.line = element_line(colour = "black"))
      
      })
    }

    # -------------------------------------------------------------
    # SQL Create Record
    # -------------------------------------------------------------
    # Commit Record
    observeEvent(input$create_finish,{
      tryCatch(
        expr = {
          values <- gsub('\"', "'", input$create_value)
          dbFetch(dbSendQuery(conn, sprintf("INSERT INTO %s VALUES (%s)", input$create_table, values)))
          output$create_status <- renderText({ "Record Created" })
        },
        error = function(e){
          message(geterrmessage())
          print(e)
          output$create_status <- renderText({ "Failed to Create Record" })
        }
      )
    })
    
    # -------------------------------------------------------------
    # SQL Update Record
    # -------------------------------------------------------------
    updateSelectInput(session, 'update_column', choices=dbFetch(dbSendQuery(conn, sprintf('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = "%s"', input$update_table))))
    observeEvent(input$update_finish,{
      tryCatch(
        expr = {
          to <- gsub('\"', "'", input$update_to)
          condition <- gsub('\"', "'", input$update_value)
          dbFetch(dbSendQuery(conn, sprintf("UPDATE %s SET %s = %s WHERE %s", input$update_table, input$update_column, to, condition)))
          output$update_status <- renderText({ "Record Updated" })
          
        },
        error = function(e){
          message(geterrmessage())
          print(e)
          output$update_status <- renderText({ "Record Failed to Update" })
        }
      )
    })
    
    # -------------------------------------------------------------
    # SQL Delete Record
    # -------------------------------------------------------------
    updateSelectInput(session, 'delete_column', choices=dbFetch(dbSendQuery(conn, sprintf('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = "%s"', input$delete_table))))
    observeEvent(input$delete_finish,{
      tryCatch(
        expr = {
          condition <- gsub('\"', "'", input$delete_value)
          delete_query <- sprintf("DELETE FROM %s WHERE %s %s", input$delete_table, input$delete_column, condition)
          dbFetch(dbSendQuery(conn, delete_query))
          output$delete_status <- renderText({ "Record Deleted" })
        },
        error = function(e){
          message(geterrmessage())
          print(e)
          output$delete_status <- renderText({ "Record Failed to Delete" })
        }
      )
    })
    
    
    # -------------------------------------------------------------
    # SQL Select Record
    # -------------------------------------------------------------
    
    # Display Dynamic Tables and Columns
    tryCatch(
      exp = {
        new_choices <- c()
        if (length(input$select_table) >= 1){
          for (i in 1:length(input$select_table)){
            new_choices[i] <- dbFetch(dbSendQuery(conn,sprintf('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = "%s"', input$select_table[i])))
          }
        }

        new_choices <- unlist(new_choices)
        updateSelectInput(session, 'select_column', choices= new_choices)
        
        
        # Display Resulting Query in Data Table
        observeEvent(input$select_finish,{
          select_tables  <-  as.list(scan(text=input$select_table, what="", sep=","))
          
          # NO JOINS NECESSARY (Only 1 Table Selected)
          if (length(select_tables) == 1){
            select_columns <- as.list(scan(text=input$select_column, what="", sep=","))
            
            # Render Table
            output$select_grid <- DT::renderDataTable({
              new_data <- dbFetch(dbSendQuery(conn, sprintf('SELECT %s FROM %s', toString(unlist(select_columns)), unlist(select_tables))))
              DT::datatable(new_data)
            })
          }
          
          if (length(select_tables) > 1){
            select_columns <- as.list(scan(text=input$select_column, what="", sep=","))
            
            # MANUALLY-DEFINED JOINS
            CountryPersonJoin <- "LEFT JOIN Person on Person.ResidingCountry=Country.Name"
            PersonIndividualJoin <- "INNER JOIN IndividualStatistics on IndividualStatistics.Person=Person.PersonID"
            IndividualVaccineJoin <- "INNER JOIN Vaccine on Vaccine.Patient=IndividualStatistics.Person"
            CountryStatsCountryJoin <- "INNER JOIN Country on Country.ID=CountryStatistics.CountryID"
            VaccinePersonJoin <- "INNER JOIN Person on Person.PersonID=Vaccine.Patient"
            
            PersonCountryJoin <- "LEFT JOIN Country on Country.Name=Person.ResidingCountry"
            IndividualPersonJoin <- "INNER JOIN Person on Person.PersonID=IndividualStatistics.Person"
            VaccineIndividualJoin <- "INNER JOIN IndividualStatistics on IndividualStatistics.Person=Vaccine.Patient"
            CountryCountryStatsJoin <- "INNER JOIN CountryStatistics on CountryStatistics.CountryID=Country.ID"
            PersonVaccineJoin <- "INNER JOIN Vaccine on Vaccine.Patient=Person.PersonID"
             
            join_list <- c(c(CountryPersonJoin,PersonCountryJoin), c(PersonIndividualJoin, IndividualPersonJoin), c(IndividualVaccineJoin, VaccineIndividualJoin),
                           c(CountryStatsCountryJoin, CountryCountryStatsJoin), c(VaccinePersonJoin, PersonVaccineJoin))
            JOINS <- c()
            if ("Country" %in% select_tables){
              if ("Person" %in% select_tables){
                if (match("Country", select_tables) > match("Person", select_tables)){
                  JOINS <- c(JOINS, CountryPersonJoin)
                  
                }
                else{
                  JOINS <- c(JOINS, PersonCountryJoin)
                }
              }
            }
            
            if ("Person" %in% select_tables){
              if ("IndividualStatistics" %in% select_tables){
                if (match("Person", select_tables) > match("IndividualStatistics", select_tables)){
                  JOINS <- c(JOINS, PersonIndividualJoin)
                  
                }
                else{
                  JOINS <- c(JOINS, IndividualPersonJoin)
                }
              }
            }
            
            if ("IndividualStatistics" %in% select_tables){
              if("Vaccine" %in% select_tables){
                if (match("Vaccine", select_tables) > match("IndividualStatistics", select_tables)){
                  JOINS <- c(JOINS, IndividualVaccineJoin)
                }
                else{
                  JOINS <- c(JOINS, VaccineIndividualJoin)
                }
              }
            }
            
            if ("CountryStatistics" %in% select_tables){
              if("Country" %in% select_tables){
                if (match("CountryStatistics", select_tables) > match("Country", select_tables)){
                  JOINS <- c(JOINS, CountryStatsCountryJoin)
                }
                else{
                  JOINS <- c(JOINS, CountryCountryStatsJoin)
                }
              }
            }
            
            if ("Vaccine" %in% select_tables){
              if("Person" %in% select_tables){
                if (match("Vaccine", select_tables) > match("Person", select_tables)){
                  JOINS <- c(JOINS, VaccinePersonJoin)
                }
                else{
                  JOINS <- c(JOINS, PersonVaccineJoin)
                }
              }
            }
            
            if (length(JOINS) == 0){
              output$select_grid <- NULL 
            }
            
            else{
              for(join in JOINS){
                idx <- match(join,JOINS)
                if (grepl(sprintf("JOIN %s", toString(unlist(select_tables)[1])), join)){
                  replacement <- match(join, join_list)
                  if ((replacement %% 2) == 0){
                    JOINS[idx] <- join_list[replacement-1]
                  }
                  else{
                    JOINS[idx] <- join_list[replacement+1]
                  }
                }
                
                if (sum(grepl(word(join, 2,3), JOINS)) > 1){
                  replacement <- match(join, join_list)
                  if ((replacement %% 2) == 0){
                    JOINS[idx] <- join_list[replacement-1]
                  }
                  else{
                    JOINS[idx] <- join_list[replacement+1]
                  }
                }
              }
              
              #print(sprintf("SELECT %s FROM %s %s", toString(unlist(select_columns)),
                            #toString(unlist(select_tables)[1]), gsub(",","",toString(unlist(JOINS)))))
              
              finalQuery <- dbFetch(dbSendQuery(conn, sprintf("SELECT %s FROM %s %s", toString(unlist(select_columns)),
                                                             toString(unlist(select_tables)[1]), gsub(",","",toString(unlist(JOINS))))),n=Inf)
              
              # Render Table
              output$select_grid <- DT::renderDataTable({
                DT::datatable(finalQuery)
              })
              
              # Generate Report
              observeEvent(input$select_export,{
                finalQuery <- data.frame(finalQuery)
                filename <- sprintf("covid_report_%s.csv",toString(unlist(select_columns)))
                filename <- gsub(', ', '_', filename)
                write.csv(finalQuery, filename)
                output$export_status <- renderText({ 'Data Exported to CSV' })
                
              })
            }
          }
         }
        )
      },
      
      error = function(e){
      },
      
      warning = function(w){
      }
      
      )
  })
}


shinyApp(ui, server)

# lapply(dbListConnections(RMySQL::MySQL()), dbDisconnect)
