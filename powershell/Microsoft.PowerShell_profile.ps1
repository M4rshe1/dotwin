$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1



if (-not(Get-Module -Name PSReadLine -ListAvailable)) {
    Write-Host "PSReadLine module not found. Attempting to install via PowerShellGet..."
    try {
        Install-Module -Name PSReadLine -AllowClobber -Force
        Write-Host "PSReadLine installed successfully. Importing..."
        Import-Module PSReadLine
    } catch {
        Write-Error "Failed to install PSReadLine. Error: $_"
    }
} else {
    Import-Module PSReadLine
}

if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

function Update-Profile {
    if (-not $global:canConnectToGitHub) {
        Write-Host "Skipping profile update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
        return
    }

    try {
        $url = "https://raw.githubusercontent.com/M4rshe1/pwsh/master/powershll/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        }
    } catch {
        Write-Error "Unable to check for `$profile updates"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}
Update-Profile


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

function e {
    explorer .
}

function c {
    [string]$path = $PWD
    pycharm $path
}

function ctt {
    irm christitus.com/win | iex
}

# Network Utilities
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# System Utilities
function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

function cb
{
    param(
        [string]$path = "",
        [string]$rm,
        [Switch]$ls,
        [String]$token = "wefwefwefwefthedrthrthertheewr34345345345rtherth",
        [String]$serverURI = "https://bin.heggli.dev"
    )
    if ($rm) {
        if ($rm -eq "") {
            Write-Host "No fileid provided" -ForegroundColor Red
            return
        }

        $headers = @{
            'Content-Type' = 'application/json'
        }
        $body = @{
            token = $token
        }
        Invoke-RestMethod -Uri "$($serverURI)/$($rm)?token=$($token)" -Method Delete -Body $body -Headers $headers
        return
    }
    if ($ls) {
        $body = @{
            token = $token
        }
        Invoke-RestMethod -Uri "$($serverURI)/ls" -Method Get -Body $body
        return
    }
    if ($path -eq "") {
        Write-Host "No path provided" -ForegroundColor Red
        return
    }
    if (-not (Test-Path $path)) {
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

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
    param($Path, $n = 10)
    Get-Content $Path -Head $n
}

function tail {
    param($Path, $n = 10)
    Get-Content $Path -Tail $n
}

function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

function touch($file) { "" | Out-File $file -Encoding ASCII }
function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.directory)\$($_)"
    }
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else {
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}