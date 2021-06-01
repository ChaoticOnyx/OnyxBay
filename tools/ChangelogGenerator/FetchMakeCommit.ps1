git stash
git fetch master
git checkout master/dev --force
git checkout -b "changelog-$(Get-Date -Format 'yyyy-MM-dd')"
Invoke-Expression "$PSScriptRoot\Fetch.ps1"
Invoke-Expression "$PSScriptRoot\Make.ps1"
git commit -a --message="Генерация чейнджлога на $(Get-Date -Format 'dd/MM/yyyy')"
