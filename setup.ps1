param (
    [Switch]$noInstall,
    [Switch]$noConfig,
    [Switch]$noStartup,
    [Switch]$noFont
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin)
{
    Read-Host "Please run this script as an administrator."
    exit
}

if (-not $noInstall)
{
    Write-Host "Installing software..."

    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/ctt/ctt.json" | Out-File $env:TMP\ctt.json

    Invoke-Expression "& { $( Invoke-RestMethod christitus.com/win ) } -Config $env:TMP\ctt.json -Run"
    winget install glazewm
}

if (-not $noConfig)
{
    Write-Host "Add config files..."
    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/powershell/Microsoft.PowerShell_profile.ps1" | Out-File $PROFILE
    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/shell/shell.nss" | Out-File "C:\Program Files\Nilesoft Shell\shell.nss" $env:LOCALAPPDATA
    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/glazewm/config.yml" | Out-File "~\.glaze-wm\config.yml"
    Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/terminal/settings.json" | Out-File "$env:LOCALAPPDATA\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

function Add-StartUpShortcut($name, $path)
{
    $shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$name.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcut)
    $shortcut.TargetPath = $path
    $shortcut.Save()
}

function Get-WinGetProgramPath($name)
{
    $path = $env:LOCALAPPDATA + "\Microsoft\WinGet\Packages\"
    Get-ChildItem -Path $path -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        return "$( $_.directory )\$( $_ )"
    }
}

if (-not $noStartup)
{
    Write-Host "Adding startup shortcuts..."
    Add-StartUpShortcut "glazewm" (Get-WinGetProgramPath "glazewm.exe")
}

if (-not $noFont)
{
    Write-Host "Installing fonts..."

    irm https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip -OutFile $env:TMP\JetBrainsMono.zip
    Expand-Archive $env:TMP\JetBrainsMono.zip -DestinationPath $env:TMP\JetBrainsMono
    $fonts = $env:TMP + "\JetBrainsMono\*.ttf"
    Copy-Item $fonts -Destination "C:\Windows\Fonts"
}

Write-Host "Setup complete!"




