# Скрипт создаёт аннотации из вывода dreamchecker'а

if ($null -eq $env:GITHUB_WORKSPACE)
{
    throw 'Переменная среды GITHUB_WORKSPACE не найдена.'
}

if ($null -eq $env:GITHUB_REPOSITORY)
{
    throw 'Переменная среды GITHUB_REPOSITORY не найдена.'
}

if ($null -eq $env:PR)
{
    throw 'Переменная среды PR не найдена.'
}

$Bin = 'dreamchecker'

if ($IsWindows)
{
    $Bin = $Bin + '.exe'
}

$Bin = Join-Path -Path $env:GITHUB_WORKSPACE $Bin
$TargetOut = Join-Path -Path $env:GITHUB_WORKSPACE 'annotations.json'

if (-not(Test-Path $Bin))
{
    Write-Error "Файл $Bin не найден!"
}

# Получение списка изменённых файлов.
$Response = Invoke-WebRequest -Uri "https://api.github.com/repos/$env:GITHUB_REPOSITORY/pulls/$env:PR/files" -Headers @{ Accept = 'application/vnd.github.groot-preview+json' } `
            -Method 'GET' -AllowUnencryptedAuthentication -SslProtocol 'Tls12'

$ChangedFiles = $Response.Content | ConvertFrom-Json

$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
$ProcessInfo.FileName = $Bin
$ProcessInfo.RedirectStandardOutput = $true
$ProcessInfo.RedirectStandardError = $true
# UseShellExecute = $false требуется для редиректа потоков.
$ProcessInfo.UseShellExecute = $false

Write-Host "Запуск $Bin"
$Process = New-Object System.Diagnostics.Process
$Process.StartInfo = $ProcessInfo
$Process.Start() | Out-Null

# BeginOutputReadLine() требуется для избежания дедлока.
$Process.BeginOutputReadLine()
$ErrorOutput = $Process.StandardError.ReadToEnd()
$Process.WaitForExit()

Write-Host 'Парсинг вывода.'

# Вырезаем управляющие символы
$ErrorOutput = $ErrorOutput -replace '\e\[(\d+;)*(\d+)?[ABCDHJKfmsu]', ''
$RegexMatches = $ErrorOutput | Select-String -Pattern '(?<filename>.*?), line (?<line>\d+), column (?<column>\d+):\s{1,2}(?<type>error|warning): (?<message>.*)' -AllMatches

$ResultJson = @()

foreach ($match in $RegexMatches.Matches)
{
    $Path = $match.Groups | Where-Object -Property 'name' -eq 'filename' | Select-Object -ExpandProperty 'Value'

    if ($null -eq ($ChangedFiles | Where-Object -Property 'filename' -eq $Path))
    {
        continue
    }

    $Column = ($match.Groups | Where-Object -Property 'name' -eq 'column' | Select-Object -ExpandProperty 'Value') -as [int]
    $Line = ($match.Groups | Where-Object -Property 'name' -eq 'line' | Select-Object -ExpandProperty 'Value') -as [int]
    $Level = $match.Groups | Where-Object -Property 'name' -eq 'type' | Select-Object -ExpandProperty 'Value'

    if ($Level -eq 'error')
    {
        $Level = 'failure'
    }

    $ResultJson += @{
        message = $match.Groups | Where-Object -Property 'name' -eq 'message' | Select-Object -ExpandProperty 'Value'
        path = $Path
        start_line = $Line
        end_line = $Line
        start_column = $Column
        end_column = $Column
        annotation_level = $Level
        title = $Level
    }
}

Write-Host "Сохранение в $TargetOut"
ConvertTo-Json -InputObject $ResultJson | Out-File -FilePath $TargetOut
