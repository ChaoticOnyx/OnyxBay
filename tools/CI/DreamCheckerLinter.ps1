$Ci = Get-GithubEnvironment
$PR = $env:PR -as [int]
$DREAMCHECKER = $env:DREAMCHECKER

if ($null -eq $Ci)
{
    throw 'Окружение Github Workflow не найдено.'
}

if (0 -eq $PR)
{
    throw 'Переменная среды PR не найдена.'
}

if ($null -eq $DREAMCHECKER)
{
    throw 'Переменная среды DREAMCHECKER не найдена.'
}

Push-Location $Ci.Workspace

$Messages = Get-DreamCheckerAnalyze -Path $DREAMCHECKER -Workspace (Get-Location)
$ChangedFiles = Get-GithubPullRequestFiles -Repository $Ci.Repository -PullRequestNumber $PR

Pop-Location

$HasErrors = $false

foreach ($Message in $Messages)
{
    if ($null -eq ($ChangedFiles | Where-Object -Property FileName -EQ $Message.FileName))
    {
        continue
    }

    if ($null -eq ($ChangedFiles | Select-Object -ExpandProperty ChangedLines | Where-Object {$_ -EQ $Message.Line}))
    {
        continue
    }

    if ($Message.Level -eq 'error')
    {
        $HasErrors = $true
    }

    $Message | Format-GithubWorkflowMessage | Write-Host
}

if ($HasErrors -eq $true)
{
    exit 1
}
