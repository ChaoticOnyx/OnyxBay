#nullable enable

using System.Text.Json;
using System.IO;

/// <summary>
///     Настройки скрипта.
/// </summary>
private static class Settings
{
    /// <summary>
    ///     Корень билда.
    /// </summary>
    public static readonly DirectoryInfo WorkspaceFolder = new(Path.GetFullPath("./", Directory.GetCurrentDirectory()));
    /// <summary>
    ///     Папка с чейнджлогами.
    /// </summary>
    public static readonly DirectoryInfo ChangelogsFolder = new(Path.GetFullPath("./html/changelogs/", WorkspaceFolder.FullName));
    /// <summary>
    ///     Кэш чейнджлогов.
    /// </summary>
    public static readonly DirectoryInfo ChangelogsCache = new(Path.GetFullPath("./html/changelogs/.all_changelog.json", WorkspaceFolder.FullName));
    /// <summary>
    ///     HTML файл чейнджлога.
    /// </summary>
    /// <returns></returns>
    public static readonly FileInfo HtmlChangelog = new(Path.GetFullPath("./html/changelog.html", WorkspaceFolder.FullName));
    /// <summary>
    ///     Шаблон HTML чейнджлога.
    /// </summary>
    public static readonly FileInfo ChangelogTemplate = new(Path.GetFullPath("./html/templates/changelog.tmpl", WorkspaceFolder.FullName));
    /// <summary>
    ///     Файл с указанием на дату закрытия последнего PR для которого был сделан чейнджлог.
    /// </summary>
    /// <returns></returns>
    public static readonly FileInfo LastClosedPrDateFile = new(Path.GetFullPath("./tools/ChangelogGenerator/last_pr.txt", WorkspaceFolder.FullName));
    /// <summary>
    ///     Настройки JSON сериализатора.
    /// </summary>
    public static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
        WriteIndented = true
    };
    /// <summary>
    ///     Название плашки, которая будет добавляться к PR если отсутствует чейнджлог или он с ошибками.
    /// </summary>
    public static readonly string ChangelogRequiredLabel = ":scroll: Требуется чейнджлог";
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
