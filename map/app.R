
library(shiny)
library(leaflet)
library(dplyr)
library(readr)
library(httr)
library(jsonlite)


# UI for the app
ui <- fluidPage(
    titlePanel("Upload CSV and Visualize Clients on Map"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Upload CSV File", 
                      accept = c(".csv")),
            tags$hr(),
            h4("Instructions:"),
            p("1. Upload a CSV file containing latitude and longitude data."),
            p("2. The CSV file should have two columns named 'Latitude' and 'Longitude'.")
        ),
        
        mainPanel(
            leafletOutput("mymap"),
            tableOutput("summary"),
            tableOutput("client_count")
        )
    )
)

# Server logic
server <- function(input, output, session) {
    
    # Reverse geocode function
    reverse_geocode <- function(lat, lon) {
        url <- paste0("https://nominatim.openstreetmap.org/reverse?format=json&lat=", lat, "&lon=", lon, "&zoom=10&addressdetails=1")
        response <- httr::GET(url)
        content <- httr::content(response, as = "text")
        result <- jsonlite::fromJSON(content)
        
        if (!is.null(result$address$city)) {
            return(result$address$city)
        } else if (!is.null(result$address$village)) {
            return(result$address$village)
        } else if (!is.null(result$address$town)) {
            return(result$address$town)
        } else {
            return(NA)
        }
    }
    
    # Reactive file reading
    uploaded_data <- reactive({
        req(input$file)
        
        data <- read_csv(input$file$datapath)
        
        if (!all(c("Latitude", "Longitude") %in% colnames(data))) {
            stop("The CSV file must contain 'Latitude' and 'Longitude' columns.")
        }
        
        valid_data <- data %>%
            filter(!(Latitude == 0 & Longitude == 0))
        
        return(valid_data)
    })
    
    # Map rendering
    output$mymap <- renderLeaflet({
        data <- uploaded_data()
        
        leaflet(data = data) %>%
            addTiles() %>%
            addCircleMarkers(
                lng = ~Longitude, 
                lat = ~Latitude, 
                popup = ~paste("Latitude:", Latitude, "<br>Longitude:", Longitude)
            )
    })
    
    # Descriptive statistics
    output$summary <- renderTable({
        data <- uploaded_data()
        
        summary_stats <- data %>%
            summarise(
                Lat_Min = min(Latitude),
                Lat_Max = max(Latitude),
                Lat_Mean = mean(Latitude),
                Lon_Min = min(Longitude),
                Lon_Max = max(Longitude),
                Lon_Mean = mean(Longitude)
            )
        
        summary_stats
    })
    
    # Client count and place names
    output$client_count <- renderTable({
        data <- uploaded_data()
        
        client_counts <- data %>%
            group_by(Latitude, Longitude) %>%
            summarise(Client_Count = n()) %>%
            mutate(Place = mapply(reverse_geocode, Latitude, Longitude))
        
        client_counts
    })
}

# Create the Shiny app object
shinyApp(ui, server)

