<#
  .SYNOPSIS

  .PARAMETER environment
    Run dev or prod
#>

param (
  [Parameter(Mandatory=$true,Position=0)][string]$env
)

. ./setup.ps1

initialize $env "bootstrap"

Write-host "Creating resource group $env:TF_VAR_infra_resource_group"
az group create --resource-group $env:TF_VAR_infra_resource_group --location $env:TF_VAR_location

Write-host "Create storage account $env:TF_VAR_infra_storage_account"
az storage account create --resource-group $env:TF_VAR_infra_resource_group `
--name $env:TF_VAR_infra_storage_account `
--sku Standard_LRS `
--location $env:TF_VAR_location `
--kind StorageV2 `
--https-only true `
--allow-blob-public-access false

$key=$(az storage account keys list --account-name $env:TF_VAR_infra_storage_account --query "[0].value" -o tsv)
Write-host "Create storage container $env:TF_VAR_storage_container"
az storage container create --account-name $env:TF_VAR_infra_storage_account --name $env:TF_VAR_storage_container --account-key "$key"

terraformInit $env

reset