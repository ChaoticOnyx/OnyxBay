$Bin = 'dreamchecker'

if ($IsWindows)
{
    $Bin = $Bin + '.exe'
}

$RepositoryRoot = $PSScriptRoot | Split-Path -Parent
$Bin = Join-Path -Path $RepositoryRoot $Bin
$TargetOut = Join-Path -Path $RepositoryRoot 'annotations.json'

if (-not(Test-Path $Bin))
{
    Write-Host "Файл $Bin не найден!"
    return 1 | Out-Null
}

$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
$ProcessInfo.FileName = $Bin
$ProcessInfo.RedirectStandardOutput = $true
$ProcessInfo.RedirectStandardError = $true
# UseShellExecute = $false требуется для редиректа потоков.
$ProcessInfo.UseShellExecute = $false
$ProcessInfo.StandardErrorEncoding = [System.Text.Encoding]::ASCII

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
    $Column = ($match.Groups | Where-Object -Property 'name' -eq 'column' | Select-Object -ExpandProperty 'Value') -as [int]
    $Line = ($match.Groups | Where-Object -Property 'name' -eq 'line' | Select-Object -ExpandProperty 'Value') -as [int]

    $ResultJson += @{
        pessage = $match.Groups | Where-Object -Property 'name' -eq 'message' | Select-Object -ExpandProperty 'Value'
        path = $match.Groups | Where-Object -Property 'name' -eq 'filename' | Select-Object -ExpandProperty 'Value'
        column = @{
            start = $Column
            end = $Column
        }
        line = @{
            start = $Line
            end = $Line
        }
        level = ($match.Groups | Where-Object -Property 'name' -eq 'type' | Select-Object -ExpandProperty 'Value')
    }
}

Write-Host "Сохранение в $TargetOut"
ConvertTo-Json -InputObject $ResultJson | Out-File -FilePath $TargetOut
