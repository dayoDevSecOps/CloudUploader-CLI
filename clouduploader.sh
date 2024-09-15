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
    Introduction
    # Check if storage account exists
    if az storage account show --name $StgAcct --resource-group $RgName &>/dev/null
    then
        echo "Storage account $StgAcct exists"

        # Check if container exists
        if az storage container exists --name $Container --account-name $StgAcct --query exists -o tsv | grep -q "true"
        then
            echo "Container $Container exists in storage account $StgAcct"
        fi
    else
        echo "Storage account $StgAcct does not exist"
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


## Check to create new Storage Account
read -p "Do you have a storage account: " NewSTG

if [[ "$NewSTG" == "No" ]]
then
    StorageCheck
    InfraSetUp
else
    StorageCheck
fi

## Argument Parsing
read -p "Enter Path to file or File name: " fileName

## Function to check file locally
function FileCheck()
{
    if [ -d $fileName ] && [ -d $fileName ]
    then
        echo "$fileName exist"
        if [ -r $fileName ]
        then
            echo "$fileName is readable"
    else
        echo "Please check your input or check if file exist"
    fi
}
FileCheck