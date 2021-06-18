#r "nuget: ChaoticOnyx.Hekate, 0.4.5"

#load "../Issues.csx"
#load "../Analyzer.csx"
#nullable enable

using System.Collections.Immutable;
using System.Collections.ObjectModel;
using ChaoticOnyx.Hekate;

/// <summary>
///     Анализатор пробелов в коде.
/// </summary>
public sealed class SpaceAnalyzer : CodeAnalyzer
{
    private readonly List<CodeIssue> _issues = new();
    private List<SyntaxToken>? _fixedTokens = null;
    private bool _fixMode = false;

    internal override AnalysisResult Analyze(AnalysisContext context)
    {
        var (style, unit, _) = context;
        _fixMode = context.TryToFix;
        var tokens = unit.Lexer.Tokens.ToList();
        var spacingStyle = style.Spaces;

        if (_fixMode)
        {
            _fixedTokens = new();
        }

        for (var i = 0; i < tokens.Count; i++)
        {
            var token = tokens[i];
            var next = i + 1 < tokens.Count ? tokens[i + 1] : null;
            SyntaxToken result;

            switch (token.Kind)
            {
                case SyntaxKind.IfKeyword:
                    result = CheckSpaces(token, next, true, spacingStyle.If);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.ForKeyword:
                    result = CheckSpaces(token, next, true, spacingStyle.For);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.CatchKeyword:
                    result = CheckSpaces(token, next, true, spacingStyle.Catch);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.ThrowKeyword:
                    result = CheckSpaces(token, next, true, spacingStyle.Throw);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.Comma:
                    result = CheckSpaces(token, next, true, spacingStyle.AfterComma);
                    result = CheckSpaces(result, next, false, spacingStyle.BeforeComma);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.NewKeyword:
                    result = CheckSpaces(token, next, true, spacingStyle.New);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.OpenParenthesis:
                    result = CheckSpaces(token, next, true, spacingStyle.InParentheses);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.CloseParenthesis:
                    result = CheckSpaces(token, next, false, spacingStyle.InParentheses);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.OpenBracket:
                    result = CheckSpaces(token, next, true, spacingStyle.InBrackets);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.CloseBracket:
                    result = CheckSpaces(token, next, false, spacingStyle.InBrackets);
                    _fixedTokens?.Add(result);

                    break;
                case SyntaxKind.Identifier:
                    if (next?.Kind != SyntaxKind.OpenParenthesis)
                    {
                        _fixedTokens?.Add(token);
                        break;
                    }

                    result = CheckSpaces(token, next, true, spacingStyle.MethodParentheses);
                    _fixedTokens?.Add(result);

                    break;
                default:
                    _fixedTokens?.Add(token);

                    break;
            }
        }

        return new(_issues, _fixedTokens);
    }

    internal override void Clear()
    {
        _fixedTokens?.Clear();
        _fixedTokens = null;
        _issues.Clear();
        _fixMode = false;
    }

    /// <summary>
    ///     Проверяет на наличие/отсутствие пробела перед/после токена.
    ///     Возвращает исправленный токен если включён режим исправления или переданный токен без режима исправления.
    ///     В случае выключенного режима исправления - создаёт ошибку.
    /// </summary>
    /// <param name="token">Токен который необходимо проверить.</param>
    /// <param name="next">Следующий токен.</param>
    /// <param name="checkAfter">Если true - проверяет после токена, false - перед токеном.</param>
    /// <param name="shouldBe">Если true - проверяет на наличие пробела, false - его отсутствие.</param>
    /// <returns></returns>
    private SyntaxToken CheckSpaces(SyntaxToken token, SyntaxToken? next, bool checkAfter = true, bool shouldBe = false)
    {
        if (checkAfter && token.Kind != SyntaxKind.Comma && next?.Kind != SyntaxKind.OpenParenthesis)
        {
            return token;
        }

        SyntaxToken? whitespace;

        if (checkAfter)
        {
            whitespace = token.Trails.FirstOrDefault();
        }
        else
        {
            whitespace = token.Leads.LastOrDefault();
        }

        if (whitespace?.Kind == SyntaxKind.EndOfLine)
        {
            return token;
        }

        if (whitespace?.Kind != SyntaxKind.WhiteSpace)
        {
            if (shouldBe)
            {
                if (_fixMode)
                {
                    return checkAfter ? CreateTokenWithSpaceAfterFrom(token) : CreateTokenWithSpaceBeforeFrom(token);
                }
                else
                {
                    AddIssue(Issues.ExtraSpaceAfter, token);
                }
            }
        }
        else
        {
            if (!shouldBe)
            {
                if (_fixMode)
                {
                    return checkAfter ? CreateTokenWithoutSpaceAfterFrom(token) : CreateTokenWithoutSpaceBeforeFrom(token);
                }
                else
                {
                    AddIssue(Issues.MissingSpaceAfter, token);
                }
            }
        }

        return token;
    }

    private SyntaxToken CreateTokenWithSpaceAfterFrom(SyntaxToken token)
    {
        SyntaxToken newToken = new(token.Kind, token.Text, token.Position, token.FilePosition);

        newToken.AddLeadTokens(token.Leads.ToArray());
        newToken.AddTrailTokens(new SyntaxToken(SyntaxKind.WhiteSpace, " "));
        newToken.AddTrailTokens(token.Trails.ToArray());

        return newToken;
    }

    private SyntaxToken CreateTokenWithoutSpaceAfterFrom(SyntaxToken token)
    {
        SyntaxToken newToken = new(token.Kind, token.Text, token.Position, token.FilePosition);

        newToken.AddLeadTokens(token.Leads.ToArray());
        newToken.AddTrailTokens(token.Trails.Skip(1).ToArray());

        return newToken;
    }

    private SyntaxToken CreateTokenWithSpaceBeforeFrom(SyntaxToken token)
    {
        SyntaxToken newToken = new(token.Kind, token.Text, token.Position, token.FilePosition);

        newToken.AddTrailTokens(token.Trails.ToArray());
        newToken.AddLeadTokens(token.Leads.ToArray());
        newToken.AddLeadTokens(new SyntaxToken(SyntaxKind.WhiteSpace, " "));

        return newToken;
    }

    private SyntaxToken CreateTokenWithoutSpaceBeforeFrom(SyntaxToken token)
    {
        SyntaxToken newToken = new(token.Kind, token.Text, token.Position, token.FilePosition);

        newToken.AddTrailTokens(token.Trails.ToArray());
        newToken.AddLeadTokens(token.Leads.SkipLast(1).ToArray());

        return newToken;
    }

    private void AddIssue(string id, SyntaxToken token)
    {
        _issues.Add(new(id, token, token.Text));
    }
}
