using System.Data;
using ChaoticOnyx.Hekate;
/// <summary>
///     Все возможные ошибки анализаторов.
///     Формат - DMSCYXXX.
///     Где X - номер уникальный ошибки. 
///     Y - 1, если это обратное другой ошибке, в остальных случая - 0.
/// </summary>
public static class Issues
{
    public const string MissingSpaceAfter = "DMSC0001";
    public const string ExtraSpaceAfter = "DMSC1001";

    public const string MissingSpaceBefore = "DMSC0002";
    public const string ExtraSpaceBefore = "DMSC1002";

    /// <summary>
    ///     Возвращает сообщение ошибки в зависимости от его идентификатора.
    /// </summary>
    /// <param name="id">Идентификатор ошибки.</param>
    /// <returns>Сообщение ошибки.</returns>
    public static string IdToMessage(string id)
    {
        return id switch
        {
            // Ошибки анализаторов.
            MissingSpaceAfter => "Отсутствует пробел после `{0}`.",
            MissingSpaceBefore => "Отсутствует пробел перед `{0}`.",
            ExtraSpaceAfter => "Лишний пробел после `{0}`.",
            ExtraSpaceBefore => "Лишний пробел перед `{0}`.",

            // Встроенные ошибки.
            IssuesId.MissingClosingSign => "Отсутствует закрывающий знак для `{0}`.",
            IssuesId.UnexpectedToken => "Неожиданный токен `{0}`.",
            IssuesId.UnknownDirective => "Неизвестная директива `{0}`.",
            IssuesId.UnknownMacrosDefinition => "Неизвестное определение макроса `{0}`.",
            IssuesId.EndIfNotFound => "#endif для `{0}` не найден.",
            IssuesId.ExtraEndIf => "Найден лишний #endif.",

            _ => throw new NotImplementedException($"Неизвестный идентификатор ошибки: {id}")
        };
    }
}
