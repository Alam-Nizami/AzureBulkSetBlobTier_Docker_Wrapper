#!/bin/bash

# Set your resource group and Azure Container Registry (ACR) variables
RG="DockerContainerRG" #Replace with a RG you created to house the containers.
ACR="YourContainerRegistry" #Replace with the name of your container registry.
REGION="eastus" #Replace with the region your storage account and containers are in. Make sure they are in same region. 

ACRSVR="YourContainerRegistryServer" #Replace with Login Server under Access Keys section of container registry in Azure Portal.  
ACRUSER="YourContainerRegistryUserName" #Replace from under Access Keys section of container registry in Azure Portal.     
ACRPWD="YourContainerRegistryPassword" #Replace from under Access Keys section of container registry in Azure Portal.

# Loop through the text files (Group1.txt to Group52.txt)
for i in {1..52}; do
    # Construct the file name and corresponding ACI and image names
    TXT_FILE="./Group${i}.txt"

    # Name the container instances. Change env name to your env, change cool to the tier you are updating to. g stands for group.
    ACI="az-bulk-set-env-name-blobs-cool-g${i}"
    # Docker image name based on groups of data in txt files. 
    IMAGE_NAME="azbulksetblobtiersg${i}:latest"

    # Build the Docker image with the current text file. Update path to folder where you have all the files for this process. 
    az acr build -r $ACR "Update This Path ./AzureBulkSetBlobTier_Docker_Wrapper" -f Dockerfile --image $IMAGE_NAME --build-arg TXT_FILE=$TXT_FILE

    # Wait for the image to be available in ACR
    while true; do
        # Check if the image exists in the ACR
        RESPONSE=$(az acr repository show --name $ACR --image $IMAGE_NAME --username $ACRUSER --password $ACRPWD 2>&1)
        # Check if the response contains the lastUpdateTime field
        if echo "$RESPONSE" | jq -e '.createdTime' > /dev/null; then
            echo "Image $IMAGE_NAME is available."
            break
        elif echo "$RESPONSE" | grep -q "Error: the specified tag does not exist."; then
            echo "Waiting for image $IMAGE_NAME to be available..."
            sleep 10  # Wait for 10 seconds before checking again
        else
            echo "An unexpected error occurred: $RESPONSE"
            break
        fi
    done

    # Create a new Azure Container Instance for the current text file
    az container create \
        --name $ACI \
        --resource-group $RG \
        --location $REGION \
        --cpu 2 \
        --memory 4 \
        --registry-login-server $ACRSVR \
        --registry-username $ACRUSER \
        --registry-password $ACRPWD \
        --image "$ACRSVR/$IMAGE_NAME" \
        --restart-policy Never \
        --no-wait
done
