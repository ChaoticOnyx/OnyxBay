#nullable enable
#load "Settings.csx"
#load "Models.csx"

using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;

// Получение переменных среды.
var githubRepository = Environment.GetEnvironmentVariable("GITHUB_REPOSITORY")
                       ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_REPOSITORY не найдена.");
var token = Environment.GetEnvironmentVariable("TOKEN")
                ?? throw new InvalidOperationException("🚫 Переменная среды TOKEN не найдена.");
var githubEventPath = Environment.GetEnvironmentVariable("GITHUB_EVENT_PATH")
                      ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_EVENT_PATH не найдена.");

// Настройка HTTP клиента
var client = new HttpClient();
client.BaseAddress = new("https://api.github.com/");
client.DefaultRequestHeaders.UserAgent.ParseAdd("PostmanRuntime/7.28.0");
client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github.groot-preview+json");
client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

// Получение информации о PR
var eventPayaload = JsonSerializer.Deserialize<Github.Event>(File.ReadAllText(githubEventPath), Settings.JsonOptions)
                    ?? throw new InvalidOperationException($"🚫 Невозможно распарсить {githubEventPath}");

var pullRequest = eventPayaload.PullRequest;

if (pullRequest is null)
{
    WriteLine("🚫 PR не обнаружен.");

    return 1;
}

if (pullRequest.Labels.Any(l => l.Name == Settings.ChangelogNotRequiredLabel))
{
    WriteLine("✅ Чейнджлог не требуется.");
    return 0;
}

try
{
    var changelog = pullRequest.ParseChangelog();
}
catch (Exception e)
{
    WriteLine($"🚫 Ошибка при парсинге чейнджлога:\n\t{e.Message}");
    // Удаление плашки проверенного чейнджлога.
    await client.DeleteAsync($"repos/{githubRepository}/issues/{pullRequest.Number}/labels/{Uri.EscapeUriString(Settings.ChangelogCheckedLabel)}");
    // Добавление плашки о требовании чейнджлога.
    var putResponse = await client.PutAsync($"repos/{githubRepository}/issues/{pullRequest.Number}/labels", new StringContent($"{{ \"labels\": [\"{Settings.ChangelogRequiredLabel}\"] }}"));
    putResponse.EnsureSuccessStatusCode();

    return 1;
}

WriteLine($"✅ Чейнджлог корректный.");

// Удаление плашки о требовании чейнджлога.
await client.DeleteAsync($"repos/{githubRepository}/issues/{pullRequest.Number}/labels/{Uri.EscapeUriString(Settings.ChangelogRequiredLabel)}");
// Добавление плашки о наличии чейнджлога.
var putResponse = await client.PutAsync($"repos/{githubRepository}/issues/{pullRequest.Number}/labels", new StringContent($"{{ \"labels\": [\"{Settings.ChangelogCheckedLabel}\"] }}"));
putResponse.EnsureSuccessStatusCode();

return 0;
