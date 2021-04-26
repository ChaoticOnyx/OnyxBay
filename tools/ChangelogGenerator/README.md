## Описание
Cl.csx - генерирует файл чейнджлога из тела PR и запускается из CL и не требует ручного запуска.
Program.csx - запускается как через CL так и ручками, превращает все чейнджлог файлы в HTML представление.

## Требования
- [.NET SDK 5.0](https://dotnet.microsoft.com/download)
- dotnet-script - `dotnet tool install -g dotnet-script`

## Запуск
- Windows: Запустить run.bat
- Linux/MacOS: Запустить Program.csx
- VSCode: F5 -> Generate Changelog
