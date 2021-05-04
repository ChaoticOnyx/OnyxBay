$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
Push-Location -Path ../../
dotnet script "$scriptRoot\Make.csx"
Pop-Location
