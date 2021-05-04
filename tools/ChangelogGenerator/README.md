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
- Unix: `./<script-name>.csx` или `dotnet-script <script-name>.csx`
- Windows: `<script-name>.bat` или `dotnet-script <script-name>.csx`
- VSCode: F5 `Fetch Changelogs` или `Generate Changelogs`
