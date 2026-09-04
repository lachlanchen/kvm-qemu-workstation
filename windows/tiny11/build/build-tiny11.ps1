[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceIso,

    [string]$WorkDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($WorkDirectory)) {
    $WorkDirectory = $PSScriptRoot
}
$sourceIsoPath = (Resolve-Path -LiteralPath $SourceIso).Path
$workPath = (Resolve-Path -LiteralPath $WorkDirectory).Path
$builderPath = Join-Path $workPath 'tiny11maker.ps1'
$answerSource = Join-Path $workPath 'source-autounattend.xml'
$answerActive = Join-Path $workPath 'autounattend.xml'
$outputIso = Join-Path $workPath 'tiny11.iso'
$resultPath = Join-Path $workPath 'build-result.json'
$mountedImage = $null

if (-not (Test-Path -LiteralPath $builderPath -PathType Leaf)) {
    throw "Builder not found: $builderPath"
}
if (-not (Test-Path -LiteralPath $answerSource -PathType Leaf)) {
    throw "Stock unattended file not found: $answerSource"
}

$admin = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'The Tiny11 build task must run elevated.'
}

Copy-Item -LiteralPath $answerSource -Destination $answerActive -Force
Remove-Item -LiteralPath $resultPath -Force -ErrorAction SilentlyContinue

try {
    $mountedImage = Mount-DiskImage -ImagePath $sourceIsoPath -PassThru
    $volume = $mountedImage | Get-Volume
    if (-not $volume.DriveLetter) {
        throw 'The mounted Windows ISO did not receive a drive letter.'
    }

    $setupExecutable = Join-Path "$($volume.DriveLetter):\" 'setup.exe'
    if (-not (Test-Path -LiteralPath $setupExecutable -PathType Leaf)) {
        throw 'The mounted image does not contain setup.exe.'
    }
    $setupSignature = Get-AuthenticodeSignature -LiteralPath $setupExecutable
    if ($setupSignature.Status -ne 'Valid') {
        throw "Microsoft setup.exe signature is not valid: $($setupSignature.Status)"
    }

    $installImage = Join-Path "$($volume.DriveLetter):\" 'sources\install.wim'
    if (-not (Test-Path -LiteralPath $installImage)) {
        $installImage = Join-Path "$($volume.DriveLetter):\" 'sources\install.esd'
    }
    if (-not (Test-Path -LiteralPath $installImage)) {
        throw 'The mounted ISO has neither sources\install.wim nor install.esd.'
    }

    $proImage = Get-WindowsImage -ImagePath $installImage |
        Where-Object { $_.ImageName -eq 'Windows 11 Pro' } |
        Select-Object -First 1
    if (-not $proImage) {
        throw 'The ISO does not contain an exact Windows 11 Pro image.'
    }

    Remove-Item -LiteralPath $outputIso -Force -ErrorAction SilentlyContinue
    & $builderPath `
        -ISO $volume.DriveLetter `
        -ImageIndex $proImage.ImageIndex `
        -NonInteractive
    if (-not (Test-Path -LiteralPath $outputIso -PathType Leaf)) {
        throw 'Tiny11 builder completed without producing tiny11.iso.'
    }

    $item = Get-Item -LiteralPath $outputIso
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputIso
    [ordered]@{
        status = 'complete'
        source_iso = $sourceIsoPath
        selected_image = $proImage.ImageName
        selected_index = $proImage.ImageIndex
        source_setup_signer = $setupSignature.SignerCertificate.Subject
        output_iso = $item.FullName
        output_bytes = $item.Length
        output_sha256 = $hash.Hash.ToLowerInvariant()
        completed_at = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $resultPath
} catch {
    [ordered]@{
        status = 'failed'
        message = $_.Exception.Message
        failed_at = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $resultPath
    throw
} finally {
    if ($mountedImage) {
        Dismount-DiskImage -ImagePath $sourceIsoPath -ErrorAction SilentlyContinue
    }
}
