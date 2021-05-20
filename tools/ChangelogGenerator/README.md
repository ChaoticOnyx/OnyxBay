## Описание
ClCheck.csx - проверяет PR на наличие и корректность чейнджлога.

Fetch.csx - собирает все чейнджлоги с репозитория в файлы.

Make.csx - обрабатывает все чейнджлоги и превращает в HTML.

Settings.csx - настройки скрипта.

Models.csx - модели используемые в скрипте.

FetchMakeCommit.bat - комбинирование fetch.csx и make.csx, также создаёт ветку с изменениями и коммит.

## Требования
- [.NET SDK 5.0](https://dotnet.microsoft.com/download)
- dotnet-script - `dotnet tool install -g dotnet-script`

## Запуск
- VSCode: F5 `<script-name>`
