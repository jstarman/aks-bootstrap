<#
  .SYNOPSIS

  .PARAMETER environment
    Run dev or prod
#>

param (
  [Parameter(Mandatory=$true,Position=0)][string]$env
)

. ./setup.ps1

initialize $env "apply"

terraformInit $env

# Write-Output "Terraform plan"
# terraform plan

Write-Output "Terraform apply"
terraform apply -auto-approve

reset