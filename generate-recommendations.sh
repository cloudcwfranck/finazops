#!/usr/bin/env bash
# Generate cost-saving recommendations from mock audit

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

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

RECOMMENDATIONS=()
for item in "${EC2_INSTANCES[@]}"; do
  IFS=":" read -r id state cost <<< "$item"
  if [[ $state == "stopped" ]]; then
    RECOMMENDATIONS+=("Terminate $id to save \$${cost}/mo")
  fi
done
for item in "${EIPS[@]}"; do
  IFS=":" read -r id status cost <<< "$item"
  if [[ $status == "detached" ]]; then
    RECOMMENDATIONS+=("Release $id to save \$${cost}/mo")
  fi
done
for item in "${EBS_VOLUMES[@]}"; do
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

