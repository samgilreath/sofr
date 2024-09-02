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

# Function to get the current SOFR rate using the Federal Reserve Bank of New York API
get_sofr_rate <- function() {
  # Define the API endpoint
  url <- "https://markets.newyorkfed.org/api/rates/all/latest.json"
  
  # Send a GET request to the API
  response <- GET(url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Parse the JSON content from the response
    content <- content(response, "text", encoding = "UTF-8")
    data <- fromJSON(content, flatten = TRUE)
    
    # Extract the SOFR rate from the data
    sofr_data <- data$refRates[sapply(data$refRates$type, function(x) x == "SOFR"), ]
    
    # Return the most recent SOFR rate
    if (nrow(sofr_data) > 0) {
      # Convert effectiveDate to Date type and find the latest date
      sofr_data$effectiveDate <- as.Date(sofr_data$effectiveDate)
      latest_date <- max(sofr_data$effectiveDate)
      latest_sofr_rate <- sofr_data$percentRate[sofr_data$effectiveDate == latest_date]
      
      return(latest_sofr_rate)
    } else {
      stop("SOFR rate not found in the response.")
    }
  } else {
    stop("Failed to fetch SOFR rate. Status code: ", status_code(response))
  }
}

# Fetch and print the SOFR rate
sofr_rate <- get_sofr_rate()
print(paste("Current SOFR rate:", sprintf("%.2f", sofr_rate)))

