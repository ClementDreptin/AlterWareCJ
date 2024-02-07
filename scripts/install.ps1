param([switch]$Dev)

$Cwd = $(Get-Location).Path
$DataDir = "$Cwd\data"
$SrcDir = "$PSScriptRoot\..\src"
$ParsedDir = "$Cwd\parsed"
$GscToolExePath = "$DataDir\gsc-tool.exe"
$ConfigPath = "$DataDir\config.json"

class Engine {
    [string]$Name
    [string]$Label
    [string]$Path
    [string]$ScriptDir
}

$Engines = @(
    [Engine]@{
        Name      = "iw4"
        Label     = "MW2"
        Path      = ""
        ScriptDir = "userraw\scripts"
    },
    [Engine]@{
        Name      = "iw6"
        Label     = "Ghosts"
        Path      = ""
        ScriptDir = "iw6\scripts"
    },
    [Engine]@{
        Name      = "s1"
        Label     = "AW"
        Path      = ""
        ScriptDir = "s1\scripts"
    }
)

function DownloadGscTool {
    $ZipPath = "$DataDir\gsc-tool.zip"
    $DownloadUri = "https://github.com/xensik/gsc-tool/releases/latest/download/windows-x64-release.zip"

    # In dev mode, skip the download if the binary is already on disk
    if ($Dev.IsPresent -and [System.IO.File]::Exists($GscToolExePath)) {
        Write-Host "gsc-tool already downloaded"
        return
    }

    # Download the latest binary
    try {
        $Null = mkdir -Force $DataDir
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($DownloadUri, $ZipPath)
        Write-Host "gsc-tool downloaded"
    }
    catch {
        throw "Could not download the gsc-tool binary"
    }

    # Unzip
    try {
        Expand-Archive $ZipPath -Destination $DataDir -Force
        Write-Host "gsc-tool extracted"
    }
    catch {
        throw "Could not unzip $ZipPath"
    }

    # Delete the zip file
    try {
        Remove-Item $ZipPath
    }
    catch {
        throw "Could not delete $ZipPath"
    }
}

function GetInstallPath {
    param ([Engine]$Engine, [System.Windows.Forms.FolderBrowserDialog]$Browser)

    # Show folder picker dialog
    $Browser.Description = "Pick $($Engine.Label) installation folder"
    $Result = $Browser.ShowDialog()

    # Only update the engine path if the user clicked OK
    if ($Result -eq "OK") {
        $Engine.Path = $Browser.SelectedPath
    }
}

function GenerateParsedScripts {
    param ([Engine]$Engine)

    Write-Host "Processing $($Engine.Label)"

    # gsc-tool doesn't support iw4 but parsing scripts as iw5 is fine for this mod
    $EngineName = $Engine.Name
    if ($EngineName -eq "iw4") {
        $EngineName = "iw5"
    }

    # Generate the parsed files with gsc-tool
    $Null = & $GscToolExePath -m parse -g $EngineName -s pc $SrcDir
    Write-Host "`tGenerated scripts for $($Engine.Label)"

    $TargetDir = "$($Engine.Path)\$($Engine.ScriptDir)"

    # Create the scripts directory if it doesn't exist
    if (![System.IO.Directory]::Exists($TargetDir)) {
        try {
            $Null = New-Item -Path $TargetDir -ItemType Directory -Force
        }
        catch {
            throw "Couldn't install scripts"
        }
    }

    # Check if the scripts directory already contains scripts, if so, ask to overwrite them
    if ((Get-ChildItem -Path $TargetDir -Force | Measure-Object).Count -eq 0) {
        # Always overwrite in dev mode
        if (!$Dev.IsPresent) {
            $Reply = [System.Windows.Forms.MessageBox]::Show(
                "Existing scripts were found, do you want to overwrite them?",
                "Overwrite existing scripts",
                [System.Windows.Forms.MessageBoxButtons]::YesNo
            )

            if ($Reply -eq "Yes") {
                Remove-Item "$TargetDir\*" -Recurse
            }
            else {
                return
            }
        }
        else {
            Remove-Item "$TargetDir\*" -Recurse
        }
    }

    # Move the parsed scripts to the scripts directory
    try {
        Move-Item -Path "$ParsedDir\$($EngineName)\*" -Destination $TargetDir -Force -ErrorAction Stop
        Write-Host "`tScripts installed"
    }
    catch {
        throw "Couldn't install scripts"
    }
}

function Cleanup {
    # Keep the data dir between runs in dev mode
    if (!$Dev.IsPresent) {
        Remove-Item $DataDir -Recurse -ErrorAction SilentlyContinue
    }

    Remove-Item $ParsedDir -Recurse -ErrorAction SilentlyContinue

    Write-Output "Cleaned up"
}

try {
    DownloadGscTool

    # Create a folder picker dialog object
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $Browser = New-Object System.Windows.Forms.FolderBrowserDialog

    # Load the path from the config when in dev mode instead of using a folder picker dialog
    if ($Dev.IsPresent -and [System.IO.File]::Exists($ConfigPath)) {
        $Engines = Get-Content $ConfigPath | ConvertFrom-Json
    }
    else {
        foreach ($Engine in $Engines) {
            GetInstallPath $Engine $Browser
        }
    }

    # Generate the gsc scripts
    foreach ($Engine in $Engines) {
        if ($Engine.Path -ne "") {
            GenerateParsedScripts $Engine
        }
    }

    # Dump the engines to a file when in dev mode
    if ($Dev.IsPresent -and ![System.IO.File]::Exists($ConfigPath)) {
        $Engines | ConvertTo-Json | Out-File $ConfigPath
    }

    Cleanup

    Write-Host -ForegroundColor Green "All good!"
}
catch {
    Write-Host -ForegroundColor Red $_.Exception
}

pause
