$paths = @()
$maps = Get-ChildItem -Path maps -Include *.dmm -Exclude null* -Recurse

Push-Location ./maps

Write-Host 'Обнаружены карты:'
$maps | ForEach-Object -Process {
    Write-Host $($_)
    $relativePath = Resolve-Path $_ -Relative
    $relativePath = "#include ""$($relativePath.Substring(2))"""
    $paths += $relativePath
 }

Pop-Location

$paths | Sort-Object | Out-File -FilePath ./maps/_map_include.dm
