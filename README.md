# FinOps CLI Toolkit

This project provides a simple cross‑platform FinOps command line toolkit for **Azure**.  Most scripts rely on small mock datasets for quick demos, but the waste detection script can now query live Azure resources. Output is styled with ANSI colours and Unicode tables similar to the screenshot referenced in the project description.
The remaining scripts continue to use local mock data for budget checks and recommendations.

## Quick start

Clone the repository and install the Python dependencies:

```bash
git clone https://github.com/cloudcwfranck/finazops.git
cd finazops
bash init.sh   # or run init.bat on Windows
```

After the packages are installed you can run the toolkit just like the AWS version but targeting Azure.

## Components

The repository is organised into several parts:

- Shell and PowerShell scripts for common FinOps tasks.
- A Python CLI available as the `finazops` command.
- A lightweight FastAPI service for programmatic access.
- Cross-platform setup scripts `init.sh` and `init.bat` to create a virtual environment and install requirements.

## Install from PyPI

The CLI can be installed as a package from [PyPI](https://pypi.org/project/finazops/):

```bash
pip install finazops
finazops --help
```

## Scripts

- `detect-waste.sh` / `detect-waste.ps1` – verify Azure CLI authentication and list stopped VMs, unassociated public IPs and unattached managed disks, pulling their current cost from Azure.
- `check-budgets.sh` / `check-budgets.ps1` – check mock budgets for multiple subscriptions and indicate if they are under or over budget.
- `generate-recommendations.sh` / `generate-recommendations.ps1` – display recommendations based on detected waste.

Detect-waste uses the Azure CLI for live data while the other scripts continue to rely on Bash or PowerShell with mock inputs.

## Run on GitHub

[![Run FinOps Toolkit](https://github.com/cloudcwfranck/finazops/actions/workflows/run-app.yml/badge.svg?branch=main)](https://github.com/cloudcwfranck/finazops/actions/workflows/run-app.yml)

Execute the toolkit in a GitHub Actions runner using the `run-app` workflow.
Click the badge above, choose **Run workflow**, and once the job completes open
the run and view the output in the **Summary** tab directly in your browser.

## Build and publish on GitHub

The `publish` workflow builds the Python package and uploads it to PyPI. Push a
tag like `v1.2.3` or trigger the workflow manually after configuring a
`PYPI_API_TOKEN` secret in your repository settings.


## Running on Replit or Linux/macOS

After cloning run `./init.sh` (or `init.bat` on Windows) once to set up the virtual environment and install packages. In new shells activate it with `source .venv/bin/activate` (or `call .venv\Scripts\activate.bat` on Windows). Then execute:

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

In a PowerShell terminal run the setup script once and then execute the scripts:

```powershell
cmd /c init.bat
```

Then run:

```powershell
powershell -ExecutionPolicy Bypass -File detect-waste.ps1
powershell -ExecutionPolicy Bypass -File check-budgets.ps1
powershell -ExecutionPolicy Bypass -File generate-recommendations.ps1
```
These commands output colorized tables summarizing waste, budgets, and recommendations. Waste data comes from Azure while the other reports use mock inputs.

## Python FinOps CLI

The `finops_cli.py` script adds enhanced features such as cost analysis by time period, cost trends, subscription management and export options. It uses the [Rich](https://pypi.org/project/rich/) library for a pleasant terminal UI. When installed from PyPI it is available as the `finazops` command.

Key capabilities include:

* **Cost analysis by time period** – view the current and previous month by default. Set custom ranges such as 7, 30 or 90 days with `--time-range`.
* **Cost by Azure service** – sorted from highest to lowest for clear insight.
* **Cost by tag** – filter spend by one or more tags using `--tag` (cost allocation tags must be enabled).
* **Budget information** – display limits and actual spend for configured budgets.
* **VM instance status** – detailed state information across specified regions via `--regions`.
* **Cost trend analysis** – bar charts summarising the last six months across profiles when `--trend` is used.
* **FinOps audit** – view untagged resources, unused or stopped instances and budget breaches across profiles.
* **Profile management** – automatic subscription detection, select with `--profiles`, use all with `--all` or combine using `--combine`.
* **Export options** – set a name with `--report-name` and output to CSV, JSON and/or PDF with `--report-type` (e.g. `--report-type csv json`). Use `--dir` to choose the folder. Trend reports export to JSON only. Markdown or HTML reports can be generated with `--export md` or `--export html` (requires the `jinja2` package).
* **Improved error handling** and a beautiful terminal UI thanks to the Rich library.

Run `./init.sh` (or `init.bat` on Windows) beforehand so the required Python packages are present.

Run the CLI with Python or the installed command:

```bash

finazops --help
# or
python3 finops_cli.py --help
```

Exports can be written to CSV, JSON or PDF with `--report-type` and saved to a custom directory using `--dir`.

## Azure Authentication

`azure_login.py` launches an interactive browser window to sign into Azure and
prints your available subscriptions. It requires the `azure-identity` and
`azure-mgmt-resource` packages which are installed automatically in the GitHub
Actions workflow or by running `./init.sh` (or `init.bat` on Windows).

Run locally with:

```bash
python3 azure_login.py
```

## FastAPI Service

The project also exposes a lightweight FastAPI web server that wraps the CLI.
Start it with:

```bash
uvicorn finops_server:app --reload
```

Send prompts via HTTP:

```bash
curl -X POST http://localhost:8000/prompt -H "Content-Type: application/json" \
    -d '{"prompt": "check budget for profile-05"}'
```

The response includes the command output in JSON format.

