# Автоматическое обновление файлов кэша при изменении .css, .js, .css и .tmpl файлов в ChaoticOnyx/nano/**/*.

try
{
    $PreviousEvent = $null
    $NanoFolder = $PSScriptRoot
    $Watcher = New-Object IO.FileSystemWatcher $NanoFolder, '' -Property @{
        IncludeSubdirectories = $true
        NotifyFilter = [IO.NotifyFilters]'LastWrite'
    }

    Register-ObjectEvent $Watcher -EventName Changed -SourceIdentifier 'FileWatcher' -Action {
        # Минимальная задержка между событиями изменения файлов.
        # Так-как редакторы могут вызывать больше одного события за раз - необходимо фильтровать повторы.
        $Delay = 250
        $CacheDirectory = "$env:USERPROFILE/Documents/BYOND/cache/"

        if ($PreviousEvent -eq $null)
        {
            $PreviousEvent = $Event
        }

        $PreviousEventDate = Get-Date -Date $PreviousEvent.TimeGenerated
        $LastEventDate = Get-Date -Date $Event.TimeGenerated
        $EventDelay = [Math]::Abs(($LastEventDate.TimeOfDay - $PreviousEventDate.TimeOfDay).Milliseconds)

        if ($EventDelay -gt $Delay)
        {
            $PreviousEvent = $Event
            $ChangedFile = Get-Item $EventArgs.FullPath
            $Extension = $ChangedFile.Extension

            if (($Extension -ne '.css') -and ($Extension -ne '.js') -and ($Extension -ne '.css') -and ($Extension -ne '.tmpl'))
            {
                return
            }

            # Копирование файлов во все папки в кэше БЙОНДА.
            foreach ($Directory in Get-ChildItem $CacheDirectory -Attributes 'd')
            {
                Copy-Item $ChangedFile -Destination "$($Directory.FullName)/$($ChangedFile.Name)" -Force
                Write-Host "$($ChangedFile.Name) → $($Directory.FullName)/$($ChangedFile.Name)"
            }
        }
    }

    Write-Host 'Слежение за изменениями. Ctrl-C для выхода.'

    while ($true) { }
}
finally
{
    Unregister-Event -SourceIdentifier 'FileWatcher'
    Write-Host 'Выход...'
}
