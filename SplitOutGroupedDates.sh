#!/bin/bash

# Define the input and output file paths
input_file="path to grouped test file/GroupedDated.txt"  # Change this to your actual file path
output_directory="Path where you want the split txt files by group /SplitGroupTextFiles"  # Change this to your desired output directory

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Initialize variables
current_group=""
current_dates=()

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line indicates a new group
    if [[ $line =~ \*\*Group\ ([0-9]+)\:\*\* ]]; then
        # If we have collected dates for a previous group, write them to a file
        if [[ -n $current_group ]]; then
            output_file="$output_directory/Group$current_group.txt"
            printf "%s\n" "${current_dates[@]}" > "$output_file"
        fi
        # Reset for the new group
        current_group="${BASH_REMATCH[1]}"
        current_dates=()
    elif [[ $line =~ ^[0-9]{4}\ [0-9]{2}\ [0-9]{2} ]]; then
        # If the line contains a date, add it to the current dates array
        current_dates+=("$line")
    fi
done < "$input_file"

# Write the last group if it exists
if [[ -n $current_group ]]; then
    output_file="$output_directory/Group$current_group.txt"
    printf "%s\n" "${current_dates[@]}" > "$output_file"
fi

echo "Files created successfully in $output_directory"
