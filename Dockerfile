# Use the official Azure CLI image
FROM mcr.microsoft.com/azure-cli

# Set the working directory
WORKDIR /app

# Copy the Bash script into the container
COPY azbulksetblob.sh .

# Accept the text file as a build argument
ARG TXT_FILE

# Copy the specified text file into the container
# Use a fixed name for the file in the container
COPY ${TXT_FILE} ./dates.txt
COPY ${TXT_FILE} .
# Make the script executable
RUN chmod +x azbulksetblob.sh

# Set the entry point to run the Bash script with the input file
ENTRYPOINT ["./azbulksetblob.sh", "dates.txt"]


