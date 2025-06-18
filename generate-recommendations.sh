#!/usr/bin/env bash
# Generate cost-saving recommendations from mock audit

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

VMS=(
  "vm-001:stopped:10"
  "vm-002:running:20"
  "vm-003:stopped:15"
)

PUBLIC_IPS=(
  "pip-001:unassociated:3"
  "pip-002:associated:0"
)

MANAGED_DISKS=(
  "disk-001:unattached:5"
  "disk-002:attached:0"
)

RECOMMENDATIONS=()
for item in "${VMS[@]}"; do
  IFS=":" read -r id state cost <<< "$item"
  if [[ $state == "stopped" ]]; then
    RECOMMENDATIONS+=("Terminate $id to save \$${cost}/mo")
  fi
done
for item in "${PUBLIC_IPS[@]}"; do
  IFS=":" read -r id status cost <<< "$item"
  if [[ $status == "unassociated" ]]; then
    RECOMMENDATIONS+=("Release $id to save \$${cost}/mo")
  fi
done
for item in "${MANAGED_DISKS[@]}"; do
  IFS=":" read -r id status cost <<< "$item"
  if [[ $status == "unattached" ]]; then
    RECOMMENDATIONS+=("Delete $id to save \$${cost}/mo")
  fi
done

printf "\n\u250C\u2500\u252C\u2500\u2510\n"
printf "\u2502 %-40s \u2502\n" "Recommendation"
printf "\u251C\u2500\u253C\u2500\u2524\n"
for rec in "${RECOMMENDATIONS[@]}"; do
  printf "\u2502 %-40s \u2502\n" "$rec"
done
printf "\u2514\u2500\u2534\u2500\u2518\n"

