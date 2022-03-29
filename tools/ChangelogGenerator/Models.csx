#r "nuget:Markdig, 0.24.0"
#load "Settings.csx"
#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using Markdig;

public sealed class Changelog
{
    /// <summary>
    ///     Автор изменений.
    /// </summary>
    public string Author { get; init; } = string.Empty;

    /// <summary>
    ///     Дата генерации изменении.
    /// </summary>
    public DateTime Date { get; init; } = DateTime.Now.Date;

    /// <summary>
    ///     Изменения.
    /// </summary>
    public List<Change> Changes { get; init; } = new();

    /// <summary>
    ///     Объединение одинаковых чейнджлогов по датам и авторам, удаление дубликатов.
    /// </summary>
    /// <param name="changelogs">Чейнджлоги.</param>
    /// <returns>Объёдинённые чейнджлоги.</returns>
    public static List<Changelog> Merge(List<Changelog> changelogs)
    {
        List<Changelog> result = new();

        foreach (Changelog changelog in changelogs)
        {
            if (result.Any(e => e.Author == changelog.Author && e.Date.Date == changelog.Date.Date)) { continue; }

            List<Change> changelogChanges = changelogs
                                                .Where(e => e.Author == changelog.Author
                                                            && e.Date.Date == changelog.Date.Date)
                                                .SelectMany(e => e.Changes)
                                                .ToHashSet()
                                                .ToList();

            result.Add(new Changelog
            {
                Author = changelog.Author,
                Date = changelog.Date,
                Changes = changelogChanges
            });
        }

        return result;
    }

    public override string ToString()
    {
        StringBuilder sb = new();

        sb.Append($"Author: {Author}\n");
        sb.Append($"Date: {Date}\n");
        sb.Append("Changes:\n");

        foreach (Change change in Changes)
        {
            sb.Append($"\t{change}\n");
        }

        return sb.ToString();
    }

    public sealed class Change
    {
        /// <summary>
        ///     Префикс изменения.
        /// </summary>
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ChangePrefix Prefix { get; init; } = ChangePrefix.BugFix;

        /// <summary>
        ///     Описание изменения.
        /// </summary>
        public string Message { get; init; } = string.Empty;

        /// <summary>
        ///     Номер PR к которому относится данное изменение.
        /// </summary>
        public int? Pr { get; init; } = null;

        /// <summary>
        ///     Message в формате HTML.
        /// </summary>
        /// <returns></returns>
        [JsonIgnore]
        public string MessageMdToHtml { get => Markdown.ToHtml(Message, Settings.MdPipeline); }

        /// <summary>
        ///     Font Awesome классы для иконки в HTML.
        /// </summary>
        [JsonIgnore]
        public string Icon { get => IconBinding(Prefix); }
        /// <summary>
        ///     Цвет отображения в HTML.
        /// </summary>
        [JsonIgnore]
        public string Color { get => ColorBinding(Prefix); }

        public override string ToString() => $"{Prefix} - {Message} (#{Pr ?? 0})";

        public override int GetHashCode() => HashCode.Combine(Prefix, Message, Pr ?? 0);

        public override bool Equals(object? obj)
        {
            if (obj is null)
            {
                return false;
            }

            if (obj is Change change)
            {
                return change.GetHashCode() == GetHashCode();
            }

            return false;
        }


        /// <summary>
        ///     Возвращает класс FontAwesome инконки соответствующий для префикса.
        /// </summary>
        /// <param name="prefix">Префикс изменения.</param>
        public static string IconBinding(ChangePrefix prefix)
        {
            return prefix switch
            {
                ChangePrefix.BugFix => "fas fa-bug",
                ChangePrefix.Tweak => "fas fa-wrench",
                ChangePrefix.SoundAdd => "fas fa-music",
                ChangePrefix.SoundDel => "fas fa-minus",
                ChangePrefix.RscAdd => "fas fa-plus",
                ChangePrefix.RscDel => "fas fa-minus",
                ChangePrefix.ImageAdd => "fas fa-palette",
                ChangePrefix.ImageDel => "fas fa-minus",
                ChangePrefix.MapTweak => "far fa-compass",
                ChangePrefix.SpellCheck => "fas fa-spell-check",
                ChangePrefix.Experiment => "fas fa-hard-hat",
                ChangePrefix.Admin => "fas fa-crown",
                ChangePrefix.Balance => "fas fa-balance-scale",
                _ => throw new NotImplementedException($"  🚫 Для {prefix} не определена иконка.")
            };
        }

        /// <summary>
        ///     Возвращает цвет соответствующий префиксу.
        /// </summary>
        /// <param name="prefix"></param>
        /// <returns></returns>
        public static string ColorBinding(ChangePrefix prefix)
        {
            return prefix switch
            {
                ChangePrefix.BugFix
                or ChangePrefix.Tweak
                or ChangePrefix.SoundAdd
                or ChangePrefix.RscAdd
                or ChangePrefix.ImageAdd
                or ChangePrefix.MapTweak
                or ChangePrefix.SpellCheck
                or ChangePrefix.Admin => "green",
                ChangePrefix.Balance
                or ChangePrefix.Experiment => "yellow",
                ChangePrefix.SoundDel
                or ChangePrefix.RscDel
                or ChangePrefix.ImageDel => "red",
                _ => throw new NotImplementedException($"  🚫 Для {prefix} не определён цвет.")
            };
        }
    }
}

/// <summary>
///     Github things.
/// </summary>
public static class Github
{
    /// <summary>
    ///     PR Github.
    /// </summary>
    public sealed class PullRequest
    {
        /// <summary>
        ///     Ссылка на PR.
        /// </summary>
        [JsonPropertyName("html_url")]
        public string Url { get; init; } = string.Empty;
        /// <summary>
        ///     Номер PR.
        /// </summary>
        /// <value></value>
        public int Number { get; init; } = 0;
        /// <summary>
        ///     Тело PR.
        /// </summary>
        public string Body { get; init; } = string.Empty;
        /// <summary>
        ///     Автор PR.
        /// </summary>
        [JsonPropertyName("user")]
        public User Author { get; init; } = new();
        /// <summary>
        ///     Время открытия PR.
        /// </summary>
        /// <value></value>
        [JsonPropertyName("created_at")]
        public DateTime Opened { get; init; } = DateTime.Now;
        /// <summary>
        ///     Время закрытия PR.
        /// </summary>
        /// <value></value>
        [JsonPropertyName("closed_at")]
        public DateTime? Closed { get; init; } = null;
        /// <summary>
        ///     Плашки.
        /// </summary>
        public Label[] Labels { get; init; } = Array.Empty<Label>();

        private static readonly Regex s_clBody = new(@"(:cl:|🆑)(.+)?\r\n((.|\n|\r)+?)\r\n\/(:cl:|🆑)", RegexOptions.Multiline);
        private static readonly Regex s_clSplit = new(@"(^\w+):\s*(.*)", RegexOptions.Multiline);

        /// <summary>
        ///     Парсит чейнджлог из тела PR.
        /// </summary>
        /// <returns>Чейнджлог</returns>
        public Changelog ParseChangelog()
        {
            if (String.IsNullOrEmpty(Body))
            {
                throw new Exceptions.ChangelogNotFound("  🚫 Тело пулл реквеста пустое.");
            }

            var changesBody = s_clBody.Match(Body);

            if (!changesBody.Success)
            {
                throw new Exceptions.ChangelogNotFound("  🚫 Чейнджлог не обнаружен.");
            }

            var matches = s_clSplit.Matches(changesBody.Value);

            if (matches.Count == 0)
            {
                throw new Exceptions.ChangelogIsEmpty("  🚫 Чейнджлог пустой или имеет неверный формат.");
            }

            var author = changesBody.Groups[2].Value.Trim();

            if (string.IsNullOrEmpty(author))
            {
                author = Author.Login;
            }

            Changelog changelog = new()
            {
                Author = author,
                Date = DateTime.Now.Date
            };

            foreach (Match match in matches)
            {
                string[] parts = match.Value.Split(':');

                if (parts.Length < 2)
                {
                    throw new InvalidOperationException($"  🚫 Неверный формат изменения: '{match.Value}'");
                }

                var prefix = parts[0].Trim();
                var message = string.Join(':', parts[1..]).Trim();

                changelog.Changes.Add(new()
                {
                    Prefix = Enum.Parse<ChangePrefix>(prefix, true),
                    Message = message,
                    Pr = Number
                });
            }

            return changelog;
        }
    }

    /// <summary>
    ///     Пользователь Github.
    /// </summary>
    public sealed class User
    {
        /// <summary>
        ///     Логин пользователя.
        /// </summary>
        public string Login { get; init; } = string.Empty;
    }

    /// <summary>
    ///     Github Event Payload
    /// </summary>
    public sealed class Event
    {
        public string Action { get; init; } = string.Empty;
        [JsonPropertyName("pull_request")]
        public PullRequest? PullRequest { get; init; }
    }

    /// <summary>
    ///     Github Search Query
    /// </summary>
    public sealed class Search<T> where T : class
    {
        /// <summary>
        ///     Общее количество элементов.
        /// </summary>
        public int TotalCount { get; init; }
        /// <summary>
        ///     Элементы.
        /// </summary>
        public List<T> Items { get; init; } = new();
    }

    /// <summary>
    ///     Github Label.
    /// </summary>
    public sealed class Label
    {
        /// <summary>
        ///     Название плашки.
        /// </summary>
        public string Name { get; init; } = string.Empty;
        /// <summary>
        ///     Описание плашки.
        /// </summary>
        public string Description { get; init; } = string.Empty;
        /// <summary>
        ///     Цвет плашки.
        /// </summary>
        public string Color { get; init; } = string.Empty;
    }
}

public static class Exceptions
{
    public class ChangelogNotFound : Exception
    {
        public ChangelogNotFound() : base() {}
        public ChangelogNotFound(string message) : base(message) {}
        public ChangelogNotFound(string message, Exception inner) : base(message, inner) {}
    }

    public class ChangelogIsEmpty : Exception
    {
        public ChangelogIsEmpty() : base() { }
        public ChangelogIsEmpty(string message) : base(message) { }
        public ChangelogIsEmpty(string message, Exception inner) : base(message, inner) { }
    }
}
