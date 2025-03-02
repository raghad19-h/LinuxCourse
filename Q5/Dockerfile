# Use the latest Ubuntu as the base image
FROM ubuntu:latest

# Update package lists and install required tools for the script (gawk for awk, sed for text processing)
RUN apt-get update && apt-get install -y gawk sed

# Set the working directory inside the container
WORKDIR /app

# Copy the Bash script into the container
COPY q5_script.sh /app/

# Make the script executable
RUN chmod +x q5_script.sh

# Run the script when the container starts
CMD ["./q5_script.sh"]
