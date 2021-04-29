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
    ///     Файл с указанием на последний PR для которого был сделан чейнджлог.
    /// </summary>
    /// <returns></returns>
    public static readonly string LastPrFile = Path.GetFullPath("./tools/ChangelogGenerator/last_pr.txt", WorkspaceFolder);
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

/// <summary>
///     Префиксы изменении.
/// </summary>
public enum ChangePrefix
{
    BugFix = 0,
    Wip,
    Tweak,
    SoundAdd,
    SoundDel,
    RscAdd,
    RscDel,
    ImageAdd,
    ImageDel,
    MapTweak,
    SpellCheck,
    Experiment,
    Admin
}
