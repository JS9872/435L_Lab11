param([string]$PopplerBin)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$qa = Join-Path $PSScriptRoot 'qa'
New-Item $qa -ItemType Directory -Force | Out-Null
$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $document = $word.Documents.Open((Join-Path $root 'deliverables\Lab11_Report_Joey_Saade.docx'))
    try {
        $document.Fields.Update() | Out-Null
        $document.ExportAsFixedFormat((Join-Path $qa 'report.pdf'), 17)
        Write-Host "Rendered pages: $($document.ComputeStatistics(2))"
    } finally { $document.Close(0) }
} finally { $word.Quit() }
if ($PopplerBin) {
    & "$PopplerBin\pdftoppm.exe" -r 100 -png "$qa\report.pdf" "$qa\page"
    if ($LASTEXITCODE -ne 0) { throw 'Page rasterization failed' }
}
