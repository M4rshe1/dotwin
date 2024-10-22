try
{
    $request = [System.Net.HttpWebRequest]::Create("https://github.com")
    $request.Timeout = 500
    $response = $request.GetResponse()
    $response.Close()
    $canConnectToGitHub = $true
}
catch
{
    $canConnectToGitHub = $false
}

if (-not (Get-Module -Name PSReadLine -ListAvailable))
{
    Write-Host "PSReadLine module not found. Attempting to install via PowerShellGet..."
    try
    {
        Install-Module -Name PSReadLine -AllowClobber -Force
        Write-Host "PSReadLine installed successfully. Importing..."
        Import-Module PSReadLine
    }
    catch
    {
        Write-Error "Failed to install PSReadLine. Error: $_"
    }
}
else
{
    Import-Module PSReadLine
}

if (-not (Get-Module -ListAvailable -Name Terminal-Icons))
{
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}

Import-Module -Name Terminal-Icons

function Update-Profile
{
    if (-not $global:canConnectToGitHub)
    {
        Write-Host "Skipping profile update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return
    }

    try
    {
        $url = "https://raw.githubusercontent.com/M4rshe1/pwsh/master/powershell/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash)
        {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        }
    }
    catch
    {
        Write-Error "Unable to check for `$profile updates"
    }
    finally
    {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}
Update-Profile

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView

function e
{
    param(
        [string]$path = "."
    )
    explorer $path
}

function Add-SSHKey
{
    irm "https://raw.githubusercontent.com/M4rshe1/tups1s/master/USB/Scripts/remote/add-ssh-key.ps1" | iex
}

function ctt
{
    irm christitus.com/win | iex
}

# Network Utilities
function Get-PubIP
{
    (Invoke-WebRequest http://ifconfig.me/ip).Content
}

function sha256
{
    param(
        [string]$path = ""
    )
    if (-not (Test-Path $path))
    {
        Write-Host "File not found" -ForegroundColor Red
        return
    }
    $hash = Get-FileHash $path -Algorithm SHA256
    Write-Host $hash.Hash
}

function grep
{
    param (
        [string] $regex = $( throw "Please provide a regex to search for" ),
        [Parameter(ValueFromPipeline = $true)]
        [string] $content,
        [switch] $caseSensitive = $false
    )
    begin {
        $lineNumber = 0
    }
    process {
        $content -split "`r`n" | ForEach-Object {
            if ($caseSensitive)
            {
                if ($_ -match $regex)
                {
                    Write-Host "$( $_ ):$lineNumber"
                }
            }
            else
            {
                if ($_ -imatch $regex)
                {
                    Write-Host "$( $_ ):$lineNumber"
                }
            }
            $lineNumber++
        }
    }
}

function unzip()
{
    param (
        [string] $file = $( throw "Please provide a file to unzip" ),
        [string] $dest = "."
    )

    Expand-Archive -Path $file -DestinationPath $dest
}

function zip()
{
    param (
        [string] $file = $( throw "Please provide a file to zip" ),
        [string] $dest = "."
    )

    Compress-Archive -Path $file -DestinationPath $dest
}

function sed($file, $find, $replace)
{
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function pkill($name)
{
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name)
{
    Get-Process | Where-Object { $_.ProcessName -match $name }
}

function head
{
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail
{
    param($Path, $n = 10)
    Get-Content $Path -Tail $n
}

function la
{
    Get-ChildItem -Path . -Force | Format-Table -AutoSize
}
function ll
{
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize
}

function mkcd($name)
{
    mkdir $name
    cd $name
}

function rmrf($path)
{
    $confirm = Read-Host "Are you sure you want to delete $path? (y/n)"
    if ($confirm -eq "y")
    {
        Remove-Item $path -Recurse -Force
    }
}

function ff($name)
{
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$( $_ )"
    }
}

function fif
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $SearchString,
        [string] $path = $PWD
    )
    $files = Get-ChildItem -Path $path -Recurse -File
    $results = @()
    foreach ($file in $files)
    {
        try
        {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $lines = $content -split "`r`n"
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match $SearchString)
                {
                    $result = "{0}:{1}" -f $file.FullName, ($i + 1)
                    $results += $result
                }
            }
        }
        catch
        {
            Write-Warning "Error reading file: $( $file.FullName )"
        }
    }
    $results
}

function cbcp
{
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string] $content
    )
    Set-Clipboard -Value $content
}

function cbpt
{
    Get-Clipboard
}

function unique
{
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$InputString
    )
    begin {
        $uniqueLines = @{ }
    }
    process {
        $trimmedLine = $InputString.Trim()
        if (-not $uniqueLines.ContainsKey($trimmedLine))
        {
            $uniqueLines[$trimmedLine] = $true
            $trimmedLine
        }
    }
}


if (Get-Command zoxide -ErrorAction SilentlyContinue)
{
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
else
{
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try
    {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    }
    catch
    {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}

function Update-Config($isInit)
{
    $config = Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/pwsh/master//config.json"
    $config.config_files | ForEach-Object {
        if ($_.init_only -and -not $isInit)
        {
            Write-Host "Ignoring $( $_.name )..." -ForegroundColor Yellow
            return
        }
        Write-Host "Updating $( $_.name )..." -ForegroundColor Green
        Invoke-RestMethod  $_.url | Out-File $( $_.local | iex ) -Force
    }
}
if ($global:canConnectToGitHub)
{
    try
    {
        $url = "https://raw.githubusercontent.com/M4rshe1/dotwin/master/ohmyposh/theme.omp.json"
        $oldhash = Get-FileHash "$env:USERPROFILE/theme.omp.json"
        Invoke-RestMethod $url -OutFile "$env:temp/theme.omp.json"
        $newhash = Get-FileHash "$env:temp/theme.omp.json"
        Copy-Item -Path "$env:temp/theme.omp.json" -Destination "$env:USERPROFILE/theme.omp.json" -Force
    }
    catch
    {
        Write-Error "Unable to check for oh-my-posh theme updates"
    }
}


if (Get-Command oh-my-posh -ErrorAction SilentlyContinue)
{

    oh-my-posh init pwsh --config "$env:USERPROFILE/theme.omp.json" | Invoke-Expression
}
else
{
    Write-Host "oh-my-posh command not found. Attempting to install via winget..."
    try
    {
        winget install JanDeDobbeleer.OhMyPosh -s winget
        Write-Host "oh-my-posh installed successfully. Initializing..."
        oh-my-posh init pwsh --config "$env:USERPROFILE/theme.omp.json" | Invoke-Expression
    }
    catch
    {
        Write-Error "Failed to install oh-my-posh. Error: $_"
    }
}

