## Описание
ClCheck.csx - проверяет PR на наличие и корректность чейнджлога.
ClCreate.csx - создаёт чейнджлоги для всех PR с номера указанного в last_pr.txt до самого последнего и обновляет HTML.
Program.csx - запускается как через CL так и ручками, превращает все чейнджлог файлы в HTML представление.

## Требования
- [.NET SDK 5.0](https://dotnet.microsoft.com/download)
- dotnet-script - `dotnet tool install -g dotnet-script`

## Запуск
- Windows: Запустить run.bat
- Linux/MacOS: Запустить Program.csx
- VSCode: F5 -> Generate Changelog
