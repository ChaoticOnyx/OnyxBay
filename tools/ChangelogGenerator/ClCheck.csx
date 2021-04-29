#nullable enable
#load "Settings.csx"
#load "Models.csx"

using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using Console = System.Console;

// Получение переменных среды.
var githubRepository = Environment.GetEnvironmentVariable("GITHUB_REPOSITORY")
                       ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_REPOSITORY не найдена.");
var githubSha = Environment.GetEnvironmentVariable("GITHUB_SHA")
                ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_SHA не найдена.");
var githubEventPath = Environment.GetEnvironmentVariable("GITHUB_EVENT_PATH")
                      ?? throw new InvalidOperationException("🚫 Переменная среды GITHUB_EVENT_PATH не найдена.");

// Получение информации о PR
var eventPayaload = JsonSerializer.Deserialize<Github.Event>(File.ReadAllText(githubEventPath), Settings.JsonOptions)
                    ?? throw new InvalidOperationException($"🚫 Невозможно распарсить {githubEventPath}");

var pullRequest = eventPayaload.PullRequest;

if (pullRequest is null)
{
    WriteLine("🚫 PR не обнаружен.");

    return 1;
}

try
{
    var changelog = pullRequest.ParseChangelog();
}
catch (Exception e)
{
    WriteLine($"🚫 Ошибка при парсинге чейнджлога:\n\t{e.Message}");

    return 1;
}

WriteLine($"✅ Чейнджлог корректный.");

return 0;
