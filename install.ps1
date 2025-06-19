# Install Python dependencies for the FinOps toolkit
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is required but not found"; exit 1
}

$python = (Get-Command python).Source
$cmd = "$python -m pip"
& $python -m pip install --upgrade pip
& $python -m pip install -r requirements.txt
Write-Host "Dependencies installed"
