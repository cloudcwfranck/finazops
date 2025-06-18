# FinOps CLI Toolkit

This repository contains a simple cross-platform FinOps command line toolkit written in Bash and PowerShell. The scripts simulate detection of cloud waste, budget checks, and cost‑saving recommendations using local mock data. Output is styled with ANSI colors and Unicode tables similar to the screenshot referenced in the project description.

## Scripts

- `detect-waste.sh` / `detect-waste.ps1` – find stopped EC2 instances, detached EIPs, and unattached EBS volumes and show estimated monthly waste.
- `check-budgets.sh` / `check-budgets.ps1` – check mock budgets for multiple profiles and indicate if they are under or over budget.
- `generate-recommendations.sh` / `generate-recommendations.ps1` – display recommendations based on detected waste.

The scripts rely only on Bash (for Linux/macOS) or PowerShell (for Windows). No cloud APIs or additional tools are required.

## Run on GitHub

[![Run FinOps Toolkit](https://github.com/cloudcwfranck/finazops/actions/workflows/run-app.yml/badge.svg?branch=main)](https://github.com/cloudcwfranck/finazops/actions/workflows/run-app.yml)

Execute the toolkit in a GitHub Actions runner using the `run-app` workflow.
Click the badge above, choose **Run workflow**, and once the job completes open
the run and view the output in the **Summary** tab directly in your browser.

## Running on Replit or Linux/macOS

```bash
bash detect-waste.sh
bash check-budgets.sh
bash generate-recommendations.sh
```

Ensure the scripts have execute permissions:

```bash
chmod +x *.sh
```

## Running on Windows PowerShell

In a PowerShell terminal run:

```powershell
powershell -ExecutionPolicy Bypass -File detect-waste.ps1
powershell -ExecutionPolicy Bypass -File check-budgets.ps1
powershell -ExecutionPolicy Bypass -File generate-recommendations.ps1
```

These commands will output colorized tables summarizing waste, budgets, and recommended actions using mock data.


## Python FinOps CLI

A new `finops_cli.py` script adds enhanced features such as cost analysis by time period, cost trends, profile management and export options. It uses the [Rich](https://pypi.org/project/rich/) library for a pleasant terminal UI.

Run the script with Python 3:

```bash
python3 finops_cli.py --help
```

Exports can be written to CSV, JSON or PDF with `--report-type` and saved to a custom directory using `--dir`.

## Azure Authentication

`azure_login.py` launches an interactive browser window to sign into Azure and
prints your available subscriptions. It requires the `azure-identity` and
`azure-mgmt-resource` packages which are installed automatically in the GitHub
Actions workflow.

Run locally with:

```bash
python3 azure_login.py
```

