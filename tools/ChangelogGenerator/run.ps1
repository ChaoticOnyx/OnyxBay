$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
dotnet script "$scriptRoot\Program.csx"
pause