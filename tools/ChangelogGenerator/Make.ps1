$RepositoryRoot = Split-Path $PSScriptRoot | Split-Path
Push-Location -Path $RepositoryRoot
dotnet script "$PSScriptRoot\Make.csx"
Pop-Location
