$RepositoryRoot = Split-Path $PSScriptRoot | Split-Path
Push-Location -Path $RepositoryRoot
$Env:GITHUB_REPOSITORY = "ChaoticOnyx/OnyxBay"
dotnet script "$PSScriptRoot\Fetch.csx"
Pop-Location
