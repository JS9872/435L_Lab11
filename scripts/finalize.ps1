$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$root = Split-Path $PSScriptRoot -Parent
$output = Join-Path $root 'deliverables'
$archive = Join-Path $output 'source.zip'
if (Test-Path $archive) { Remove-Item -LiteralPath $archive }
$zip = [System.IO.Compression.ZipFile]::Open($archive, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = @('README.md', '.gitignore', '.gitattributes') | ForEach-Object { Get-Item (Join-Path $root $_) }
    foreach ($folder in @('src', 'docs', 'packaging', 'scripts')) {
        $files += Get-ChildItem (Join-Path $root $folder) -File -Recurse
    }
    $files += Get-ChildItem (Join-Path $root 'report') -File | Where-Object Extension -In @('.py', '.ps1')
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative) | Out-Null
    }
} finally { $zip.Dispose() }
$lines = Get-ChildItem $output -File | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object {
    '{0}  {1}' -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.Name
}
[System.IO.File]::WriteAllLines((Join-Path $output 'SHA256SUMS.txt'), $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host 'Source archive and SHA-256 submission manifest finalized.'
