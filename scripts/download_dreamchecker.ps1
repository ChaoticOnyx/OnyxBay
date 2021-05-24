# Скрипт загружает последнюю доступную версию dreamchecker'a с гитхаба в корень репозитория.

$RepositoryRoot = $PSScriptRoot | Split-Path -Parent
$TargetBin = 'dreamchecker'

if ($IsWindows)
{
    $TargetBin = $TargetBin + '.exe'
}

$TargetPath = Join-Path -Path $RepositoryRoot $TargetBin
$Headers = @{ Accept = 'application/vnd.github.groot-preview+json' }

$Response = Invoke-WebRequest -Uri 'https://api.github.com/repos/SpaceManiac/SpacemanDMM/releases/latest' `
            -Headers $Headers -Method Get

$Result = $Response.Content | ConvertFrom-Json
$Asset = $Result.assets | Where-Object -Property 'name' -eq $TargetBin | Select-Object


Write-Host "Загрузка $($Asset.browser_download_url)"

$Response = Invoke-WebRequest -Uri $Asset.browser_download_url -Headers $Headers `
            -Method 'GET' -AllowUnencryptedAuthentication -OutFile $TargetPath `
            -SslProtocol 'Tls12' & Write-Host "Загружено в $TargetPath"
