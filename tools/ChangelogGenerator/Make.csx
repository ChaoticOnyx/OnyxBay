#!/usr/bin/env dotnet-script
#nullable enable
#load "Settings.csx"
#load "Models.csx"

#r "nuget:Scriban, 3.6.0"
using System.IO;
using System.Linq;
using System.Text.Json;
using Scriban;

WriteLine("[1] Парсинг чейнджлогов.");
var files = (from file in Settings.ChangelogsFolder.GetFiles()
             where !file.Name.StartsWith('.') && file.Extension == ".json"
             select file).ToList();

List<Changelog> changelogs = new(12);

foreach (var file in files)
{
    try
    {
        changelogs.Add(JsonSerializer.Deserialize<Changelog>(File.ReadAllText(file.FullName), Settings.JsonOptions)
                                      ?? throw new InvalidOperationException($"[1] 🚫Невозможно запарсить {file}"));
    }
    catch (JsonException e)
    {
        WriteLine($"[1] 🚫Ошибка при парсинге файла {file.Name}: {e.Message}");

        return 1;
    }
}

changelogs = Changelog.Merge(changelogs);

if (changelogs.Count == 0)
{
    WriteLine(" │  Нет новых чейнджлогов.");
}

List<Changelog> cache = new(0);
WriteLine(" │  Парсинг кэша.");

try
{
    cache = JsonSerializer.Deserialize<List<Changelog>>(File.ReadAllText(Settings.ChangelogsCache.FullName), Settings.JsonOptions)
                           ?? throw new InvalidOperationException($"[1] 🚫Невозможно запарсить {Settings.ChangelogsCache}");
}
catch (JsonException e)
{
    WriteLine($"[1] 🚫Ошибка при парсинге кэша: {e.Message}");

    return 1;
}

cache.AddRange(changelogs);
cache = Changelog.Merge(cache);
cache = cache.OrderByDescending(c => c.Date).ToList();

WriteLine($"[1] ✅Обработано {changelogs.Count} чейнджлогов.");
WriteLine("[2] Проверка чейнджлогов и кэша.");
bool anyErrors = false;
foreach (var changelog in cache)
{
    if (string.IsNullOrEmpty(changelog.Author))
    {
        anyErrors = true;
        WriteLine($" │  🚫Имя автора не должно быть пустым:\n{changelog}");
    }

    if (changelog.Changes.Count == 0)
    {
        anyErrors = true;
        WriteLine($" │  🚫Список изменении не должен быть пустым:\n{changelog}");
    }

    foreach (var change in changelog.Changes)
    {
        if (string.IsNullOrEmpty(change.Message))
        {
            anyErrors = true;
            WriteLine($" │  🚫Сообщение не должно быть пустым:\n{changelog}");
        }
    }
}

if (anyErrors)
{
    WriteLine("[2] 🚫Были обнаружены ошибки.");
    return 1;
}

WriteLine($"[2] Ошибок не найдено.");

WriteLine($"[3] Парсинг шаблона из {Settings.ChangelogTemplate.Name}.");
Template template = Template.Parse(File.ReadAllText(Settings.ChangelogTemplate.FullName));
var context = new
{
    GeneratingTime = DateTime.Now,
    Changelogs = cache
};

WriteLine($" │  Сохранение HTML в {Settings.HtmlChangelog.Name}...");
File.WriteAllText(Settings.HtmlChangelog.FullName, template.Render(context));
WriteLine(" │  ✅HTML сохранен.");

WriteLine($" │  Сохранение кэша в {Settings.ChangelogsCache.Name}...");
File.WriteAllText(Settings.ChangelogsCache.FullName, JsonSerializer.Serialize(cache, Settings.JsonOptions));
WriteLine(" │  ✅Кэш сохранён.");

WriteLine(" │  Удаление чейнджлог файлов...");
files.ForEach(f => f.Delete());
WriteLine("[3] ✅Чейнджлог файлы удалены.");

return 0;
