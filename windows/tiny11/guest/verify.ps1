[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$stateDirectory = Join-Path $env:ProgramData 'LazyingArt'
$outputPath = Join-Path $stateDirectory 'tiny11-verification.json'
New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null

$operatingSystem = Get-CimInstance Win32_OperatingSystem
$computerSystem = Get-CimInstance Win32_ComputerSystem
$systemDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$sshdService = Get-Service sshd -ErrorAction SilentlyContinue
$guestAgentService = Get-Service QEMU-GA -ErrorAction SilentlyContinue
$rdpProperties = Get-ItemProperty `
    'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' `
    -Name fDenyTSConnections
$unexpectedDevices = @(
    Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
        Where-Object Status -NotIn @('OK', 'Unknown') |
        Select-Object Class, FriendlyName, Status, Problem
)
$weCom = Get-Package -Name 'WeCom' -ErrorAction SilentlyContinue |
    Select-Object -First 1 Name, Version, ProviderName

$result = [ordered]@{
    status = if ($unexpectedDevices.Count -eq 0) { 'complete' } else { 'review-devices' }
    verified_at = (Get-Date).ToString('o')
    computer = $env:COMPUTERNAME
    user = "$env:USERDOMAIN\$env:USERNAME"
    windows = [ordered]@{
        caption = $operatingSystem.Caption
        version = $operatingSystem.Version
        build = $operatingSystem.BuildNumber
        architecture = $operatingSystem.OSArchitecture
    }
    resources = [ordered]@{
        logical_processors = $computerSystem.NumberOfLogicalProcessors
        memory_gib = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 1)
        c_drive_size_gib = [math]::Round($systemDrive.Size / 1GB, 1)
        c_drive_free_gib = [math]::Round($systemDrive.FreeSpace / 1GB, 1)
    }
    services = [ordered]@{
        sshd = if ($sshdService) { $sshdService.Status.ToString() } else { 'Missing' }
        qemu_guest_agent = if ($guestAgentService) { $guestAgentService.Status.ToString() } else { 'Missing' }
    }
    rdp_enabled = $rdpProperties.fDenyTSConnections -eq 0
    wecom = $weCom
    unexpected_devices = $unexpectedDevices
}

$result | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -LiteralPath $outputPath
$result | ConvertTo-Json -Depth 6
