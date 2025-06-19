@echo off
REM Initialization helper for the FinOps toolkit

where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Python 3 is required but not found.
    echo Install it from https://www.python.org/downloads/ or the Microsoft Store.
    exit /b 1
)

set PYTHON=python

if not exist .venv (
    echo Creating virtual environment .venv
    %PYTHON% -m venv .venv
)

call .venv\Scripts\activate.bat

%PYTHON% -m pip install --upgrade pip >nul
%PYTHON% -m pip install -r requirements.txt
%PYTHON% -m pip install -e . >nul

echo Setup complete. Activate with "call .venv\Scripts\activate.bat".
