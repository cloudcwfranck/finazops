#!/usr/bin/env bash
# Cross-platform initialization helper for the FinOps toolkit
set -e

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

printf "${GREEN}Initializing FinOps toolkit...${RESET}\n"

if ! command -v python3 >/dev/null 2>&1; then
  printf "${RED}Python 3 is not installed.${RESET}\n"
  case "$(uname -s)" in
    Darwin)
      printf "${YELLOW}Install it with Homebrew: brew install python@3${RESET}\n";;
    Linux)
      printf "${YELLOW}On Ubuntu run: sudo apt install python3 python3-venv${RESET}\n";;
    *)
      printf "${YELLOW}Please install Python 3 for your operating system.${RESET}\n";;
  esac
  exit 1
fi

# Ensure Azure CLI is available and authenticated
if ! command -v az >/dev/null 2>&1; then
  printf "${RED}Azure CLI is required but not found.${RESET}\n"
  case "$(uname -s)" in
    Darwin)
      printf "${YELLOW}Install it with Homebrew: brew install azure-cli${RESET}\n";;
    Linux)
      printf "${YELLOW}On Ubuntu run: sudo apt install azure-cli${RESET}\n";;
    *)
      printf "${YELLOW}Please install Azure CLI for your operating system.${RESET}\n";;
  esac
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  printf "${GREEN}Authenticating with az login...${RESET}\n"
  az login
fi

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
  printf "${GREEN}Creating virtual environment .venv${RESET}\n"
  python3 -m venv .venv
fi

# Activate the environment
# shellcheck disable=SC1091
source .venv/bin/activate
printf "${GREEN}Virtual environment activated${RESET}\n"

# Install requirements
python3 -m pip install --upgrade pip >/dev/null
python3 -m pip install -r requirements.txt
python3 -m pip install -e . >/dev/null
printf "${GREEN}Dependencies installed${RESET}\n"

printf "${GREEN}All set! Run 'source .venv/bin/activate' to use the environment.${RESET}\n"
