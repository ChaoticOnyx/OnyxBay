#!/usr/bin/env dotnet-script
#nullable enable
#load "Settings.csx"
#load "Models.csx"

using System.Globalization;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;

WriteLine("[1] Сбор настроек.");
var githubRepository = Environment.GetEnvironmentVariable("GITHUB_REPOSITORY")
                       ?? throw new InvalidOperationException("[1] 🚫Переменная среды GITHUB_REPOSITORY не найдена.");

var token = Environment.GetEnvironmentVariable("TOKEN");

WriteLine($" │  Используется репозитории {githubRepository}");

// Настройка HTTP клиента
var client = new HttpClient();
client.DefaultRequestHeaders.UserAgent.ParseAdd("PostmanRuntime/7.28.0");
client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github.groot-preview+json");

if (token is not null)
{
    WriteLine("[1] Используется токен авторизации.");
    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
}
else
{
    WriteLine("[1] Токен авторизации не обнаружен.");
}

WriteLine("[2] Поиск PR.");
var page = 0;
var lastClosedPrDate = DateTime.Parse(File.ReadAllLines(Settings.LastClosedPrDateFile.FullName)[0], CultureInfo.InvariantCulture);
var newLastClosedPrDate = lastClosedPrDate;

while (true)
{
    page++;
    var response = await client.GetAsync($"https://api.github.com/search/issues?q=repo:{githubRepository} is:pr is:merged merged:>={lastClosedPrDate.AddDays(-1).ToString("yyyy-MM-dd")} label:\"{Uri.EscapeUriString(Settings.ChangelogCheckedLabel)}\"&order=desc&per_page=100&sort=created&page={page}");
    var searchResponse = await response.Content.ReadFromJsonAsync<Github.Search<Github.PullRequest>>(Settings.JsonOptions)
                         ?? throw new InvalidOperationException("[2]🚫Невозможно распарсить ответ от Github.");

    if (searchResponse.Items.Count == 0)
    {
        WriteLine("[2] Больше PR не обнаружено.");
        File.WriteAllText(Settings.LastClosedPrDateFile.FullName, newLastClosedPrDate.ToString(CultureInfo.InvariantCulture));

        return 0;
    }

    foreach (var pullRequest in searchResponse.Items)
    {
        if (pullRequest.Closed is null || pullRequest.Closed <= lastClosedPrDate)
        {
            continue;
        }

        if (pullRequest.Closed > newLastClosedPrDate)
        {
            newLastClosedPrDate = (DateTime)pullRequest.Closed;
        }

        // Парсинг чейнджлога.
        try
        {
            Changelog changelog = pullRequest.ParseChangelog();
            var changelogPath = Path.GetFullPath($"PR-{pullRequest.Number}.json", Settings.ChangelogsFolder.FullName);
            File.WriteAllText(changelogPath, JsonSerializer.Serialize(changelog, Settings.JsonOptions));
            WriteLine($" │  ✅Чейнджлог PR #{pullRequest.Number} ({changelog.Changes.Count} изм.) сохранён.");
        }
        catch (Exception e)
        {
            WriteLine($"[2] 🚫Исключение при парсинге PR #{pullRequest.Number}:\n\t{e.Message}");
        }
    }

    // Задержка для ограничения запросов.
    Thread.Sleep(TimeSpan.FromSeconds(token is null ? 7 : 3));
}
