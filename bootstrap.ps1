<#
  .SYNOPSIS

  .PARAMETER environment
    Run dev or prod
#>

param (
  [Parameter(Mandatory=$true,Position=0)][string]$env
)

Remove-Item env:TF_VAR*

$subscriptionName=$(az account show --query name -o tsv)
$subscriptionId=$(az account show --query id -o tsv)

Get-Content "$env.env" | Foreach-Object{
    $var = $_.Split('=')
    Set-Item -Path "env:TF_VAR_$($var[0])" -Value $var[1]
}

Write-Output "=========================="
Write-Output "   Running Bootstrap $env"
Write-Output "=========================="
Write-Output "Azure resources names"
Write-Output "Subscription:    $subscriptionName"
Write-Output "SubscriptionId:  $subscriptionId"
Get-ChildItem env:TF_VAR*

$confirmation = Read-Host "Are you Sure You Want To Proceed(y/n)?"
if ($confirmation -eq 'n') {
    Write-Host "Exiting"
    exit
}

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

Set-Location "./$env"

terraform init -input=false -backend=true -reconfigure -upgrade `
  -backend-config="resource_group_name=$env:TF_VAR_infra_resource_group" `
  -backend-config="storage_account_name=$env:TF_VAR_infra_storage_account" `
  -backend-config="container_name=$env:TF_VAR_storage_container"

  Set-Location ..