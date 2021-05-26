class Ruleset
{
    [string]$Pattern
    [string]$Message
    [ValidateSet('error', 'warning')]
    [string]$Level
}

class DiagnosticMessage
{
    [string]$FileName
    [string]$Message
    [ValidateSet('error', 'warning')]
    [string]$Level
    [int]$Line
    [int]$Column
}

function New-DiagnosticMessage
{
    <#
        .SYNOPSIS
            Создаёт новоее диагностическое сообщение.
        .PARAMETER FileName
            Путь до файла.
        .PARAMETER Message
            Сообщение.
        .PARAMETER Level
            Уровень сообщения - 'error' или 'warning'
        .PARAMETER Line
            Номер строки в файле.
        .PARAMETER Column
            Номер столбца в файле.
        .OUTPUTS
            [DiagnosticMessage] - Диагностическое сообщение.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FileName,
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter(Mandatory)]
        [ValidateSet('error', 'warning')]
        [string]$Level,
        [Parameter(Mandatory)]
        [int]$Line,
        [Parameter(Mandatory)]
        [int]$Column
    )

    PROCESS
    {
        return [DiagnosticMessage]@{
            FileName = $FileName
            Message  = $Message
            Level    = $Level
            Line     = $Line
            Column   = $Column
        }
    }
}

function Invoke-DmCodeStyleCheck
{
    <#
        .SYNOPSIS
            Производит анализ файла на язык программирования DM на соответствие стилю кода.
        .PARAMETER Path
            Путь до анализируемого файла.
        .PARAMETER Ruleset
            Набор правил для анализа.
        .OUTPUTS
            [DiagnosticMessage[]] - найденные проблемы.
    #>

    [CmdletBinding()]
    [OutputType([DiagnosticMessage[]])]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [ValidateNotNullOrEmpty()]
        [Ruleset[]]$Ruleset = $Global:DmRuleset
    )

    PROCESS
    {
        if (-not (Test-Path -Path $Path))
        {
            Write-Error "Файл $Path не существует"
            continue
        }

        Write-Host "Парсинг файла $Path"
        $FileContent = Get-Content -Path $Path
        $Lines = ($FileContent -replace '\n\r', '\n').Split('\n')
        $LineIndex = 0

        foreach ($Line in $Lines)
        {
            $LineIndex++

            foreach ($Rule in $Ruleset)
            {
                $RegexMatches = $Line | Select-String -Pattern $Rule.Pattern -AllMatches

                foreach ($Match in $RegexMatches.Matches)
                {
                    $ErrorString = $Match.Groups | Where-Object -Property Name -EQ 'error'

                    if ($null -eq $ErrorString)
                    {
                        continue
                    }

                    # Ширина табуляции на гитхабе - 8
                    $Column = ($Line[0..($Match.Index - 1)] -replace '\t', [string]::new(' ', 8)).Count
                    $FormatedMessage = $Rule.Message -f $Match.Groups[0].Value, $ErrorString

                    New-DiagnosticMessage -FileName $Path -Message $FormatedMessage -Level $Rule.Level -Line $LineIndex -Column $Column | Write-Output
                }
            }
        }
    }
}
