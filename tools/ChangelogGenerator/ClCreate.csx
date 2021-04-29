#nullable enable
#load "Settings.csx"
#load "Models.csx"

using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;

// Получение переменных среды.
var githubRepository = Environment.GetEnvironmentVariable("GITHUB_REPOSITORY")
                       ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_REPOSITORY не найдена.");
var githubSha = Environment.GetEnvironmentVariable("GITHUB_SHA")
                ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_SHA не найдена.");

// Настройка HTTP клиента, получение и отправка запроса.
var client = new HttpClient();
client.DefaultRequestHeaders.UserAgent.ParseAdd("PostmanRuntime/7.28.0");
client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github.groot-preview+json");
var page = 0;
var lastPrNumber = int.Parse(File.ReadAllLines(Settings.LastPrFile)[0]);
var newLastPrNumber = lastPrNumber;

// Парсинг PR.
while (true)
{
    page++;
    var response = await client.GetAsync($"https://api.github.com/search/issues?q=repo:{githubRepository} is:pr is:merged&order=desc&per_page=100&page={page}");
    var searchResponse = await response.Content.ReadFromJsonAsync<Github.Search<Github.PullRequest>>(Settings.JsonOptions)
                         ?? throw new InvalidOperationException("🚫 Невозможно распарсить ответ от Github.");

    if (searchResponse.Items.Count == 0)
    {
        File.WriteAllText(Settings.LastPrFile, newLastPrNumber.ToString());

        return 0;
    }

    foreach (var pullRequest in searchResponse.Items)
    {
        if (pullRequest.Number > newLastPrNumber)
        {
            newLastPrNumber = pullRequest.Number;
        }

        if (pullRequest.Number <= lastPrNumber)
        {
            WriteLine("✅ Больше PR не обнаружено.");
            File.WriteAllText(Settings.LastPrFile, newLastPrNumber.ToString());

            return 0;
        }

        // Парсинг ченйджлога.
        try
        {
            Changelog changelog = pullRequest.ParseChangelog();
            var changelogPath = Path.GetFullPath($"PR-{pullRequest.Number}.json", Settings.ChangelogsFolder);
            File.WriteAllText(changelogPath, JsonSerializer.Serialize(changelog, Settings.JsonOptions));
            WriteLine($"✅ Чейнджлог PR #{pullRequest.Number} сохранён.");
        }
        catch (Exception e)
        {
            WriteLine($"🚫 Исключение при парсинге PR #{pullRequest.Number}:\n\t{e.Message}");
        }
    }

    // Задержка для ограничения запросов.
    Thread.Sleep(TimeSpan.FromSeconds(7));
}
