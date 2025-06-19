#!/usr/bin/env bash
# Detect cloud waste using Azure resources

set -euo pipefail

RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Ensure Azure CLI is available
if ! command -v az >/dev/null 2>&1; then
  echo -e "${RED}Azure CLI (az) is required but not installed.${RESET}" >&2
  exit 1
fi

# Verify authentication
if ! az account show >/dev/null 2>&1; then
  echo "No Azure credentials found. Launching browser to login..."
  if ! az login >/dev/null; then
    echo -e "${RED}Azure login failed${RESET}" >&2
    exit 1
  fi
fi

SUB_ID=$(az account show --query id -o tsv)

# Utility to fetch current month cost for a resource
get_cost() {
  local id="$1"
  az costmanagement query \
    --type ActualCost \
    --scope "/subscriptions/$SUB_ID" \
    --timeframe MonthToDate \
    --dataset "{\"granularity\":\"None\",\"aggregation\":{\"cost\":{\"name\":\"Cost\",\"function\":\"Sum\"}},\"filter\":{\"dimensions\":{\"name\":\"ResourceId\",\"operator\":\"In\",\"values\":[\"$id\"]}}}" \
    --query "properties.rows[0][1]" -o tsv 2>/dev/null || echo "0"
}

print_row() {
  local id="$1"
  local status="$2"
  local cost="$3"
  local color="$4"
  printf '\u2502 %-40s \u2502 %b%-12s%b \u2502 %8s \u2502\n' "$id" "$color" "$status" "$RESET" "$cost"
}

printf '\n\u250C\u2500\u252C\u2500\u252C\u2500\u2510\n'
printf '\u2502 %-40s \u2502 %-12s \u2502 %-8s \u2502\n' "Resource" "Status" "Monthly $"
printf '\u251C\u2500\u253C\u2500\u253C\u2500\u2524\n'

total=0

# Stopped VMs
while IFS=$'\t' read -r id state; do
  cost=$(get_cost "$id")
  print_row "$id" "$state" "$cost" "$RED"
  total=$(python3 -c "print(float('$total') + float('$cost'))")
done < <(az vm list -d --query "[?powerState=='VM stopped' || powerState=='VM deallocated'].[id,powerState]" -o tsv)

# Unassociated public IPs
while IFS= read -r id; do
  cost=$(get_cost "$id")
  print_row "$id" "unassociated" "$cost" "$YELLOW"
  total=$(python3 -c "print(float('$total') + float('$cost'))")
done < <(az network public-ip list --query "[?ipConfiguration==null].id" -o tsv)

# Unattached managed disks
while IFS= read -r id; do
  cost=$(get_cost "$id")
  print_row "$id" "unattached" "$cost" "$YELLOW"
  total=$(python3 -c "print(float('$total') + float('$cost'))")
done < <(az disk list --query "[?managedBy==null].id" -o tsv)

printf '\u2514\u2500\u2534\u2500\u2534\u2500\u2518\n'
printf "\nEstimated monthly waste: %b$%.2f%b\n" "$RED" "$total" "$RESET"
