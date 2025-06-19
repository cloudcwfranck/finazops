# Show Azure budgets using the Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli"; exit 1
}

if (-not (az account show 2>$null)) { az login }

Write-Host ""
Write-Host "Budgets:" 
az consumption budget list --query "[].{Subscription:name,Limit:amount,Current:currentSpend.amount}" -o table
