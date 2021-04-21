#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;

public sealed class Changelog
{
    /// <summary>
    ///     Автор изменений.
    /// </summary>
    public string Author { get; init; }

    /// <summary>
    ///     Дата изменении.
    /// </summary>
    public DateTime Date { get; init; }

    /// <summary>
    ///     Изменения.
    /// </summary>
    public List<Change> Changes { get; init; } = new();

    public Changelog()
    {
        Author = string.Empty;
        Date = DateTime.Now;
    }

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
}

public sealed class Change
{
    /// <summary>
    ///     Префикс изменения.
    /// </summary>
    public string Prefix { get; init; }

    /// <summary>
    ///     Описание изменения.
    /// </summary>
    public string Message { get; init; }

    public Change()
    {
        Prefix = string.Empty;
        Message = string.Empty;
    }

    public override string ToString() => $"{Prefix} - {Message}";

    public override int GetHashCode() => HashCode.Combine(Prefix, Message);

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
}
