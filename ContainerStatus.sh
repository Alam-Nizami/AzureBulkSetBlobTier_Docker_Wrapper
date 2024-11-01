#!/bin/bash

# Set your resource group name
RESOURCE_GROUP="ContainerRG"  # Replace with your actual resource group name

# Output file
OUTPUT_FILE="containerstatus"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Loop through container instances from 1 to 52
for i in {1..52}; do
    # Construct the container name
    CONTAINER_NAME="az-bulk-set-env-name-blobs-cool-g${i}" #update to name from AzureBulkSetBlobTier_Docker_Wrapper.sh script.

    # Check the status of the container
    STATUS=$(az container show --name "$CONTAINER_NAME" --resource-group "$RESOURCE_GROUP" --query "instanceView.state" -o tsv 2>/dev/null)

    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Container: $CONTAINER_NAME - Status: $STATUS" >> "$OUTPUT_FILE"
    else
        echo "Container: $CONTAINER_NAME - Status: Not found or error occurred." >> "$OUTPUT_FILE"
    fi
done

echo "Container status has been written to $OUTPUT_FILE."


