function initialize {

  param (
    [Parameter(Mandatory=$true,Position=0)][string]$env,
    [Parameter(Mandatory=$true,Position=1)][string]$action
  )

  Remove-Item env:TF_VAR*

  $subscriptionName=$(az account show --query name -o tsv)
  $subscriptionId=$(az account show --query id -o tsv)

  Get-Content "$env.env" | Foreach-Object{
      $var = $_.Split('=')
      Set-Item -Path "env:TF_VAR_$($var[0])" -Value $var[1]
  }

  Write-Output "=========================="
  Write-Output "   Running $action $env"
  Write-Output "=========================="
  Write-Output "Azure resources names"
  Write-Output "Subscription:    $subscriptionName"
  Write-Output "SubscriptionId:  $subscriptionId"
  Get-ChildItem env:TF_VAR*
  Write-Output ""
  $confirmation = Read-Host "Are you sure you want $action to proceed(y/n)?"
  if ($confirmation -eq 'n') {
      Write-Output "Exiting"
      exit
  }
}

function terraformInit {

  param (
    [Parameter(Mandatory=$true,Position=0)][string]$env
  )

  Set-Location "./$env"

  terraform init -input=false -backend=true -reconfigure -upgrade `
    -backend-config="resource_group_name=$env:TF_VAR_infra_resource_group" `
    -backend-config="storage_account_name=$env:TF_VAR_infra_storage_account" `
    -backend-config="container_name=$env:TF_VAR_storage_container"
}

function reset {
  Set-Location ..
}