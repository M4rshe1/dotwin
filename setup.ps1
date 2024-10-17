Function Show-MenuSelect()
{

    Param(
        [Parameter(Mandatory = $True)][String]$MenuTitle,
        [Parameter(Mandatory = $True)][String]$MenuBanner,
        [Parameter(Mandatory = $True)][array]$MenuOptions
    )

    $MaxValue = $MenuOptions.count - 1
    $Selection = 0
    $EnterPressed = $False

    Clear-Host

    While ($EnterPressed -eq $False)
    {
        if ($MenuBanner.Length -ne 1)
        {
            Write-Host "$MenuBanner"
        }
        Write-Host "$MenuTitle"

        For ($i = 0; $i -le $MaxValue; $i++) {

            If ($i -eq $Selection)
            {
                Write-Host -BackgroundColor DarkGray -ForegroundColor White "[ $( $MenuOptions[$i] ) ]"
            }
            Else
            {
                Write-Host "  $( $MenuOptions[$i] )  "
            }

        }

        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode

        Switch ($KeyInput)
        {
            13 {
                $EnterPressed = $True
                Return $Selection
                Clear-Host
                break
            }

            38 {
                If ($Selection -eq 0)
                {
                    $Selection = $MaxValue
                }
                Else
                {
                    $Selection -= 1
                }
                Clear-Host
                break
            }

            40 {
                If ($Selection -eq $MaxValue)
                {
                    $Selection = 0
                }
                Else
                {
                    $Selection += 1
                }
                Clear-Host
                break
            }
            Default {
                Clear-Host
            }
        }
    }
}

Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/config.json" | Out-File $env:TMP\settings.json
$Global:settings = Get-Content $env:TMP\settings.json | ConvertFrom-Json
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")

if (-not $isAdmin)
{
    Read-Host "Please run this script as an administrator."
    exit
}

function install-Softwares
{
    Write-Host "Installing software..."
    $Global:settings.software | ForEach-Object {
        winget install $_ -y
    }
}

function Set-Settings
{
    Write-Host "Add config files..."
    if (-not (Test-Path $PROFILE))
    {
        New-Item -ItemType File -Path $PROFILE -Force
    }
    $Global:settings.config_files | ForEach-Object {
        $file = $_
        if ($file.init_only)
        {
            Write-Host "Ignoring $($file.name)..." -ForegroundColor Yellow
            return
        }
        Write-Host "Updating $($file.name)..." -ForegroundColor Green
        Invoke-RestMethod  $($file.url) | Out-File $($file.local | iex) -Force
    }
}



function Add-StartUpShortcut($name, $pathm, $admin)
{
    $shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$name.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcut)
    $shortcut.TargetPath = $path

    if ($admin)
    {
        $shortcut.Arguments = "-ExecutionPolicy Bypass -File $path"
    }
    $shortcut.Save()
}

function Get-WinGetProgramPath($name)
{
    $path = $env:LOCALAPPDATA + "\Microsoft\WinGet\Packages\"
    Get-ChildItem -Path $path -recurse -filter "*$name*" -ErrorAction SilentlyContinue | ForEach-Object {
        return "$( $_.directory )\$( $_ )"
    }
}

function Add-StartUpShortcuts
{
    Write-Host "Adding startup shortcuts..."
    Add-StartUpShortcut "glazewm" (Get-WinGetProgramPath "glazewm.exe")
}

function Install-Fonts
{
    Write-Host "Installing fonts..."

    Invoke-WebRequest "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -OutFile $env:TMP\JetBrainsMono.zip
    Expand-Archive $env:TMP\JetBrainsMono.zip -DestinationPath $env:TMP\JetBrainsMono
    $fonts = Get-ChildItem -Path $env:TMP\JetBrainsMono -Recurse -Filter "*.ttf"
    $fontViewer = New-Object -ComObject Shell.Application
    $fonts | ForEach-Object {
        Write-Host "Installing $( $_.Name )..."
        $fontViewer.Namespace(0x14).CopyHere($_.FullName)
    }
    Remove-Item -Path $env:TMP\JetBrainsMono -Recurse -Force
    Remove-Item -Path $env:TMP\JetBrainsMono.zip -Force
}

Write-Host "Setup complete!"




