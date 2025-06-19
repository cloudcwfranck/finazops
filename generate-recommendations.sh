#!/usr/bin/env bash
# Generate cost-saving recommendations from Azure resources
set -e

if ! command -v az >/dev/null; then
  echo "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli" >&2
  exit 1
fi

az account show >/dev/null 2>&1 || az login

recs=()
while IFS= read -r id; do
  recs+=("Delete unattached disk $id")
done < <(az disk list --query "[?managedBy==null].id" -o tsv)

while IFS= read -r id; do
  recs+=("Release public IP $id")
done < <(az network public-ip list --query "[?ipConfiguration==null].id" -o tsv)

while IFS= read -r id; do
  recs+=("Delete stopped VM $id")
done < <(az vm list -d --query "[?powerState=='VM deallocated'].id" -o tsv)

if [ ${#recs[@]} -eq 0 ]; then
  echo "No recommendations. Resources are optimised."
else
  echo "Recommendations:"
  for r in "${recs[@]}"; do
    echo "- $r"
  done
fi
