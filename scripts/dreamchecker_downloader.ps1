# Скрипт загружает последнюю доступную версию dreamchecker'a с гитхаба в корень репозитория.

if ($null -eq $env:GITHUB_WORKSPACE)
{
    throw 'Переменная среды GITHUB_WORKSPACE не найдена.'
}

$TargetBin = 'dreamchecker'

if ($IsWindows)
{
    $TargetBin = $TargetBin + '.exe'
}

$TargetPath = Join-Path -Path $env:GITHUB_WORKSPACE $TargetBin
$Headers = @{ Accept = 'application/vnd.github.groot-preview+json' }

$Response = Invoke-WebRequest -Uri 'https://api.github.com/repos/SpaceManiac/SpacemanDMM/releases/latest' `
            -Headers $Headers -Method Get

$Result = $Response.Content | ConvertFrom-Json
$Asset = $Result.assets | Where-Object -Property 'name' -eq $TargetBin | Select-Object -ExpandProperty 'browser_download_url'

Write-Host "Загрузка $Asset в $TargetPath"

$Response = Invoke-WebRequest -Uri $Asset -Headers $Headers `
            -Method 'GET' -AllowUnencryptedAuthentication -OutFile $TargetPath `
            -SslProtocol 'Tls12'
