# Generate recommendations based on Azure resources
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli"; exit 1
}

if (-not (az account show 2>$null)) { az login }

$recs = @()
$disks = az disk list --query "[?managedBy==null].id" -o tsv
foreach ($d in $disks) { $recs += "Delete unattached disk $d" }
$ips = az network public-ip list --query "[?ipConfiguration==null].id" -o tsv
foreach ($ip in $ips) { $recs += "Release public IP $ip" }
$vms = az vm list -d --query "[?powerState=='VM deallocated'].id" -o tsv
foreach ($vm in $vms) { $recs += "Delete stopped VM $vm" }

if ($recs.Count -eq 0) {
    Write-Host "No recommendations. Resources are optimised."
} else {
    Write-Host "Recommendations:" 
    foreach ($r in $recs) { Write-Host "- $r" }
}
