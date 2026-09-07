[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Installer,
    [Parameter(Mandatory = $true)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$Sha256,
    [Parameter(Mandatory = $true)][version]$Version,
    [switch]$Install
)

# Run from an elevated Windows PowerShell. No account copying or reboot.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$installerPath = (Resolve-Path -LiteralPath $Installer).Path
if ((Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash -ne $Sha256) {
    throw 'Installer SHA-256 mismatch.'
}
$signature = Get-AuthenticodeSignature -LiteralPath $installerPath
if ($signature.Status -ne 'Valid' -or
    $signature.SignerCertificate.Subject -notmatch 'CN="?NetEase \(Hangzhou\) Network Co\., Ltd"?(,|$)') {
    throw 'Installer does not have a valid NetEase signature.'
}
if ([version](Get-Item -LiteralPath $installerPath).VersionInfo.FileVersion -ne $Version) {
    throw 'Installer version does not match the reviewed version.'
}
$exe = Join-Path $env:ProgramFiles 'Netease\GameViewer\GameViewer.exe'
$existing = if (Test-Path -LiteralPath $exe) { [version](Get-Item $exe).VersionInfo.FileVersion } else { $null }
$status = 'validated-only'
if ($existing -and $existing -ge $Version) {
    $status = 'already-installed'
} elseif ($Install) {
    if ($existing) {
        throw 'An older UU install exists. Use its normal updater in a separate maintenance window.'
    }
    $admin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'An elevated PowerShell is required for installation.'
    }
    $process = Start-Process -FilePath $installerPath -ArgumentList '/S' -PassThru
    if (-not $process.WaitForExit(180000)) {
        throw 'Installer is still running after three minutes. Inspect it before rerunning; it was not killed.'
    }
    $process.Refresh()
    if ($process.ExitCode -ne 0) { throw "Installer exited $($process.ExitCode)." }
    if (-not (Test-Path -LiteralPath $exe)) { throw 'Expected UU executable is missing after installation.' }
    $existing = [version](Get-Item $exe).VersionInfo.FileVersion
    if ($existing -ne $Version) { throw 'Installed version differs from the reviewed version.' }
    $status = 'installed'
}
[ordered]@{
    status = $status
    reviewed_version = [string]$Version
    installed_version = [string]$existing
    installer_sha256 = $Sha256.ToLowerInvariant()
    executable = $exe
    account_login = 'Check the native UU window; this script never copies login state.'
} | ConvertTo-Json
