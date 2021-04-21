#!/usr/bin/env dotnet-script
#nullable enable
#load "Models.csx"

#r "nuget:Scriban, 3.6.0"
using System.IO;
using System.Linq;
using System.Text.Json;
using Scriban;
using Console = System.Console;

/// <summary>
///     Настройки скрипта.
/// </summary>
private static class Settings
{
    /// <summary>
    ///     Корень билда.
    /// </summary>
    public static readonly string WorkspaceFolder = Path.GetFullPath("../../");
    /// <summary>
    ///     Папка с чейнджлогами.
    /// </summary>
    public static readonly string ChangelogsFolder = Path.GetFullPath("./html/changelogs/", WorkspaceFolder);
    /// <summary>
    ///     Кэш чейнджлогов.
    /// </summary>
    public static readonly string ChangelogsCache = Path.GetFullPath("./html/changelogs/.all_changelog.json", WorkspaceFolder);
    /// <summary>
    ///     HTML файл чейнджлога.
    /// </summary>
    /// <returns></returns>
    public static readonly string HtmlChangelog = Path.GetFullPath("./html/changelog.html", WorkspaceFolder);
    /// <summary>
    ///     Шаблон HTML чейнджлога.
    /// </summary>
    public static readonly string ChangelogTemplate = Path.GetFullPath("./html/templates/changelog.tmpl", WorkspaceFolder);
    /// <summary>
    ///     Список допустимых префиксов.
    /// </summary>
    public static readonly List<string> ValidPrefixes = new()
    {
        "bugfix",
        "wip",
        "tweak",
        "soundadd",
        "sounddel",
        "rscadd",
        "rscdel",
        "imageadd",
        "imagedel",
        "maptweak",
        "spellcheck",
        "experiment",
        "admin"
    };
    /// <summary>
    ///     Настройки JSON сериализатора.
    /// </summary>
    public static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
        WriteIndented = true
    };
}

// Поиск и парсинг чейнджлогов.
var _files = (from file in Directory.GetFiles(Settings.ChangelogsFolder)
              where Path.GetFileName(file)[0] != '.' && Path.GetExtension(file) == ".json"
              select file).ToList();

var _changelogs = _files.Select(f => JsonSerializer.Deserialize<Changelog>(File.ReadAllText(f), Settings.JsonOptions)
                                     ?? throw new InvalidOperationException($"Can't parse {f}"))
                        .ToList();

_changelogs = Changelog.Merge(_changelogs);

if (_changelogs.Count == 0)
{
    WriteLine("Нет новых чейнджлогов.");

    return 0;
}

// Парсинг кэша.
var _cache = JsonSerializer.Deserialize<List<Changelog>>(File.ReadAllText(Settings.ChangelogsCache), Settings.JsonOptions)
                            ?? throw new InvalidOperationException($"Can't parse {Settings.ChangelogsCache}");
_cache.AddRange(_changelogs);
_cache = Changelog.Merge(_cache);
_cache = _cache.OrderByDescending(c => c.Date).ToList();

// Проверка кэша.
bool _anyErrors = false;
foreach (var changelog in _cache)
{
    if (string.IsNullOrEmpty(changelog.Author))
    {
        _anyErrors = true;
        WriteLine($"Имя автора не должно быть пустым:\n{changelog}");
    }

    if (changelog.Changes.Count == 0)
    {
        _anyErrors = true;
        WriteLine($"Список изменении не должен быть пустым:\n{changelog}");
    }

    foreach (var change in changelog.Changes)
    {
        if (string.IsNullOrEmpty(change.Prefix))
        {
            _anyErrors = true;
            WriteLine($"Префикс не должен быть пустым:\n{changelog}");
        }

        if (string.IsNullOrEmpty(change.Message))
        {
            _anyErrors = true;
            WriteLine($"Сообщение не должно быть пустым:\n{changelog}");
        }

        if (!Settings.ValidPrefixes.Contains(change.Prefix))
        {
            _anyErrors = true;
            WriteLine($"Недопустимый префикс `{change.Prefix}`:\n{changelog}");
        }
    }
}

if (_anyErrors)
{
    return -1;
}

// Создание и рендеринг HTML шаблона
Template template = Template.Parse(File.ReadAllText(Settings.ChangelogTemplate));
var context = new
{
    GeneratingTime = DateTime.Now,
    Changelogs = _cache
};

// Сохранение и удаление
WriteLine("Сохранение HTML.");
File.WriteAllText(Settings.HtmlChangelog, template.Render(context));

WriteLine("Сохранение кэша.");
File.WriteAllText(Settings.ChangelogsCache, JsonSerializer.Serialize(_cache, Settings.JsonOptions));

WriteLine("Удаление чейнджлог файлов.");
_files.ForEach(f => File.Delete(f));

return 0;
