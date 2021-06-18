#r "nuget: ChaoticOnyx.Hekate, 0.4.5"
#nullable enable

#load "Settings.csx"
#load "Issues.csx"
#load "Analyzer.csx"
#load "Analyzers/SpacesAnalyzer.csx"

using ChaoticOnyx.Hekate;

public static FileInfo DmePath = null!;
public static Dictionary<FileInfo, IEnumerable<CodeIssue>> IssuesInFile = new();

/// <summary>
///     Кэш всех используемых анализаторов.
/// </summary>
/// <returns></returns>
public List<CodeAnalyzer> Analyzers = new() {
    new SpaceAnalyzer()
};

DmePath = new FileInfo(GetDme());
WriteLine($"Файл среды: {DmePath.FullName}");

ParseFile(DmePath);

/// <summary>
///     Возвращает .dme файл из первого аргумента или из текущей рабочей директории.
/// </summary>
/// <exception cref="FileNotFoundException">.dme файл не обнаружен.</exception>
/// <returns>Путь до .dme файла.</returns>
public string GetDme()
{
    string dmePath = Args.FirstOrDefault() ?? string.Empty;

    if (string.IsNullOrEmpty(dmePath))
    {
        var files = Directory.GetFiles(Directory.GetCurrentDirectory());

        dmePath = files.First(fileName => Path.GetExtension(fileName) == ".dme");
    } else {
        if (File.Exists(dmePath) && Path.GetExtension(dmePath) == ".dme") {
            return dmePath;
        }
    }

    if (string.IsNullOrEmpty(dmePath))
    {
        throw new FileNotFoundException(".dme файл не найден.");
    }

    return dmePath;
}

/// <summary>
///     Производит парсинг и анализа файла, также рекурсивно вызывается по всем файлам в найденных #include.
/// </summary>
/// <param name="file">Файл для анализа.</param>
public void ParseFile(FileInfo file) {
    var fileContent = File.ReadAllText(file.FullName);
    var unit = CompilationUnit.FromSource(fileContent, 4);
    var context = new AnalysisContext(Settings.CodeStyle, unit, true);

    IEnumerable<CodeIssue> issues = new List<CodeIssue>();

    foreach (var analyzer in Analyzers)
    {
        var result = analyzer.Call(context);
        issues = issues.Concat(result.CodeIssues);

        if (result.FixedUnit is not null)
        {
            unit = CompilationUnit.FromTokens(result.FixedUnit);
        }
    }

    File.WriteAllText(file.FullName, unit.Emit());
    IssuesInFile.Add(file, issues);

    foreach (var issue in issues)
    {
        WriteLine(issue.FormatMessage(file.FullName, Issues.IdToMessage(issue.Id)));
    }

    foreach (var include in unit.Preprocessor.Includes) {
        var target = include.Text[1..^1];

        if (Path.GetExtension(target) is not ".dme" and not ".dm") {
            continue;
        }

        var targetInfo = new FileInfo(Path.GetFullPath(target, file.DirectoryName!));

        ParseFile(targetInfo);
    }
}
