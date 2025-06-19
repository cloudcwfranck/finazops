#!/usr/bin/env bash
# Detect unused resources in your Azure tenant
set -e

if ! command -v az >/dev/null; then
  echo "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli" >&2
  exit 1
fi

az account show >/dev/null 2>&1 || az login

echo
echo "Stopped or deallocated VMs:"
az vm list -d --query "[?powerState=='VM deallocated'].{VM:name,RG:resourceGroup}" -o table

echo
echo "Unassociated public IPs:"
az network public-ip list --query "[?ipConfiguration==null].[name,resourceGroup]" -o table

echo
echo "Unattached managed disks:"
az disk list --query "[?managedBy==null].[name,resourceGroup]" -o table
