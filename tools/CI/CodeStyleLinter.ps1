$Ci = Get-GithubEnvironment
$PR = $env:PR -as [int]

if ($null -eq $Ci)
{
    throw 'Окружение Github Workflow не найдено.'
}

if (0 -eq $PR)
{
    throw 'Переменная среды PR не найдена.'
}

$ChangedFiles = Get-GithubPullRequestFiles -Repository $Ci.Repository -PullRequestNumber $PR
$HasErrors = $false

Push-Location -Path $Ci.Workspace

foreach ($File in $ChangedFiles)
{
    if ((Test-Path $File.FileName) -eq $false)
    {
        continue
    }

    if (($File.FileName[-3..-1] | Join-String) -ne '.dm')
    {
        Write-Verbose "Пропускается файл $($File.FileName)"
        continue
    }

    $Messages = Invoke-DmCodeStyleCheck -Ruleset $Global:DmRuleset -Path $File.FileName

    foreach ($Message in $Messages)
    {
        if ($null -eq ($File.ChangedLines | Where-Object -Property Start -LT $Message.Line | Where-Object -Property End -GT $Message.Line))
        {
            continue
        }

        if ($Message.Level -eq 'error')
        {
            $HasErrors = $true
        }

        $Message | Format-GithubWorkflowMessage | Write-Host
    }
}

Pop-Location

if ($HasErrors -eq $true)
{
    exit 1
}
