$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
Push-Location -Path ../../
$Env:GITHUB_REPOSITORY = "ChaoticOnyx/OnyxBay"
dotnet script "$scriptRoot\Fetch.csx"
Pop-Location
