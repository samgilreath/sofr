# Check and install 'httr' if not already installed
if (!require("httr", quietly = TRUE)) {
  install.packages("httr")
  library(httr)
}

# Check and install 'jsonlite' if not already installed
if (!require("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
  library(jsonlite)
}

# Function to get SOFR history from the API endpoint
get_sofr_history <- function() {
  # Define the API endpoint
  url <- "https://markets.newyorkfed.org/api/rates/secured/sofr/last/365.json"
  
  # Send a GET request to the API
  response <- GET(url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Parse the JSON content from the response
    content <- content(response, "text", encoding = "UTF-8")
    data <- fromJSON(content, flatten = TRUE)
    
    # Extract the SOFR data from the response
    sofr_data <- data$refRates[sapply(data$refRates$type, function(x) x == "SOFR"), ]
    
    # Check if there is any SOFR data available
    if (nrow(sofr_data) > 0) {
      # Convert effectiveDate to Date type
      sofr_data$effectiveDate <- as.Date(sofr_data$effectiveDate)
      
      # Sort data by effectiveDate
      sofr_data <- sofr_data[order(sofr_data$effectiveDate), ]
      
      # Return the SOFR data
      return(sofr_data)
    } else {
      stop("SOFR history not found in the response.")
    }
  } else {
    stop("Failed to fetch SOFR history. Status code: ", status_code(response))
  }
}

# Fetch the SOFR history
sofr_history <- get_sofr_history()

# Write the historical SOFR data to a csv file
write.csv(sofr_history,file='sofr_history.csv',quote=FALSE)

