$Global:Cwd = $(Get-Location).Path
$Global:DataDir = "$Cwd\data"
$Global:SrcDir = "$PSScriptRoot\..\src"
$Global:ConfigPath = "$DataDir\config.json"
$Global:GscToolExePath = "$DataDir\gsc-tool.exe"

class Engine {
    [string]$Name
    [string]$Label
    [string]$Path
    [string]$ScriptDir
}

$Global:Config = @(
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

    # Return early if the binary was already downloaded
    if ([System.IO.File]::Exists($GscToolExePath)) {
        Write-Output "gsc-tool already downloaded"
        return
    }

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

function PopulateConfig {
    # If the config file already exists, load the config from it
    if ([System.IO.File]::Exists($ConfigPath)) {
        try {
            $Global:Config = Get-Content $ConfigPath | ConvertFrom-Json
            Write-Output "Loaded config from $ConfigPath"
        } catch {
            throw "Could not load config from $ConfigPath"
        }

        return
    }

    # Load the Windows Forms assembly (required for file dialogs)
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

    # Ask the user for the installation path of each engine
    $Browser = New-Object System.Windows.Forms.FolderBrowserDialog
    foreach ($Engine in $Config)
    {
        $Browser.Description = "Pick $($Engine.Label) installation folder"
        $Null = $Browser.ShowDialog()
        $Engine.Path = $Browser.SelectedPath
        $Browser.SelectedPath = $(Get-Item $Browser.SelectedPath).Parent.FullName
    }

    # Dump the config to a JSON file
    try {
        $Null = New-Item -ItemType "file" -Path $ConfigPath -Value ($Config | ConvertTo-Json)
        Write-Output "Created config file at $ConfigPath"
    } catch {
        throw "Could not create config file at $ConfigPath"
    }
}

function GenerateParsedFiles {
    $ParsedRootDir = "$Cwd\parsed"

    foreach ($Engine in $Config) {
        Write-Output "Processing $($Engine.Label)"

        # gsc-tool doesn't support iw4 but parsing scripts as iw5 is fine for this mod
        $EngineName = $Engine.Name
        if ($Engine.Name -eq "iw4") {
            $EngineName = "iw5"
        }

        # Generate the parsed files with gsc-tool
        $Null = & $GscToolExePath -m parse -g $EngineName -s pc $SrcDir
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
        $ParsedDir = "$ParsedRootDir\$EngineName"
        try {
            Move-Item -Path $ParsedDir -Destination $TargetDir -Force -ErrorAction Stop
            Write-Output "`tScripts installed"
        } catch {
            throw "Couldn't install scripts"
        }
    }

    Remove-Item $ParsedRootDir -Recurse
}

try {
    DownloadGscTool
    PopulateConfig
    GenerateParsedFiles
} catch {
    Write-Output $_.Exception
}
