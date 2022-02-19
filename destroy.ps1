<#
  .SYNOPSIS

  .PARAMETER environment
    Run dev or prod
#>

param (
  [Parameter(Mandatory=$true,Position=0)][string]$env
)

. ./setup.ps1

initialize $env "destroy"

terraformInit $env

terraform destroy -auto-approve

reset

# For complete clean up including terraform backend state
# az group delete --name [ENV INFRA STORE HERE] --yes