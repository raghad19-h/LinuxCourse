#!/bin/bash

# Set up file paths for output and SQLite database
LOG_OUTPUT="5_output_sql.txt"
DB_FILE=""  # SQLite database file

# Helper function to output messages to console and file
output_log() {
    echo "$1" >> "$LOG_OUTPUT"
    echo "$1"
}

# Check if the SQLite database is available
check_db_availability() {
    if [ ! -f "$DB_FILE" ]; then
        output_log "Warning: No SQLite database exists. Please create one with option 1 first."
        return 1
    fi
    return 0
}

# Create a new SQLite database and table
make_db() {
    echo -n "What would you like to name the SQLite database?"
    read db_name
    DB_FILE="$db_name"
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_collected TEXT,
    species TEXT,
    sex TEXT,
    weight REAL
);
EOF
    output_log "New SQLite database created: $DB_FILE with table 'data'"
}

# Display all table content with numbered rows (skipping header logic, since SQLite handles it)
display_csv_data() {
    if check_db_availability; then
        output_log "Listing all entries with row numbers from $DB_FILE:"
        sqlite3 "$DB_FILE" "SELECT row_number() OVER () AS row_num, date_collected, species, sex, weight FROM data;" | nl -w1 -s ". " | sed 's/^[[:space:]]*//'
        output_log "Finished listing all entries with row numbers"
    fi
}

# Add a new row to the SQLite table
insert_row() {
    if check_db_availability; then
        echo -n "Enter collection date (e.g., 1/8): "
        read date_input
        echo -n "Enter Species type (e.g., OT): "
        read species_type
        echo -n "Enter sex (M/F): "
        read gender_input
        echo -n "Enter weight: "
        read weight_input
        sqlite3 "$DB_FILE" "INSERT INTO data (date_collected, species, sex, weight) VALUES ('$date_input', '$species_type', '$gender_input', $weight_input);"
        output_log "New row added: $date_input,$species_type,$gender_input,$weight_input to $DB_FILE"
    fi
}

# Show all items for a specific species and calculate average weight
analyze_type_weight() {
    if check_db_availability; then
        echo -n "Which Specie would you like to search ? "
        read specie_type
        output_log "Entries for species '$specie_type' in $DB_FILE:"
        sqlite3 "$DB_FILE" "SELECT date_collected, species, sex, weight FROM data WHERE species = '$specie_type';" | tail -n +1
        avg_weight=$(sqlite3 "$DB_FILE" "SELECT AVG(weight) FROM data WHERE species = '$specie_type';")
        echo "Average weight for $specie_type: $avg_weight" | tee -a "$LOG_OUTPUT"
        output_log "Displayed entries and average weight for specie type '$specie_type': $avg_weight"
    fi
}

# Show all items for a specific species and sex, and calculate average weight
evaluate_type_gender_weight() {
    if check_db_availability; then
        echo -n "Which specie type would you like to search? "
        read specie_type
        echo -n "Which gender? "
        read gender_input
        output_log "Entries for species '$specie_type' and gender '$gender_input' in $DB_FILE:"
        sqlite3 "$DB_FILE" "SELECT date_collected, species, sex, weight FROM data WHERE species = '$specie_type' AND sex = '$gender_input';" | tail -n +1
        avg_weight=$(sqlite3 "$DB_FILE" "SELECT AVG(weight) FROM data WHERE species = '$specie_type' AND sex = '$gender_input';")
        echo "Average weight for $specie_type and gender $gender_input: $avg_weight" | tee -a "$LOG_OUTPUT"
        output_log "Displayed entries and average weight for specie type '$specie_type' and gender '$gender_input': $avg_weight"
    fi
}

# Save current table data to a new SQLite file
export_to_csv() {
    if check_db_availability; then
        echo -n "Name the new SQLite file for saving: "
        read new_file
        cp "$DB_FILE" "$new_file"
        output_log "Saved current data to new SQLite file: $new_file"
    fi
}

# Delete a row by its index (using rowid from SQLite)
erase_row() {
    if check_db_availability; then
        echo -n "Which row index would you like to delete? "
        read row_index
        sqlite3 "$DB_FILE" "DELETE FROM data WHERE rowid = $row_index;"
        output_log "Row $row_index deleted from $DB_FILE"
    fi
}

# Update the weight of a row by its index (using rowid from SQLite)
adjust_weight() {
    if check_db_availability; then
        echo -n "Which row index would you like to update? "
        read row_index
        echo -n "Enter the new weight value: "
        read new_weight
        sqlite3 "$DB_FILE" "UPDATE data SET weight = $new_weight WHERE rowid = $row_index;"
        output_log "Updated weight for row $row_index to $new_weight in $DB_FILE"
    fi
}

# Display menu and handle user choices without clearing screen
display_menu() {
    while true; do
        echo "Choose an option:"
        echo "1. CREATE SQLite DB"
        echo "2. Display all TABLE DATA with row INDEX"
        echo "3. Read user input for new row"
        echo "4. Read Species (e.g., OT) and display all items of that species and the AVG weight"
        echo "5. Read Species and Sex (M/F) and display all items of species-sex"
        echo "6. Save last output to new SQLite file"
        echo "7. Delete row by row index"
        echo "8. Update weight by row index"
        echo "9. Exit"
        echo -n "Please select an option (1-9): "
        read option

        case $option in
            1) make_db; display_menu ;;
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
