#nullable enable

using System.Text.Json;

/// <summary>
///     Настройки скрипта.
/// </summary>
private static class Settings
{
    /// <summary>
    ///     Корень билда.
    /// </summary>
    public static readonly string WorkspaceFolder = Path.GetFullPath("./", Directory.GetCurrentDirectory());
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
