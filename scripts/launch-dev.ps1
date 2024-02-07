param([string]$EngineName)

$Cwd = $(Get-Location).Path
$DataDir = "$Cwd\data"
$ConfigPath = "$DataDir\config.json"

# Correct usage check
if ($EngineName -eq "") {
    Write-Output "Usage: .\launch.ps1 <iw4|iw6|s1>"
    exit 0
}

# An installation in dev mode needs to happen first
if (![System.IO.File]::Exists($ConfigPath)) {
    Write-Output "Config not found. Make sure to run `"install.ps1 -Dev`" first"
    exit 1
}

# Get the correct object in the config depending on $EngineName
$Config = $null
try {
    $Config = $(Get-Content $ConfigPath | ConvertFrom-Json) | Where-Object { $_.Name -eq $EngineName }
}
catch {
    Write-Output "Error in config file format"
    exit 1
}

# The alterware launcher uses a command line argument to launch iw4x or iw4x-sp
$Arg = if ($EngineName -eq "iw4") { "iw4x" } else { "" }

# The alterware launcher requires the current working directory to be the
# directory where the game is installed
Set-Location $Config.Path
.\alterware-launcher.exe $Arg
Set-Location $Cwd
