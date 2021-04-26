$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
cd ../../
dotnet script "$scriptRoot\Program.csx"
pause