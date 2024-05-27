try
{
    $request = [System.Net.HttpWebRequest]::Create("http://github.com")
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


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

function e
{
    param(
        [string]$path = "."
    )
    explorer $path
}

function cdn
{
    param (
        [string]$path = "."
    )
    Set-Location -Path $path
    nvim .
}

function c
{
    [string]$path = $PWD

    if (Test-Path $path -PathType Leaf)
    {
        $path = $path | Split-Path
    }

    if (Get-Command pycharm -ErrorAction SilentlyContinue)
    {
        cd $path
        pycharm .
        return
    }
    elseif (Get-Command code -ErrorAction SilentlyContinue)
    {
        cd $path
        code .
        return
    }
    elseif (Get-Command nvim -ErrorAction SilentlyContinue)
    {
        cd $path
        nvim .
        return
    }
    else
    {
        notepad $path
    }
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

# System Utilities
function uptime
{
    $uptime = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | ForEach-Object { [Management.ManagementDateTimeConverter]::ToDateTime($_) }
    $uptime = New-TimeSpan -Start $uptime -End (Get-Date) | Select-Object -Property Days, Hours, Minutes, Seconds
    "$( $uptime.Days ) days, $( $uptime.Hours ) hours, $( $uptime.Minutes ) minutes, $( $uptime.Seconds ) seconds"
}

function cb
{
    param(
        [string]$path = "",
        [string]$rm,
        [Switch]$ls,
        [String]$token = [Environment]::GetEnvironmentVariable("CB_TOKEN", "User"),
        [String]$serverURI = "https://bin.heggli.dev"
    )

    if ($token -eq "")
    {
        $token = Read-Host "Please provide a token`n>> "
        [Environment]::SetEnvironmentVariable("CB_TOKEN", $token, "User")
    }

    if ($rm)
    {
        if ($rm -eq "")
        {
            Write-Host "No fileid provided" -ForegroundColor Red
            return
        }

        $headers = @{
            'Content-Type' = 'application/json'
        }
        $body = @{
            token = $token
        }
        Invoke-RestMethod -Uri "$( $serverURI )/$( $rm )?token=$( $token )" -Method Delete -Body $body -Headers $headers
        return
    }
    if ($ls)
    {
        $body = @{
            token = $token
        }
        Invoke-RestMethod -Uri "$( $serverURI )/ls" -Method Get -Body $body
        return
    }
    if ($path -eq "")
    {
        Write-Host "No path provided" -ForegroundColor Red
        return
    }
    if (-not (Test-Path $path))
    {
        Write-Host "File not found" -ForegroundColor Red
        return
    }
    $content = Get-Content $path -Raw
    $body = @{
        file = $content
        token = $token
        filename = $path.Split("\")[-1].Split("/")[-1]
    }
    Invoke-RestMethod -Uri $serverURI -Method Get -Body $body
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


function df
{
    get-volume
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

function export($name, $value)
{
    [Environment]::SetEnvironmentVariable($name, $value, "User")
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


function touch($file)
{
    "" | Out-File $file -Encoding ASCII
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

    # Get all files recursively from the current directory
    $files = Get-ChildItem -Path $path -Recurse -File

    # Array to store results
    $results = @()

    foreach ($file in $files)
    {
        try
        {
            # Read the content of the file
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

            # Split content into lines
            $lines = $content -split "`r`n"  # Split by newline (handles Windows format)

            # Iterate through each line to find the search string
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match $SearchString)
                {
                    # Build the result string: "file_path:line_number"
                    $result = "{0}:{1}" -f $file.FullName, ($i + 1)  # Line numbers are 1-based
                    $results += $result
                }
            }
        }
        catch
        {
            Write-Warning "Error reading file: $( $file.FullName )"
        }
    }

    # Output the results
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
