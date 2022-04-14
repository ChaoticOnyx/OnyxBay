$correctFile = $args[0]
$checkFile = $args[1]

if ($null -eq $correctFile) {
    Write-Host 'Pass as the first argument path to a correct .ftl file'
    exit
}

if ($null -eq $checkFile) {
    Write-Host 'Pass as the second argument path to a file which should be checked.'
    exit
}

if ((Test-Path $correctFile) -eq $false) {
    Write-Host "'$correctFile' not found"
    exit
}

if ((Test-Path $checkFile) -eq $false) {
    Write-Host "'$checkFile' not found"
    exit
}

$originalVars = @()

foreach ($line in Get-Content $correctFile) {
    if ($line -match '^.*=') {
        $originalVars += $line.Split(' ')[0]
    }
}

$checkVars = @()

foreach ($line in Get-Content $checkFile) {
    if ($line -match '^.*=') {
        $checkVars += $line.Split(' ')[0]
    }
}

$hasErrors = $false

foreach ($var in $originalVars) {
    if ($checkVars.Contains($var) -eq $false) {
        Write-Host "$checkFile does not have: '$var'"
        $hasErrors = $true
    }
}

foreach ($var in $checkVars) {
    if ($originalVars.Contains($var) -eq $false) {
        Write-Host "$checkFile contains extra var: '$var'"
        $hasErrors = $true
    }
}

if ($hasErrors -eq $true) {
    exit 1
}

exit 0
