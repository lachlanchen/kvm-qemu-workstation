[CmdletBinding()]
param(
    [string]$WorkDirectory
)

$ErrorActionPreference = 'Stop'
$builderCommit = '00e7d8a151a39ccffccab4a267bb81fb3756a01d'
$tiny11Root = Split-Path -Parent $PSScriptRoot
$workPath = if ([string]::IsNullOrWhiteSpace($WorkDirectory)) {
    Join-Path $env:LOCALAPPDATA 'KvmQemuWorkstation\Tiny11Build'
} else {
    [IO.Path]::GetFullPath($WorkDirectory)
}
$sourcePath = Join-Path $workPath 'tiny11builder-source'
$patchPath = Join-Path $PSScriptRoot 'patches\tiny11builder-noninteractive.patch'
$builderPath = Join-Path $workPath 'tiny11maker.ps1'
$answerPath = Join-Path $workPath 'source-autounattend.xml'

New-Item -ItemType Directory -Force -Path $workPath | Out-Null
foreach ($command in @('git.exe', 'powershell.exe')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is missing: $command"
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $sourcePath '.git'))) {
    & git.exe clone --filter=blob:none https://github.com/ntdevlabs/tiny11builder.git $sourcePath
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not clone the Tiny11 builder source.'
    }
}
$origin = (& git.exe -C $sourcePath remote get-url origin).Trim()
if ($LASTEXITCODE -ne 0 -or $origin -ne 'https://github.com/ntdevlabs/tiny11builder.git') {
    throw "Unexpected Tiny11 builder origin: $origin"
}
if ((& git.exe -C $sourcePath status --porcelain)) {
    throw 'The Tiny11 builder source checkout is modified; preserve or remove it before continuing.'
}
& git.exe -C $sourcePath fetch --depth=1 origin $builderCommit
if ($LASTEXITCODE -ne 0) {
    throw 'Could not fetch the audited Tiny11 builder commit.'
}
& git.exe -C $sourcePath checkout --detach $builderCommit
if ($LASTEXITCODE -ne 0) {
    throw 'Could not select the audited Tiny11 builder commit.'
}
if ((& git.exe -C $sourcePath rev-parse HEAD).Trim() -ne $builderCommit) {
    throw 'Tiny11 builder checkout does not match the audited commit.'
}

$sourceText = [IO.File]::ReadAllText((Join-Path $sourcePath 'tiny11maker.ps1'))
$normalizedSource = $sourceText.Replace("`r`n", "`n").Replace("`r", "`n")
[IO.File]::WriteAllText($builderPath, $normalizedSource, [Text.UTF8Encoding]::new($false))
Push-Location $workPath
try {
    & git.exe apply --unidiff-zero --no-index --unsafe-paths --whitespace=nowarn $patchPath
    if ($LASTEXITCODE -ne 0) {
        throw 'The audited Tiny11 non-interactive patch did not apply cleanly.'
    }
} finally {
    Pop-Location
}

Copy-Item -LiteralPath (Join-Path $tiny11Root 'autounattend.xml') -Destination $answerPath -Force
foreach ($name in @('build-tiny11.ps1', 'install-build-task.ps1', 'report-build.ps1')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $workPath $name) -Force
}

$drive = Get-Volume -DriveLetter C
if ($drive.SizeRemaining -lt 40GB) {
    throw "At least 40 GB free is required on C:; found $([Math]::Round($drive.SizeRemaining / 1GB, 1)) GB."
}

$oscdimg = Join-Path $workPath 'oscdimg.exe'
if (-not (Test-Path -LiteralPath $oscdimg -PathType Leaf)) {
    Invoke-WebRequest `
        -Uri 'https://msdl.microsoft.com/download/symbols/oscdimg.exe/3D44737265000/oscdimg.exe' `
        -OutFile $oscdimg `
        -UseBasicParsing
}

$item = Get-Item -LiteralPath $oscdimg
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $oscdimg).Hash.ToLowerInvariant()
$expectedHash = 'f5129f313ed7eb46f2677cf522e64264a225f226307ed0ddb52bb14c46e7cfdd'
if ($hash -ne $expectedHash -or $item.VersionInfo.ProductName -ne 'OSCDIMG') {
    throw 'oscdimg.exe failed its pinned SHA-256 or PE identity check.'
}

[ordered]@{
    status = 'ready'
    work_directory = $workPath
    builder_commit = $builderCommit
    free_gib = [Math]::Round($drive.SizeRemaining / 1GB, 1)
    oscdimg_sha256 = $hash
    oscdimg_version = $item.VersionInfo.FileVersion
    prepared_at = (Get-Date).ToString('o')
} | ConvertTo-Json
