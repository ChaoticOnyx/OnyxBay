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

    internal override AnalysisResult Analyze(AnalysisContext context)
    {
        var (codeStyle, unit) = context;
        var spacingStyle = codeStyle.Spaces;

        for (var i = 0; i < unit.Lexer.Tokens.Count; i++)
        {
            var token = unit.Lexer.Tokens[i];
            var next = i + 1 < unit.Lexer.Tokens.Count ? unit.Lexer.Tokens[i + 1] : null;
            var lastLead = token.Leads.LastOrDefault();
            var firstTrail = token.Trails.FirstOrDefault();

            if (firstTrail?.Kind == SyntaxKind.EndOfLine)
            {
                continue;
            }

            var hasSpacesBefore = lastLead?.Kind == SyntaxKind.WhiteSpace;
            var hasSpacesAfter = firstTrail?.Kind == SyntaxKind.WhiteSpace;

            switch (token.Kind)
            {
                case SyntaxKind.IfKeyword:
                    if (spacingStyle.If && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.If && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.ForKeyword:
                    if (spacingStyle.For && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.For && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.CatchKeyword:
                    if (spacingStyle.Catch && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.Catch && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.ThrowKeyword:
                    if (spacingStyle.Throw && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.Throw && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.Comma:
                    if (spacingStyle.AfterComma && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.AfterComma && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    if (spacingStyle.BeforeComma && !hasSpacesBefore)
                    {
                        AddIssue(Issues.MissingSpaceBefore, token);
                    }
                    else if (!spacingStyle.BeforeComma && hasSpacesBefore)
                    {
                        AddIssue(Issues.ExtraSpaceBefore, token);
                    }

                    break;
                case SyntaxKind.NewKeyword:
                    if (next?.Kind != SyntaxKind.OpenParenthesis)
                    {
                        break;
                    }

                    if (spacingStyle.New && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.New && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.OpenParenthesis:
                    if (spacingStyle.InParentheses && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.InParentheses && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.CloseParenthesis:
                    if (spacingStyle.InParentheses && !hasSpacesBefore)
                    {
                        AddIssue(Issues.MissingSpaceBefore, token);
                    }
                    else if (!spacingStyle.InParentheses && hasSpacesBefore)
                    {
                        AddIssue(Issues.ExtraSpaceBefore, token);
                    }

                    break;
                case SyntaxKind.OpenBracket:
                    if (spacingStyle.InBrackets && !hasSpacesAfter)
                    {
                        AddIssue(Issues.MissingSpaceAfter, token);
                    }
                    else if (!spacingStyle.InBrackets && hasSpacesAfter)
                    {
                        AddIssue(Issues.ExtraSpaceAfter, token);
                    }

                    break;
                case SyntaxKind.CloseBracket:
                    if (spacingStyle.InBrackets && !hasSpacesBefore)
                    {
                        AddIssue(Issues.MissingSpaceBefore, token);
                    }
                    else if (!spacingStyle.InBrackets && hasSpacesBefore)
                    {
                        AddIssue(Issues.ExtraSpaceBefore, token);
                    }

                    break;
            }
        }

        return new(_issues);
    }

    internal override void Clear()
    {
        _issues.Clear();
    }

    private void AddIssue(string id, SyntaxToken token)
    {
        _issues.Add(new(id, token, token.Text));
    }
}
