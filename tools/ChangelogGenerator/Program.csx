#!/usr/bin/env dotnet-script
#nullable enable
#load "Settings.csx"
#load "Models.csx"

#r "nuget:Scriban, 3.6.0"
using System.IO;
using System.Linq;
using System.Text.Json;
using Scriban;
using Console = System.Console;

// Поиск и парсинг чейнджлогов.
var files = (from file in Directory.GetFiles(Settings.ChangelogsFolder)
              where Path.GetFileName(file)[0] != '.' && Path.GetExtension(file) == ".json"
              select file).ToList();

var changelogs = files.Select(f => JsonSerializer.Deserialize<Changelog>(File.ReadAllText(f), Settings.JsonOptions)
                                     ?? throw new InvalidOperationException($"Невозможно запарсить {f}"))
                        .ToList();

changelogs = Changelog.Merge(changelogs);

if (changelogs.Count == 0)
{
    WriteLine("Нет новых чейнджлогов.");

    return 0;
}

// Парсинг кэша.
var cache = JsonSerializer.Deserialize<List<Changelog>>(File.ReadAllText(Settings.ChangelogsCache), Settings.JsonOptions)
                            ?? throw new InvalidOperationException($"Невозможно запарсить {Settings.ChangelogsCache}");
cache.AddRange(changelogs);
cache = Changelog.Merge(cache);
cache = cache.OrderByDescending(c => c.Date).ToList();

// Проверка кэша.
bool anyErrors = false;
foreach (var changelog in cache)
{
    if (string.IsNullOrEmpty(changelog.Author))
    {
        anyErrors = true;
        WriteLine($"Имя автора не должно быть пустым:\n{changelog}");
    }

    if (changelog.Changes.Count == 0)
    {
        anyErrors = true;
        WriteLine($"Список изменении не должен быть пустым:\n{changelog}");
    }

    foreach (var change in changelog.Changes)
    {
        if (string.IsNullOrEmpty(change.Prefix))
        {
            anyErrors = true;
            WriteLine($"Префикс не должен быть пустым:\n{changelog}");
        }

        if (string.IsNullOrEmpty(change.Message))
        {
            anyErrors = true;
            WriteLine($"Сообщение не должно быть пустым:\n{changelog}");
        }

        if (!Settings.ValidPrefixes.Contains(change.Prefix))
        {
            anyErrors = true;
            WriteLine($"Недопустимый префикс `{change.Prefix}`:\n{changelog}");
        }
    }
}

if (anyErrors)
{
    return 1;
}

// Создание и рендеринг HTML шаблона
Template template = Template.Parse(File.ReadAllText(Settings.ChangelogTemplate));
var context = new
{
    GeneratingTime = DateTime.Now,
    Changelogs = cache
};

// Сохранение и удаление
WriteLine("Сохранение HTML.");
File.WriteAllText(Settings.HtmlChangelog, template.Render(context));

WriteLine("Сохранение кэша.");
File.WriteAllText(Settings.ChangelogsCache, JsonSerializer.Serialize(cache, Settings.JsonOptions));

WriteLine("Удаление чейнджлог файлов.");
files.ForEach(f => File.Delete(f));

return 0;
