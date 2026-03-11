#!/bin/bash

RESOURCE_GROUP_NAME=asi-group
STORAGE_ACCOUNT_NAME=asi$RANDOM
CONTAINER_NAME=asi

# Create resource group
az group create --name $RESOURCE_GROUP_NAME \
                --location westeurope \
                --tags environment=test project=azure-stateless-infra

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME \
                          --name $STORAGE_ACCOUNT_NAME \
                          --sku Standard_LRS \
                          --encryption-services blob \
                          --allow-blob-public-access false \
                          --min-tls-version TLS1_2

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME