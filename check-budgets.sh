#!/usr/bin/env bash
# Show Azure budgets for the current subscription
set -e

if ! command -v az >/dev/null; then
  echo "Azure CLI is required. Install from https://learn.microsoft.com/cli/azure/install-azure-cli" >&2
  exit 1
fi

az account show >/dev/null 2>&1 || az login

echo
echo "Budgets:"
az consumption budget list --query "[].{Subscription:name,Limit:amount,Current:currentSpend.amount}" -o table
