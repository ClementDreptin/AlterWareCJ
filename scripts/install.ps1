$Cwd = $(Get-Location).Path
$DataDir = "$Cwd\data"
$SrcDir = "$PSScriptRoot\..\src"
$ParsedDir = "$Cwd\parsed"
$GscToolExePath = "$DataDir\gsc-tool.exe"

class Engine {
    [string]$Name
    [string]$Label
    [string]$Path
    [string]$ScriptDir
}

$Engines = @(
    [Engine]@{
        Name = "iw4"
        Label = "MW2"
        Path = ""
        ScriptDir = "userraw\scripts"
    },
    [Engine]@{
        Name = "iw6"
        Label = "Ghosts"
        Path = ""
        ScriptDir = "iw6\scripts"
    },
    [Engine]@{
        Name = "s1"
        Label = "AW"
        Path = ""
        ScriptDir = "s1\scripts"
    }
)

function DownloadGscTool {
    $ZipPath = "$DataDir\gsc-tool.zip"
    $DownloadUri = "https://github.com/xensik/gsc-tool/releases/latest/download/windows-x64-release.zip"

    # Download the latest binary
    try {
        $Null = mkdir -Force $DataDir
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($DownloadUri, $ZipPath)
        Write-Output "gsc-tool downloaded"
    } catch {
        throw "Could not download the gsc-tool binary!"
    }

    # Unzip
    try {
        Expand-Archive $ZipPath -Destination $DataDir
        Write-Output "gsc-tool extracted"
    } catch {
        throw "Could not unzip $ZipPath"
    }

    # Delete the zip file
    try {
        Remove-Item $ZipPath
    } catch {
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

    Write-Output "Processing $($Engine.Label)"

    # gsc-tool doesn't support iw4 but parsing scripts as iw5 is fine for this mod
    if ($Engine.Name -eq "iw4") {
        $Engine.Name = "iw5"
    }

    # Generate the parsed files with gsc-tool
    $Null = & $GscToolExePath -m parse -g $Engine.Name -s pc $SrcDir
    Write-Output "`tGenerated scripts for $($Engine.Label)"

    # Check if the user already has a scripts directory, if so, ask to overwrite it
    $TargetDir = "$($Engine.Path)\$($Engine.ScriptDir)"
    if ([System.IO.Directory]::Exists($TargetDir)) {
        $Reply = Read-Host "`tA scripts folder already exists, do you want to overwrite it? [y/n]"
        if ($Reply -eq "y") {
            Remove-Item $TargetDir -Recurse
        } else {
            continue
        }
    }

    # Move the parsed scripts to the engine installation directory
    try {
    Move-Item -Path "$ParsedDir\$($Engine.Name)" -Destination $TargetDir -Force -ErrorAction Stop
        Write-Output "`tScripts installed"
    } catch {
        throw "Couldn't install scripts"
    }
}

function Cleanup {
    Remove-Item $DataDir, $ParsedDir -Recurse
    Write-Output "Cleaned up"
}

try {
    DownloadGscTool

    # Create a folder picker dialog object
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $Browser = New-Object System.Windows.Forms.FolderBrowserDialog

    # Generate the gsc scripts
    foreach ($Engine in $Engines) {
        GetInstallPath $Engine $Browser

        # Don't generate the scripts if the folder picker dialog was cancelled
        if ($Engine.Path -ne "") {
            GenerateParsedScripts $Engine
        }
    }
} catch {
    Write-Output $_.Exception
}

Cleanup
