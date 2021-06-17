#r "nuget: ChaoticOnyx.Hekate, 0.4.5"
#nullable enable

using ChaoticOnyx.Hekate;

public static class Settings {
    public static readonly CodeStyle CodeStyle = new() {
        Spaces = new() {
            AfterComma = true,
            BeforeComma = false,
            Catch = false,
            For = false,
            If = false,
            InBrackets = false,
            InParentheses = false,
            MethodParentheses = false,
            New = false,
            Operators = true,
            Throw = true,
            While = false
        },
        Naming = new() {
            Methods = NamingConvention.Underscored,
            Paths = NamingConvention.Underscored,
            Variables = NamingConvention.Underscored
        },
        LastEmptyLine = true
    };
}
