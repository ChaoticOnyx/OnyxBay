#r "nuget: ChaoticOnyx.Hekate, 0.4.5"
#nullable enable

using System.Collections.Immutable;
using ChaoticOnyx.Hekate;

/// <summary>
///     Результат анализа.
/// </summary>
public sealed record AnalysisResult(ICollection<CodeIssue> CodeIssues, IList<SyntaxToken>? FixedUnit);

/// <summary>
///     Контекст анализа.
/// </summary>
/// <param name="CodeStyle">Используемый стиль кода.</param>
/// <param name="Unit">Юнит компиляции.</param>
/// <returns></returns>
public sealed record AnalysisContext(CodeStyle CodeStyle, CompilationUnit Unit, bool TryToFix = false);

/// <summary>
///     Класс для всех анализаторов. Каждый анализатор создаётся только один раз, при вызове метода Analyze().
///     Все предыдущие результаты нужно очищать в методе Clear().
/// </summary>
public abstract class CodeAnalyzer
{
    /// <summary>
    ///     Вызов анализатора.
    /// </summary>
    /// <param name="context">Контекст анализа.</param>
    public AnalysisResult Call(AnalysisContext context)
    {
        Clear();
        return Analyze(context);
    }

    /// <summary>
    ///     Метод для вызова анализа.
    /// </summary>
    /// <param name="context">Контекст анализа.</param>
    /// <returns></returns>
    internal abstract AnalysisResult Analyze(AnalysisContext context);

    /// <summary>
    ///     Метод для очистки между анализами.
    /// </summary>
    internal abstract void Clear();
}
