#!/usr/bin/env Rscript

# Set output file path for logging inside the container
output_log <- "/app/5_R_outputs.txt"
cat("R Script Execution Log\n", file = output_log)

# Read the CSV file created by the Bash script
data_set <- read.csv("question_5_d.csv", header = TRUE)

# Function to log messages to both console and file with proper newline
log_message <- function(msg) {
  cat(msg, "\n", sep = "")
  cat(msg, "\n", file = output_log, append = TRUE)
}

# Function to count the number of males and females
count_gender <- function() {
  gender_counts <- table(data_set$Sex)
  log_message("\nCount the Number of Males and Females:")
  log_message(capture.output(print(gender_counts)))
  log_message("--- End of Males and Females Count ---")
}

# Function to count records per species
tally_species_records <- function() {
  species_counts <- table(data_set$Species)
  log_message("\nCount the Number of Records per Species:")
  log_message(capture.output(print(species_counts)))
  log_message("--- End of Species Records Count ---")
}

# Function to sort data by weight
order_by_weight <- function() {
  sorted_data <- data_set[order(data_set$Weight), ]
  log_message("\nSorting the Data by Weight:")
  log_message(capture.output(print(sorted_data)))
  log_message("--- End of Sorting by Weight ---")
}

# Function to plot weight distribution by sex as an image
plot_weight_by_gender <- function() {
  png("weight_by_gender.png", width = 800, height = 600)
  boxplot(Weight ~ Sex, data = data_set, 
          main = "Weight Distribution by Gender",
          xlab = "Gender", ylab = "Weight",
          col = c("lightblue", "lightpink"))
  dev.off()
  log_message("\nPlotting to Image Weight Distribution by Sex:")
  log_message("Image saved as 'weight_by_gender.png'")
  log_message("--- End of Weight Distribution Plot ---")
}

# Menu function to display options and handle user input
show_options <- function() {
  while (TRUE) {
    cat("\nChoose an option:\n")
    cat("1. Count the Number of Males and Females\n")
    cat("2. Count the Number of Records per Species\n")
    cat("3. Sorting the Data by Weight\n")
    cat("4. Plotting to Image Weight Distribution by Sex\n")
    cat("5. Exit\n")
    cat("Enter your choice (1-5): ")
    flush.console()  # Ensure output appears immediately in console
    choice <- as.integer(readLines("stdin", n = 1))
    
    if (is.na(choice) || length(choice) == 0) {
      log_message("Invalid input. Please enter a number between 1 and 5.")
      next
    }
    
    if (choice == 1) count_gender()
    else if (choice == 2) tally_species_records()
    else if (choice == 3) order_by_weight()
    else if (choice == 4) plot_weight_by_gender()
    else if (choice == 5) {
      log_message("Program terminated")
      break
    } else {
      log_message("Invalid choice. Please try again with 1-5.")
    }
  }
}

# Start the menu
show_options()
