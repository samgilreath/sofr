---
title: "Fetching SOFR from the FRBNY API"
---

[API Documentation](https://markets.newyorkfed.org/static/docs/markets-api.html)\
\
**1. Install packages:**

```{r}
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
```

\
**2. Define the function:**

```{r}
get_sofr_rate <- function() {
```

\
**3. Define the API endpoint:**

```{r}
url <- "https://markets.newyorkfed.org/api/rates/all/latest.json"
```

\
**4. Send a GET Request to the API:**

```{r}
response <- GET(url)
```

`GET(url)` sends a GET request to the specified URL and stores the response in the `response` variable.\
\
**5. Check if the Request was Successful:**

```{r}
if (status_code(response) == 200) {
```

`status_code(response)` retrieves the HTTP status code of the response.\
A status code of 200 indicates success.\
\
**6. Parse the JSON content**

```{r}
content <- content(response, "text", encoding = "UTF-8")
data <- fromJSON(content, flatten = TRUE)
```

`content(response, "text", encoding = "UTF-8")` extracts the text content from the response.\
`fromJSON(content, flatten = TRUE)` parses the JSON content into an R list or data frame.\
\
**7. Extract the SOFR rate data**

```{r}
sofr_data <- data$refRates[sapply(data$refRates$type, function(x) x == "SOFR"), ]
```

`data$refRates[sapply(data$refRates$type, function(x) x == "SOFR"), ]` filters refRates data to include only rows where the type is "SOFR".\
\
**8. Return the most recent SOFR rate**

```{r}
if (nrow(sofr_data) > 0) {
  sofr_data$effectiveDate <- as.Date(sofr_data$effectiveDate)
  latest_date <- max(sofr_data$effectiveDate)
  latest_sofr_rate <- sofr_data$percentRate[sofr_data$effectiveDate == latest_date]
  
  return(latest_sofr_rate)
} else {
  stop("SOFR rate not found in the response.")
}
```

`as.Date(sofr_data$effectiveDate)` converts the effective date to Date type for comparison.\
`max(sofr_data$effectiveDate)` finds the most recent date.\
`sofr_data$percentRate[sofr_data$effectiveDate == latest_date]` retrieves the rate for the most recent date.\
The function returns this rate. If no SOFR rate data is found, it stops with an error message.\
\
**9. Fetch and print the SOFR rate**

```{r}
sofr_rate <- get_sofr_rate()
print(paste("Current SOFR rate:", sprintf("%.2f", sofr_rate)))
```

Calls `get_sofr_rate()` to get the rate.\
`sprintf("%.2f", sofr_rate)` formats the rate to two decimal places.\
`print(paste(...))` prints the formatted SOFR rate to the console.\

## The Script

```{r}
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
print(paste(Sys.Date(),"Current SOFR rate:", sprintf("%.2f", sofr_rate)))
```
