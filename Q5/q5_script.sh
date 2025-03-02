#!/bin/bash

# Set up file paths for output and CSV tracking
LOG_OUTPUT="5_output.txt"
ACTIVE_CSV=""

# Helper function to output messages to console and file
output_log() {
    echo "$1" >> "$LOG_OUTPUT"
    echo "$1"
}

# Check if a CSV file is available
check_csv_availability() {
    if [ -z "$ACTIVE_CSV" ] || [ ! -f "$ACTIVE_CSV" ]; then
        output_log "Warning: No CSV file available. Please create one with option 1 first."
        return 1
    fi
    return 0
}

# Create a new CSV file with user-specified name
make_csv() {
    echo -n "What would you like to name the CSV file? "
    read file_name
    echo "Date collected,Species,Sex,Weight" > "$file_name"
    ACTIVE_CSV="$file_name"
    output_log "New CSV file created: $file_name with column headers"
}

# Display all CSV content with numbered rows (skipping header)
display_csv_data() {
    if check_csv_availability; then
        output_log "Listing all CSV entries with row numbers from $ACTIVE_CSV:"
        # Print header as is
        head -n 1 "$ACTIVE_CSV"
        # Number the remaining lines starting from 1 (skip header)
        tail -n +2 "$ACTIVE_CSV" | nl -w1 -s ". " | sed 's/^[[:space:]]*//'
        output_log "Finished listing all entries with row numbers"
    fi
}

# Add a new row to the existing CSV
insert_row() {
    if check_csv_availability; then
        echo -n "Enter collection date (e.g., 1/8): "
        read date_input
        echo -n "Enter Species type (e.g., PF): "
        read species_type
        echo -n "Enter sex (M/F): "
        read gender_input
        echo -n "Enter weight: "
        read weight_input
        echo "$date_input,$species_type,$gender_input,$weight_input" >> "$ACTIVE_CSV"
        output_log "New row added: $date_input,$species_type,$gender_input,$weight_input to $ACTIVE_CSV"
    fi
}

# Show all items for a specific animal type and calculate average weight
analyze_type_weight() {
    if check_csv_availability; then
        echo -n "Which Specie would you like to search (e.g., OT)? "
        read specie_type
        output_log "Entries for animal type '$specie_type' in $ACTIVE_CSV:"
        # Filter rows for the specific specie_type (skip header) and print
        grep -A9999 "^[^,]*,$specie_type," "$ACTIVE_CSV" | tail -n +2
        # Calculate average weight using awk on filtered data
        avg_weight=$(grep -A9999 "^[^,]*,$specie_type," "$ACTIVE_CSV" | tail -n +2 | awk -F',' '{sum+=$4; count++} END {if (count > 0) printf "%.2f", sum/count}')
        echo "Average weight for $specie_type: $avg_weight" | tee -a "$LOG_OUTPUT"
        output_log "Displayed entries and average weight for specie type '$specie_type': $avg_weight"
    fi
}

# Show all items for a specific specie type and sex, and calculate average weight
evaluate_type_gender_weight() {
    if check_csv_availability; then
        echo -n "Which specie type would you like to search (e.g., OT)? "
        read specie_type
        echo -n "Which gender (M/F)? "
        read gender_input
        output_log "Entries for animal type '$specie_type' and gender '$gender_input' in $ACTIVE_CSV:"
        # Filter rows for specific specie type and gender (skip header)
        grep -A9999 "^[^,]*,$specie_type,$gender_input," "$ACTIVE_CSV" | tail -n +2
        # Calculate average weight using awk on filtered data
        avg_weight=$(grep -A9999 "^[^,]*,$specie_type,$gender_input," "$ACTIVE_CSV" | tail -n +2 | awk -F',' '{sum+=$4; count++} END {if (count > 0) printf "%.2f", sum/count}')
        echo "Average weight for $specie_type and gender $gender_input: $avg_weight" | tee -a "$LOG_OUTPUT"
        output_log "Displayed entries and average weight for specie type '$specie_type' and gender '$gender_input': $avg_weight"
    fi
}

# Save current CSV data to a new file
export_to_csv() {
    if check_csv_availability; then
        echo -n "Name the new CSV file for saving: "
        read new_file
        cp "$ACTIVE_CSV" "$new_file"
        output_log "Saved current data to new CSV: $new_file"
    fi
}

# Delete a row by its index (accounting for header)
erase_row() {
    if check_csv_availability; then
        echo -n "Which row index would you like to delete? "
        read row_index
        target_row=$((row_index + 1))
        sed -i "${target_row}d" "$ACTIVE_CSV"
        output_log "Row $row_index deleted from $ACTIVE_CSV"
    fi
}

# Update the weight of a row by its index (accounting for header)
adjust_weight() {
    if check_csv_availability; then
        echo -n "Which row index would you like to update? "
        read row_index
        echo -n "Enter the new weight value: "
        read new_weight
        target_row=$((row_index + 1))
        sed -i "${target_row}s/\([^,]*,[^,]*,[^,]*,\)[0-9]*\.?[0-9]*/\1$new_weight/" "$ACTIVE_CSV"
        output_log "Updated weight for row $row_index to $new_weight in $ACTIVE_CSV"
    fi
}

# Display menu and handle user choices without clearing screen
display_menu() {
    while true; do
        echo "Choose an option:"
        echo "1. CREATE CSV by name"
        echo "2. Display all CSV DATA with row INDEX"
        echo "3. Read user input for new row"
        echo "4. Read Species (e.g. OT) and display all items of that species and the AVG weight"
        echo "5. Read Species and Sex (M/F) and display all items of species-sex"
        echo "6. Save last output to new CSV file"
        echo "7. Delete row by row index"
        echo "8. Update weight by row index"
        echo "9. Exit"
        echo -n "Please select an option (1-9): "
        read option

        case $option in
            1) make_csv; display_menu ;;
            2) display_csv_data; display_menu ;;
            3) insert_row; display_menu ;;
            4) analyze_type_weight; display_menu ;;
            5) evaluate_type_gender_weight; display_menu ;;
            6) export_to_csv; display_menu ;;
            7) erase_row; display_menu ;;
            8) adjust_weight; display_menu ;;
            9) output_log "Program ended"; exit 0 ;;
            *) output_log "Invalid selection. Please choose 1-9."; display_menu ;;
        esac
    done
}

# Start the program
display_menu
