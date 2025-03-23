try
{
    $request = [System.Net.HttpWebRequest]::Create("https://github.com")
    $request.Timeout = 250
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

$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}
Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000

function e
{
    param(
        [string]$path = "."
    )
    explorer $path
}

function ctt
{
    Invoke-RestMethod christitus.com/win | Invoke-Expression
}

#function Import {
#    param (
#        [string]$RepoBranchFile,
#        [string[]]$Functions = @()
#    )
#
#    if ($RepoBranchFile -match "^(https?://)?([^@]+)@([^/]+)/(.+)$") {
#        $Repository = $matches[2] -replace "github.com", "raw.githubusercontent.com"
#        $Branch = $matches[3]
#        $FilePath = $matches[4]
#    } else {
#        Write-Error "Invalid format. Use 'github.com/user/repo@branch/filepath'."
#        return
#    }
#
#    $RawUrl = "https://$Repository/refs/heads/$Branch/$FilePath"
#    $RawUrl
#    try {
#        $ScriptContent = Invoke-RestMethod -Uri $RawUrl -ErrorAction Stop
#
#        Invoke-Expression -Command $ScriptContent
#
#        if (-not $Functions) {
#            $Functions = @()
#            if ($ScriptContent -match 'function\s+([\w-]+)') {
#                $Matches = $ScriptContent | Select-String -Pattern 'function\s+([\w-]+)' -AllMatches
#                foreach ($Match in $Matches.Matches) {
#                    $Functions += $Match.Groups[1].Value
#                }
#            }
#        }
#
#        foreach ($FunctionName in $Functions) {
#            $Function = Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue
#            if ($Function) {
#                Set-Item -Path "Function:\$FunctionName" -Value $Function.ScriptBlock
#            } else {
#                Write-Warning "Function '$FunctionName' was not found in the imported script."
#            }
#        }
#
#        Write-Output "Successfully imported: $($Functions -join ', ')"
#    } catch {
#        Write-Error "Failed to import the module: $_"
#    }
#}

#Import "github.com/M4rshe1/powershell-snippets@main/string/ConvertTo-CamelCase.ps1"
#
#ConvertTo-CamelCase "Hello World"

function Add-SSHKey
{
    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/tups1s/master/USB/Scripts/remote/add-ssh-key.ps1" | Invoke-Expression
}

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

function grep {
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
            $line = $_
            $lineMatches = if ($caseSensitive) {
                [regex]::Matches($line, $regex)
            } else {
                [regex]::Matches($line, $regex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            }

            if ($lineMatches.Count -gt 0) {
                $lastIndex = 0
                foreach ($match in $lineMatches) {
                    Write-Host ($line.Substring($lastIndex, $match.Index - $lastIndex)) -NoNewline
                    Write-Host ($match.Value) -ForegroundColor Red -NoNewline
                    $lastIndex = $match.Index + $match.Length
                }
                Write-Host ($line.Substring($lastIndex)) -NoNewline
                Write-Host ":$lineNumber" -ForegroundColor Yellow
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
    Set-Location $name
}

function rmrf($path)
{
    $confirm = Read-Host "Are you sure you want to delete $path? (y/n)"
    if ($confirm -eq "y")
    {
        Remove-Item $path -Recurse -Force
    }
}

function Kill-Port($port)
{
    $process = Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess -ErrorAction SilentlyContinue
    $process
    if ($null -ne $process)
    {
        $process | Stop-Process -Force
    }
    else
    {
        Write-Host "No process found on port $port" -ForegroundColor Yellow
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

function admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

Set-Alias -Name sudo -Value admin

function gs { git status }

function ga { git add . }

function gc { git commit -m "$args" }

function gp { git push }

function gcl { git clone "$args" }

function gcm {
    git add .
    git commit -m "$args"
}

function lg {
    git status
    git add .
    git commit -m "$args"
    git push
}

function gpl { git pull }

function gf { git fetch }

function gr { git remote -v }

function grr { git remote remove "$args" }

function gra { git remote add "$args" }

function gco { git checkout "$args" }

function cpy
{
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string] $content
    )
    Set-Clipboard -Value $content
}

function pst
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
        Invoke-RestMethod  $_.url | Out-File $( $_.local | Invoke-Expression ) -Force
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

