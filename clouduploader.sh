#!/bin/bash

echo "*******  Welcome to the Cloud Uploader a CLI Based Tool  ************"
function Authenticate()
{  
    az login
}

Authenticate
################## Introduction ####################
function Introduction()
{
    read -p "To begin we need to create a Resource Group: " RgName
    read -p "Resource Group Location: " RgLocation
    read -p "We need to create Storage Account: " StgAcct
    read -p "We need a Blob: " Container
}

#Function to check Storage account
function StorageCheck()
{
    # Check if storage account exists
    if az storage account show --name $StgAcct --resource-group $RgName &>/dev/null; then
        local result="Storage account $StgAcct exists"
        echo "$result"

        # Check if container exists
        if az storage container exists --name $Container --account-name $StgAcct --query exists -o tsv | grep -q "true"; then
            local result="Container $Container exists in storage account $StgAcct"          
            echo "$result"
        fi
    else
        local result="Storage account $StgAcct does not exist"
        echo "$result"
    fi
}

## Set Infrastructure
function InfraSetUp()
{
    # Create resource group 
    az group create --resource-group $RgName --location $RgLocation
    # Create Storage Account
    az storage account create \
            --resource-group $RgName \
            --name $StgAcct \
            --location $RgLocation \
            --sku Standard_LRS \
            --kind StorageV2
    # Create Container
    az storage container create \
            --name $Container \
            --account-name $StgAcct \
            --auth-mode login 
}

## Function to check file locally
function FileCheck()
{
    # Use find to search for the file (full path or partial)
    foundFile=$(find "$(dirname "$fileName")" -name "$(basename "$fileName")" 2>/dev/null)

    if [ -f "$foundFile" ]; then
        echo "$fileName exists at $foundFile"
        
        # Check if the file is readable
        if [ -r "$foundFile" ]; then
            echo "$fileName is readable"
        else
            echo "$fileName is not readable"
        fi
    else
        echo "File does not exist or incorrect path. Please check your input."
    fi
}

## Check to create new Storage Account
read -p "Do you have a storage account: " NewSTG

if [[ "$NewSTG" == "No" ]]; then
    Introduction
    InfraSetUp
elif [[ "$NewSTG" == "Yes" ]]; then
    read -p "Please Enter Storage Name: " StgAcct
    read -p "Please Enter Resource Group: " RgName
    read -p "Please Enter Container Name: " Container
    STORAGE=$(StorageCheck $StgAcct $RgName $Container) >> output.txt
    echo "***********Check Storage Account Existence***********"
    if [[ $STORAGE == "Storage account $StgAcct exists" ]]; then
        echo "There is no existing Container, Please Create one before moving forward"
        InfraSetUp
    else
        echo "Please proceed with Uploading"
    fi
fi

## Argument Parsing
read -p "Enter Path to file or File name: " fileName
FileCheck

STORAGE_KEY=$(az storage account keys list --resource-group $RgName --account-name $StgAcct --query '[0].value' --output tsv)

function FileUploader()
{
    az storage blob upload \
            --account-name $StgAcct \
            --account-key $STORAGE_KEY \
            --container-name $Container \
            --name $(basename "$fileName") \
            --file $fileName
}

FileUploader