#!/usr/bin/env bash
# Detect cloud waste using mock data and display summary

# ANSI colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Mock data arrays: id:status:monthly_cost
EC2_INSTANCES=(
  "i-001:stopped:10"
  "i-002:running:20"
  "i-003:stopped:15"
)

EIPS=(
  "eipalloc-001:detached:3"
  "eipalloc-002:attached:0"
)

EBS_VOLUMES=(
  "vol-001:unattached:5"
  "vol-002:attached:0"
)

# Print table header
printf "\n\u250C\u2500\u252C\u2500\u252C\u2500\u2510\n"
printf "\u2502 %-12s \u2502 %-8s \u2502 %-11s \u2502\n" "Resource" "Status" "Monthly $"
printf "\u251C\u2500\u253C\u2500\u253C\u2500\u2524\n"

total=0

print_row() {
  local id=$1
  local status=$2
  local cost=$3
  local color=$4
  printf "\u2502 %-12s \u2502 %b%-8s%b \u2502 %4d %7s \u2502\n" "$id" "$color" "$status" "$RESET" "$cost" ""
}

for item in "${EC2_INSTANCES[@]}"; do
  IFS=":" read -r id state cost <<< "$item"
  if [[ $state == "stopped" ]]; then
    print_row "$id" "$state" "$cost" "$RED"
    total=$((total + cost))
  fi
done
for item in "${EIPS[@]}"; do
  IFS=":" read -r id status cost <<< "$item"
  if [[ $status == "detached" ]]; then
    print_row "$id" "$status" "$cost" "$YELLOW"
    total=$((total + cost))
  fi
done
for item in "${EBS_VOLUMES[@]}"; do
  IFS=":" read -r id status cost <<< "$item"
  if [[ $status == "unattached" ]]; then
    print_row "$id" "$status" "$cost" "$YELLOW"
    total=$((total + cost))
  fi
done

printf "\u2514\u2500\u2534\u2500\u2534\u2500\u2518\n"

printf "\nEstimated monthly waste: %b$%d%b\n" "$RED" "$total" "$RESET"

