sudo timedatectl set-timezone 'Europe/Moscow' # Необходимо для даты в чейнджлогах
$old_hash = Get-FileHash ./html/changelogs/.all_changelog.json | Select-Object -ExpandProperty Hash

Write-Output 'Получение чейнджлогов...'
dotnet script ./tools/ChangelogGenerator/Fetch.csx

Write-Output 'Генерация чейнджлога...'
dotnet script ./tools/ChangelogGenerator/Make.csx

$new_hash = Get-FileHash ./html/changelogs/.all_changelog.json | Select-Object -ExpandProperty Hash

Write-Output "Старый хэш .all_changelog.json: ${old_hash}"
Write-Output "Новый хэш .all_changelog.json: ${new_hash}"

if ($new_hash -eq $old_hash)
{
    Write-Output 'Изменений нет.'
    exit 1
}

$date = Get-Date -Format 'd.M.yyyy'

git config user.name github-actions
git config user.email github-actions@github.com
git add --all
git commit -m "update(changelog): ${date}"
