$paths = @()
$maps = Get-ChildItem -Path maps -Include *.dmm -Exclude exodus*,null* -Recurse

Push-Location ./maps

$maps | ForEach-Object -Process { 
    $relativePath = Resolve-Path $_ -Relative
    $relativePath = "#include ""$($relativePath.Substring(2))"""
    $paths += $relativePath
 }

Pop-Location

$paths | Sort-Object | Out-File -FilePath ./maps/_map_include.dm
