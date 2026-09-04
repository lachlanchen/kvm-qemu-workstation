param(
    [string]$WorkDirectory,
    [string]$TaskName = 'LazyingArt-Build-Tiny11'
)

$workPath = if ([string]::IsNullOrWhiteSpace($WorkDirectory)) {
    Join-Path $env:LOCALAPPDATA 'KvmQemuWorkstation\Tiny11Build'
} else {
    (Resolve-Path -LiteralPath $WorkDirectory).Path
}
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
$info = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
$resultPath = Join-Path $workPath 'build-result.json'
$latestLog = Get-ChildItem `
    -LiteralPath $workPath `
    -Filter 'tiny11_*.log' `
    -File `
    -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

[ordered]@{
    task_state = if ($task) { [string]$task.State } else { 'Missing' }
    last_result = if ($info) { $info.LastTaskResult } else { $null }
    last_run = if ($info) { $info.LastRunTime.ToString('o') } else { $null }
    result_exists = Test-Path -LiteralPath $resultPath -PathType Leaf
    output_iso_exists = Test-Path -LiteralPath (Join-Path $workPath 'tiny11.iso') -PathType Leaf
    output_iso_bytes = if (Test-Path -LiteralPath (Join-Path $workPath 'tiny11.iso')) {
        (Get-Item -LiteralPath (Join-Path $workPath 'tiny11.iso')).Length
    } else { 0 }
    latest_log = if ($latestLog) { $latestLog.FullName } else { $null }
} | ConvertTo-Json -Compress

if (Test-Path -LiteralPath $resultPath -PathType Leaf) {
    Write-Output '--- result ---'
    Get-Content -LiteralPath $resultPath
}
if ($latestLog) {
    Write-Output '--- log tail ---'
    Get-Content -LiteralPath $latestLog.FullName -Tail 30
}
