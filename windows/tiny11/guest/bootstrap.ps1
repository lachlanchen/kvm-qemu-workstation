[CmdletBinding()]
param(
    [string]$TimeZone = 'China Standard Time'
)

$ErrorActionPreference = 'Stop'
$stateDirectory = Join-Path $env:ProgramData 'LazyingArt'
$logPath = Join-Path $stateDirectory 'tiny11-bootstrap.log'
$markerPath = Join-Path $stateDirectory 'tiny11-bootstrap-complete.json'
New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
Start-Transcript -Path $logPath -Append

try {
    powercfg.exe /change standby-timeout-ac 0 | Out-Null
    powercfg.exe /change monitor-timeout-ac 0 | Out-Null
    powercfg.exe /hibernate off | Out-Null
    Set-TimeZone -Id $TimeZone

    Set-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' `
        -Name fDenyTSConnections `
        -Type DWord `
        -Value 0
    Set-ItemProperty `
        -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
        -Name UserAuthentication `
        -Type DWord `
        -Value 1
    if (-not (Get-NetFirewallRule -DisplayName 'RDP for local KVM forward' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule `
            -DisplayName 'RDP for local KVM forward' `
            -Direction Inbound `
            -Action Allow `
            -Protocol TCP `
            -LocalPort 3389 `
            -Profile Any | Out-Null
    }

    $sshCapability = Get-WindowsCapability -Online |
        Where-Object Name -Like 'OpenSSH.Server*' |
        Select-Object -First 1
    if ($sshCapability.State -ne 'Installed') {
        Add-WindowsCapability -Online -Name $sshCapability.Name | Out-Null
    }
    Set-Service -Name sshd -StartupType Automatic
    Start-Service -Name sshd
    if (-not (Get-NetFirewallRule -DisplayName 'OpenSSH for local KVM forward' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule `
            -DisplayName 'OpenSSH for local KVM forward' `
            -Direction Inbound `
            -Action Allow `
            -Protocol TCP `
            -LocalPort 22 `
            -Profile Any | Out-Null
    }

    $sourceKey = Join-Path $PSScriptRoot 'authorized_keys'
    if (Test-Path -LiteralPath $sourceKey) {
        $sshDirectory = Join-Path $env:ProgramData 'ssh'
        $adminKeys = Join-Path $sshDirectory 'administrators_authorized_keys'
        New-Item -ItemType Directory -Force -Path $sshDirectory | Out-Null
        Copy-Item -LiteralPath $sourceKey -Destination $adminKeys -Force
        & icacls.exe $adminKeys '/inheritance:r' '/grant' 'SYSTEM:F' '/grant' 'Administrators:F' | Out-Null
    }

    $virtioInstaller = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=5' |
        ForEach-Object { Join-Path "$($_.DeviceID)\" 'virtio-win-guest-tools.exe' } |
        Where-Object { Test-Path -LiteralPath $_ } |
        Select-Object -First 1
    if ($virtioInstaller) {
        $process = Start-Process `
            -FilePath $virtioInstaller `
            -ArgumentList '/quiet', '/norestart' `
            -Wait `
            -PassThru
        if ($process.ExitCode -notin @(0, 3010)) {
            throw "VirtIO guest tools exited with code $($process.ExitCode)."
        }
    }

    $guestAgent = Get-Service -Name 'QEMU-GA' -ErrorAction SilentlyContinue
    if ($guestAgent) {
        Set-Service -Name $guestAgent.Name -StartupType Automatic
        Start-Service -Name $guestAgent.Name -ErrorAction SilentlyContinue
    }

    [ordered]@{
        status = 'complete'
        computer = $env:COMPUTERNAME
        user = "$env:USERDOMAIN\$env:USERNAME"
        rdp_enabled = $true
        ssh_enabled = (Get-Service sshd).Status -eq 'Running'
        virtio_installer = $virtioInstaller
        completed_at = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $markerPath
} catch {
    [ordered]@{
        status = 'failed'
        message = $_.Exception.Message
        failed_at = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $markerPath
    throw
} finally {
    Stop-Transcript
}
