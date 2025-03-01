#!/bin/bash

# Define paths and variables
BASE_DIR=~/Linux_Course_Work/Q4
VENV_DIR=~/env_plant
INPUT_CSV="$1"  # Path to the CSV file passed as the first parameter
LOG_PATH="./plants_logs.txt"

# Function to log messages to the log file
write_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_PATH"
}

# Check if virtual environment directory exists, create it if not
if [ ! -d "$VENV_DIR" ]; then
  write_log "Setting up new virtual environment in $VENV_DIR"
  python3 -m venv "$VENV_DIR"
  if [ "$?" -ne 0 ]; then
    write_log "Failed to initialize virtual environment!"
    exit 1
  fi
else
  write_log "Virtual environment already present at $VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate" || {
  write_log "Activation of virtual environment failed!"
  exit 1
}

# Check if dependencies file exists, create it if not
DEPS_FILE="$BASE_DIR/dependencies.list"
if [ ! -f "$DEPS_FILE" ]; then
  write_log "Dependencies file missing, creating $DEPS_FILE"
  echo "matplotlib" > "$DEPS_FILE"
  echo "numpy" >> "$DEPS_FILE"
  echo "pandas" >> "$DEPS_FILE"
  write_log "Dependencies file created"
fi

# Install dependencies if not already installed
write_log "Installing required packages from $DEPS_FILE"
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r "$DEPS_FILE"
if [ "$?" -ne 0 ]; then
  write_log "Package installation failed!"
  deactivate
  exit 1
fi

# Ensure the CSV file exists
[ -f "$INPUT_CSV" ] || {
  write_log "CSV file $INPUT_CSV not found!"
  deactivate
  exit 1
}

# Process each row in the CSV file
write_log "Starting to process CSV: $INPUT_CSV"
while IFS=',' read -r plant_name height_vals leaf_vals weight_vals; do
  # Skip the header row
  [[ "$plant_name" == "Plant" ]] && continue

  write_log "Handling data for plant: $plant_name"

  # Create a directory for the plant if it doesn't exist
  PLANT_FOLDER="$BASE_DIR/$plant_name"
  [ -d "$PLANT_FOLDER" ] || {
    mkdir "$PLANT_FOLDER"
    write_log "Created folder for $plant_name at $PLANT_FOLDER"
  }

  # Clean quotes from the data
  heights=($(echo "$height_vals" | sed 's/"//g'))
  leaves=($(echo "$leaf_vals" | sed 's/"//g'))
  weights=($(echo "$weight_vals" | sed 's/"//g'))

  # Run the Python script with the parameters for this plant
  write_log "Running Python script for $plant_name with height=${heights[*]}, leaf_count=${leaves[*]}, dry_weight=${weights[*]}"
  python3 "$BASE_DIR/plant_plots.py" --plant "$plant_name" --height "${heights[@]}" --leaf_count "${leaves[@]}" --dry_weight "${weights[@]}"
  if [ "$?" -ne 0 ]; then
    write_log "Python script failed for $plant_name!"
    continue
  fi

  # Move generated plot files to the plant's directory
  for plot in "${plant_name}_scatter.png" "${plant_name}_histogram.png" "${plant_name}_line_plot.png"; do
    mv "$BASE_DIR/$plot" "$PLANT_FOLDER/"
  done
  write_log "Plots for $plant_name moved to $PLANT_FOLDER"

done < "$INPUT_CSV"

write_log "Finished processing all plants successfully."
deactivate
