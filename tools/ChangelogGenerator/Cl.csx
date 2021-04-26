#nullable enable
#load "Settings.csx"
#load "Models.csx"

using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.RegularExpressions;
using Console = System.Console;

// Получение переменных среды.
var githubRepository = Environment.GetEnvironmentVariable("GITHUB_REPOSITORY") ?? throw new InvalidOperationException("Переменная среды GITHUB_REPOSITORY не найдена.");
var githubSha = Environment.GetEnvironmentVariable("GITHUB_SHA") ?? throw new InvalidOperationException("Переменная среды GITHUB_SHA не найдена.");

// Настройка HTTP клиента, получение и отправка запроса.
var client = new HttpClient();
client.DefaultRequestHeaders.UserAgent.ParseAdd("PostmanRuntime/7.28.0");
client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github.groot-preview+json");

var response = await client.GetAsync($"https://api.github.com/repos/{githubRepository}/commits/{githubSha}/pulls");
response.EnsureSuccessStatusCode();
var pullRequests = await response.Content.ReadFromJsonAsync<List<Github.PullRequest>>(Settings.JsonOptions) ?? throw new InvalidOperationException("Невозможно распарсить ответ от Github.");

// Проверка PR.
if (pullRequests.Count == 0)
{
    throw new InvalidOperationException($"Отсутствуют соответствующие PR для коммита {githubSha} или это прямой коммит.");
}

var pullRequest = pullRequests.First();

if (string.IsNullOrEmpty(pullRequest.Body))
{
    throw new InvalidOperationException("У PR отсутствует тело.");
}

// Парсинг тела PR.
var clBody = new Regex(@"(:cl:|🆑)(.+)?\r\n((.|\n|\r)+?)\r\n\/(:cl:|🆑)", RegexOptions.Multiline);
var clSplit = new Regex(@"(^\w+):\s+(\w.+)", RegexOptions.Multiline);

var changesBody = clBody.Match(pullRequest.Body).Value;
var matches = clSplit.Matches(changesBody);

if (string.IsNullOrEmpty(changesBody) || matches.Count == 0)
{
    throw new InvalidOperationException("Изменения в PR не найдены.");
}

Changelog changelog = new()
{
    Author = pullRequest.User.Login,
    Date = DateTime.Now
};

foreach (Match match in matches)
{
    string[] parts = match.Value.Split(':');

    if (parts.Length != 2)
    {
        throw new InvalidOperationException($"Неверный формат изменения: '{match.Value}'");
    }

    var prefix = parts[0].Trim();
    var message = parts[1].Trim();
    var anyErrors = false;

    if (!Settings.ValidPrefixes.Contains(prefix))
    {
        anyErrors = true;
        WriteLine($"Неверный префикс: {prefix}");
    }

    if (anyErrors)
    {
        return 1;
    }

    changelog.Changes.Add(new() {
        Prefix = prefix,
        Message = message
    });
}



// Сохранение чейнджлога.
var fileName = $"{Settings.ChangelogsFolder}{pullRequest.Number}.json";
WriteLine($"Сохранение чейнджлога в {fileName}");
File.WriteAllText(fileName, JsonSerializer.Serialize(changelog, Settings.JsonOptions));

return 0;
