#!/usr/bin/env bash
# Check budgets for different profiles using mock data

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Mock data: profile:limit:actual
BUDGETS=(
  "profile-02:100:90"
  "profile-03:120:130"
)

printf "\n\u250C\u2500\u252C\u2500\u252C\u2500\u2510\n"
printf "\u2502 %-10s \u2502 %-10s \u2502 %-10s \u2502\n" "Profile" "Limit" "Actual"
printf "\u251C\u2500\u253C\u2500\u253C\u2500\u2524\n"

for item in "${BUDGETS[@]}"; do
  IFS=":" read -r profile limit actual <<< "$item"
  if (( actual > limit )); then
    color=$RED
  else
    color=$GREEN
  fi
  printf "\u2502 %-10s \u2502 %4d       \u2502 %b%4d%b     \u2502\n" "$profile" "$limit" "$color" "$actual" "$RESET"
done

printf "\u2514\u2500\u2534\u2500\u2534\u2500\u2518\n"

