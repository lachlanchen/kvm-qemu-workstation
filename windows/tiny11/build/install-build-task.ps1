[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceIso,

    [string]$WorkDirectory,

    [string]$TaskName = 'LazyingArt-Build-Tiny11'
)

$ErrorActionPreference = 'Stop'
$workPath = if ([string]::IsNullOrWhiteSpace($WorkDirectory)) {
    Join-Path $env:LOCALAPPDATA 'KvmQemuWorkstation\Tiny11Build'
} else {
    (Resolve-Path -LiteralPath $WorkDirectory).Path
}
$runnerPath = Join-Path $workPath 'build-tiny11.ps1'
$sourceIsoPath = (Resolve-Path -LiteralPath $SourceIso).Path
$interactiveUser = (Get-CimInstance Win32_ComputerSystem).UserName

if ([string]::IsNullOrWhiteSpace($interactiveUser)) {
    throw 'No interactively logged-in user was detected.'
}

$arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass ' +
    '-File "' + $runnerPath + '" ' +
    '-SourceIso "' + $sourceIsoPath + '" ' +
    '-WorkDirectory "' + $workPath + '"'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arguments
$principal = New-ScheduledTaskPrincipal `
    -UserId $interactiveUser `
    -LogonType Interactive `
    -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 4)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Principal $principal `
    -Settings $settings `
    -Description 'Build a serviceable Tiny11 ISO from an official Microsoft ISO.' `
    -Force | Out-Null

Start-ScheduledTask -TaskName $TaskName
Write-Output "Started $TaskName as $interactiveUser."
