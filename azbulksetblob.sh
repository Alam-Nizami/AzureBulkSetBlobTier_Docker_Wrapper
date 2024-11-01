#!/bin/bash

# Variables
STORAGE_ACCOUNT_NAME="YourStorageAccName"    # Replace with your storage account name
STORAGE_ACCOUNT_KEY="YourStorageAccKey"      # Replace with your storage account key
CONTAINER_NAME="YourStorageAccContainerName" # Replace with your storage account container name

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_dates_file>"
    exit 1
fi

# Read the input file
DATES_FILE="$1"

# Check if the file exists
if [ ! -f "$DATES_FILE" ]; then
    echo "File not found: $DATES_FILE"
    exit 1
fi

# Loop through each line in the dates file
while IFS=' ' read -r YEAR MONTH DAY; do
    # Construct the folder path based on provided parameters
    FOLDER_PATH=""
    if [ -n "$YEAR" ]; then
        FOLDER_PATH="$YEAR"
    fi
    if [ -n "$MONTH" ]; then
        FOLDER_PATH="$FOLDER_PATH/$MONTH"
    fi
    if [ -n "$DAY" ]; then
        FOLDER_PATH="$FOLDER_PATH/$DAY"
    fi

    # Create a unique output file for each date
    OUTPUT_FILE="archived_blobs_update_${YEAR}_${MONTH}_${DAY}.txt"

    # Clear the output file
    echo "Updating Archived Blobs in Folder: $FOLDER_PATH" > "$OUTPUT_FILE"
    echo "==============================================" >> "$OUTPUT_FILE"

    # List blobs in the specified folder and filter for archived blobs
    archived_blobs=$(az storage blob list --account-name "$STORAGE_ACCOUNT_NAME" --account-key "$STORAGE_ACCOUNT_KEY" --container-name "$CONTAINER_NAME" --prefix "$FOLDER_PATH/" --query "[?properties.blobTier=='Archive'].{Name:name}" -o tsv --timeout 300)

    # Check if there are archived blobs
    if [ -z "$archived_blobs" ]; then
        echo "No archived blobs found in folder: $FOLDER_PATH" >> "$OUTPUT_FILE"
    else
        #echo "Archived blobs in folder $FOLDER_PATH:" >> "$OUTPUT_FILE"
        #echo "$archived_blobs" >> "$OUTPUT_FILE"

        # Loop through each archived blob and update its tier to Cool with high rehydrate priority
        echo "$archived_blobs" | while IFS= read -r archived_blob; do
            #echo "Updating blob tier to Cool with high rehydrate priority: $archived_blob" >> "$OUTPUT_FILE"
            
            # Set the blob's tier to Cool with high rehydrate priority
            set_tier_result=$(az storage blob set-tier --account-name "$STORAGE_ACCOUNT_NAME" --account-key "$STORAGE_ACCOUNT_KEY" --container-name "$CONTAINER_NAME" --name "$archived_blob" --tier Cool --rehydrate-priority High 2>&1)
            
            # Check if the update was successful
            # if [ $? -eq 0 ]; then
            #     #echo "Successfully updated blob tier to Cool: $archived_blob" >> "$OUTPUT_FILE"
            # else
            #     #echo "Failed to update blob tier: $archived_blob. Error: $set_tier_result" >> "$OUTPUT_FILE"
            # fi
        done
    fi

    echo "Archived blobs update process completed for $FOLDER_PATH. Check $OUTPUT_FILE for details."
done < "$DATES_FILE"
