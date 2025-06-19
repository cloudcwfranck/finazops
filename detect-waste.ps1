# Detect waste in your Azure tenant using the Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli"; exit 1
}

if (-not (az account show 2>$null)) { az login }

Write-Host ""
Write-Host "Stopped or deallocated VMs:" 
az vm list -d --query "[?powerState=='VM deallocated'].{VM:name,RG:resourceGroup}" -o table

Write-Host ""
Write-Host "Unassociated public IPs:" 
az network public-ip list --query "[?ipConfiguration==null].[name,resourceGroup]" -o table

Write-Host ""
Write-Host "Unattached managed disks:" 
az disk list --query "[?managedBy==null].[name,resourceGroup]" -o table
