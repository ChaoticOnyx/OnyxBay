class DreamCheckerMessage
{
    [ValidateSet('error', 'warning')]
    [string]$Level
    [string]$Message
    [string]$FileName
    [int]$Line
    [int]$Column
}

function Install-DreamChecker
{
    <#
        .SYNOPSIS
            Загружает самую новую версию DreamChecker'а.
        .PARAMETER Path
            Путь до папки, в которую необходимо сохранить бинарник.
            По-умолчанию - текущая рабочая папка.
        .OUTPUTS
            [string] - путь до dreamchecker'а.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location)
    )

    PROCESS
    {
        $TargetBin = 'dreamchecker'

        if ($IsWindows)
        {
            $TargetBin += '.exe'
        }

        $TargetPath = Join-Path $Path $TargetBin
        $Repository = Get-GithubRepository -Name 'SpacemanDMM' -Owner 'igorsaux'
        $Release = $Repository | Get-GithubLastRelease

        $DownloadLink = $Release.Assets | Where-Object -Property Name -EQ $TargetBin | Select-Object -ExpandProperty Url

        Write-Verbose "Ссылка для скачивания: $DownloadLink"
        Write-Host "Загрузка $TargetBin в $TargetPath"

        Invoke-WebRequest -Uri $DownloadLink -Method Get -SslProtocol Tls12 -OutFile $TargetPath

        if (-not $IsWindows)
        {
            chmod +x $TargetPath
        }

        return $TargetPath
    }
}

function Get-DreamCheckerAnalyze
{
    <#
        .SYNOPSIS
            Запускает dreamchecker и парсит вывод.
        .PARAMETER Path
            Путь до dreamcheckera (по-умолчанию берётся из переменной среды DREAMCHECKER).
        .PARAMETER Workspace
            Путь до папки где находится .dme файл (по-умолчанию - текущая рабочая папка).
        .OUTPUTS
            [DreamCheckerMessage[]] - вывод dreamchecker'а.
    #>

    [CmdletBinding()]
    [OutputType([DreamCheckerMessage[]])]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Path = $env:DREAMCHECKER,
        [ValidateNotNullOrEmpty()]
        [string]$Workspace = (Get-Location)
    )

    PROCESS
    {
        $Path = Resolve-Path $Path
        $Workspace = Resolve-Path $Workspace

        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = $Path
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.RedirectStandardError = $true
        # UseShellExecute = $false требуется для редиректа потоков.
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.WorkingDirectory = $Workspace

        Write-Host "Запуск $Path"
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null

        # BeginOutputReadLine() требуется для избежания дедлока.
        $Process.BeginOutputReadLine()
        $ErrorOutput = $Process.StandardError.ReadToEnd()
        $Process.WaitForExit()

        # Вырезаем управляющие символы
        $ErrorOutput = $ErrorOutput -replace '\e\[(\d+;)*(\d+)?[ABCDHJKfmsu]', ''
        $RegexMatches = $ErrorOutput | Select-String -Pattern '(?<filename>.*?), line (?<line>\d+), column (?<column>\d+):\s{1,2}(?<type>error|warning): (?<message>.*)' -AllMatches
        [DreamCheckerMessage[]]$Messages = @()

        foreach ($match in $RegexMatches.Matches)
        {
            $FileName = $match.Groups | Where-Object -Property 'name' -EQ 'filename' | Select-Object -ExpandProperty 'Value'
            $Column = ($match.Groups | Where-Object -Property 'name' -EQ 'column' | Select-Object -ExpandProperty 'Value') -as [int]
            $Line = ($match.Groups | Where-Object -Property 'name' -EQ 'line' | Select-Object -ExpandProperty 'Value') -as [int]
            $Level = $match.Groups | Where-Object -Property 'name' -EQ 'type' | Select-Object -ExpandProperty 'Value'
            $Message = $match.Groups | Where-Object -Property 'name' -EQ 'message' | Select-Object -ExpandProperty 'Value'

            $Messages += [DreamCheckerMessage]@{
                Level    = $Level
                Message  = $Message
                FileName = $FileName
                Line     = $Line
                Column   = $Column
            }
        }
        
        return $Messages
    }
}
