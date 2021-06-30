class GithubRepository
{
    [string]$Name
    [string]$Owner
    [Uri]$Url

    [string]ToString()
    {
        return "$($this.Owner)/$($this.Name)"
    }

    static [GithubRepository]FromJson($object)
    {
        [GithubRepository]$Repository = @{
            Name  = $object.name
            Owner = $object.owner.login
            Url   = $object.html_url
        }

        return $Repository
    }
}

class GithubCi
{
    [GithubRepository]$Repository
    [string]$Workspace
}

class LineRange
{
    [int]$Start
    [int]$End
}

class PullRequestFile
{
    [string]$FileName
    [int[]]$ChangedLines
}

class Asset
{
    [string]$Name
    [Uri]$Url

    static [Asset]FromJson($object)
    {
        [Asset]$asset = @{
            Name = $object.name
            Url  = $object.browser_download_url
        }

        return $asset
    }
}

class Release
{
    [Uri]$Url
    [Asset[]]$Assets

    static [Release]FromJsom($object)
    {
        [Release]$release = @{
            Url    = $object.html_url
            Assets = [Asset[]]@()
        }

        foreach ($asset in $object.assets)
        {
            $release.Assets += [Asset]::FromJson($asset)
        }

        return $release
    }
}

$DefaultHeader = @{ Accept = 'application/vnd.github.groot-preview+json' }
$BaseUri = 'https://api.github.com'

function Get-GithubRepository
{
    <#
        .SYNOPSIS
            Возвращает объект репозитория Github.
        .PARAMETER Name
            Название репозитория.
        .PARAMETER Owner
            Владелец репозитория.
        .OUTPUTS
            [GithubRepository] - репозитории GitHub.
        .EXAMPLE
            Get-GithubRepository -Name 'OnyxBay' -Owner 'ChaoticOnyx'
    #>

    [CmdletBinding()]
    [OutputType([GithubRepository])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Owner
    )

    PROCESS
    {
        $Uri = "$BaseUri/repos/$Owner/$Name"
        Write-Verbose "Запрос на $Uri"

        try
        {
            $Response = Invoke-WebRequest -Uri  $Uri -Method Get -Headers $DefaultHeader -SslProtocol Tls12
        }
        catch
        {
            throw $_.Exception
        }
        
        return [GithubRepository]::FromJson(($Response.Content | ConvertFrom-Json))
    }
}

function Get-GithubEnvironment
{
    <#
        .SYNOPSIS
            Возвращает объект c информацией об Github CI окружении из переменных среды.
        .OUTPUTS
            [GithubCi] - Объект с информацией об Github CI окружении. Null - когда окружение не обнаружено.
        .EXAMPLE
            $Ci = Get-GithubEnvironment
    #>

    [CmdletBinding()]
    [OutputType([GithubCi])]
    param()

    PROCESS
    {
        if ($null -eq $env:GITHUB_REPOSITORY)
        {
            Write-Error 'Переменная GITHUB_REPOSITORY не найдена.'
            return $null
        }

        if ($null -eq $env:GITHUB_WORKSPACE)
        {
            Write-Error 'Переменная GITHUB_WORKSPACE не найдена.'
            return $null
        }

        [string]$RepoAndOwner = $env:GITHUB_REPOSITORY

        return [GithubCi]@{
            Repository = [GithubRepository]@{
                Name  = $RepoAndOwner.Split('/')[1]
                Owner = $RepoAndOwner.Split('/')[0]
            }
            Workspace  = $env:GITHUB_WORKSPACE
        }
    }
}

function Get-GithubPullRequestFiles
{
    <#
        .SYNOPSIS
            Возвращает список изменённых в PR файлов.
        .DESCRIPTION
            Возвращает список изменённых в PR файлов с диапазонами изменённых строк.
            Подробнее - https://docs.github.com/en/rest/reference/pulls#list-pull-requests-files
        .EXAMPLE
            (Get-GithubEnvironment).Repository | Get-GithubPullRequestFiles -PullRequestNumber 7
        .EXAMPLE
            Get-GithubPullRequestFiles -Repository @{ Name = 'OnyxBay'; Owner = 'ChaoticOnyx' } -PullRequestNumber 5250
        .PARAMETER Repository
            Репозитории.
        .PARAMETER PullRequestNumber
            Номер PR, у которого нужно получить список файлов.
        .OUTPUTS
            [PullRequestFile[]] - список файлов, изменённых в PR.
    #>

    [CmdletBinding()]
    [OutputType([PullRequestFile[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [GithubRepository]$Repository,
        [Parameter(Mandatory)]
        [int]$PullRequestNumber
    )

    PROCESS
    {
        $Uri = "$BaseUri/repos/$($Repository.Owner)/$($Repository.Name)/pulls/$PullRequestNumber/files"
        Write-Verbose "Запрос на $Uri"
        try
        {
            $Response = Invoke-WebRequest -Uri $Uri -Method Get -Headers $DefaultHeader -SslProtocol Tls12
        }
        catch
        {
            throw $_.Exception
        }

        $RawFiles = $Response.Content | ConvertFrom-Json | Select-Object -Property 'filename', 'patch'
        [PullRequestFile[]]$Files = @()

        foreach ($RawFile in $RawFiles)
        {
            Write-Debug "Парсинг изменений в $($RawFile.FileName)"
            $Lines = ($RawFile.Patch -Split "`n")
            [int[]]$ChangedLines = @()

            foreach ($Line in $Lines)
            {
                $Match = ($Line | Select-String -Pattern '\+(?<line>\d+),(?<lines_count>\d+)' -AllMatches).Matches
                $StartLine = ($Match.Groups | Where-Object -Property 'name' -EQ 'line' | Select-Object -ExpandProperty 'value') -as [int]

                if ($StartLine -ne 0)
                {
                    $i = $StartLine - 1
                }

                if ($Line[0] -eq '+')
                {
                    Write-Debug "Изменена строка $i"
                    $ChangedLines += $i
                    $i++
                }
                elseif ($Line[0] -ne '-')
                {
                    $i++
                }
            }

            $Files += [PullRequestFile]@{
                FileName     = $RawFile.FileName
                ChangedLines = $ChangedLines
            }
        }

        return $Files
    }
}

function Get-GithubLastRelease
{
    <#
        .SYNOPSIS
            Возвращает последний релиз в указанном репозитории.
        .PARAMETER Repository
            Репозитории в котором нужно получить последний релиз.
        .EXAMPLE
            Get-GithubLastRelease -Repository @{ Name = 'OnyxBay'; Owner = 'ChaoticOnyx' }
        .OUTPUTS
            [Release] - Последний релиз из репозитория.
    #>

    [CmdletBinding()]
    [OutputType([Release])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [GithubRepository]$Repository
    )

    PROCESS
    {
        $Uri = "$BaseUri/repos/$($Repository.Owner)/$($Repository.Name)/releases/latest"

        try
        {
            $Response = Invoke-WebRequest -Uri $Uri -Method Get -Headers $DefaultHeader -SslProtocol Tls12
        }
        catch
        {
            throw $_.Exception
        }

        return [Release]::FromJsom(($Response.Content | ConvertFrom-Json))
    }
}

function Format-GithubWorkflowMessage
{
    <#
        .SYNOPSIS
            Форматирует сообщение в формате Github Workflow.
        .PARAMETER Level
            Уровень сообщения - 'error' или 'warning'.
        .PARAMETER FileName
            Относительный путь до файла, с которым связанно сообщение.
        .PARAMETER Line
            Номер строки, с которым связанно сообщение.
        .PARAMETER Column
            Положение в строке, с которым связанно сообщение.
        .PARAMETER Message
            Само сообщение.
        .EXAMPLE
            Format-GithubWorkflowMessage -Level error -Message 'There is an error'
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('error', 'warning')]
        [string]$Level,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Message,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FileName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Line,
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Column
    )

    PROCESS
    {
        $Formated = "::$Level "

        if (-not [string]::IsNullOrEmpty($FileName))
        {
            if ($null -eq $Line)
            {
                throw '-Line is null'
            }

            if ($null -eq $Column)
            {
                throw '-Column is null'
            }

            $Formated += "file=$FileName,line=$Line,col=$Column"
        }

        $Formated += "::$Message"

        Write-Output $Formated
    }
}
