param (
    [Array]$ignore_files
)


Invoke-RestMethod "https://raw.githubusercontent.com/M4rshe1/dotwin/master/config.json" | Out-File $env:TMP\config.json
$Global:settings = Get-Content $env:TMP\config.json | ConvertFrom-Json

$Global:settings.config_files | ForEach-Object {
    $file = $_
    write-host $file.name
    if ($ignore_files -contains $file.name)
    {
        Write-Host "Ignoring $($file.name)..." -ForegroundColor Yellow
        return
    }
    Write-Host "Updating $($file.name)..." -ForegroundColor Green
    Invoke-RestMethod  $($file.url) | Out-File $file.local
}