﻿git stash
git fetch origin
git checkout origin/dev --force
git checkout -b changelog
Invoke-Expression "$PSScriptRoot\Fetch.ps1"
Invoke-Expression "$PSScriptRoot\Make.ps1"
git status
$date = (Get-Date -Format "dd/MM/yyyy HH:mm").ToString()
git commit -a --message="Генерация чейнджлога на ${date}"
