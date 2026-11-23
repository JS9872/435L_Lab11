param([Parameter(Mandatory=$true)][ValidateSet('WindowsBuild','WindowsVerify','DebianBuild','DebianVerify','RpmBuild','RpmVerify')][string]$Stage)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$host.UI.RawUI.WindowTitle = "435L Lab 11 - $Stage - Joey Saade"
$host.UI.RawUI.BackgroundColor = 'Black'
$host.UI.RawUI.ForegroundColor = 'White'
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(112, 2000)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(112, 42)
} catch { }
Clear-Host
Write-Host "EECE 435L | Joey Saade | 202305993 | $Stage" -ForegroundColor Cyan
Write-Host ('=' * 76)
$log = Join-Path $root "evidence/logs/$Stage.txt"
Start-Transcript -Path $log -Force | Out-Null
try {
    switch ($Stage) {
        'WindowsBuild' {
            Write-Host 'PS> .\scripts\build-windows.ps1 (WiX 3.14.1 candle + light)'
            & ./scripts/build-windows.ps1
            Write-Host 'PS> Get-Item deliverables/helloworld_joey_saade.msi'
            Get-Item deliverables/helloworld_joey_saade.msi | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
            Write-Host 'ICE91 alone is excluded: this is intentionally per-user only.'
            Write-Host 'All remaining MSI validation checks run normally.'
        }
        'WindowsVerify' {
            Write-Host 'PS> .\scripts\verify-windows.ps1'
            & ./scripts/verify-windows.ps1
        }
        'DebianBuild' {
            Write-Host 'PS> docker exec 435l-lab11-debian sh -c "gcc ...; dpkg-deb --build ..."'
            docker exec 435l-lab11-debian sh scripts/evidence-debian-build.sh
            if ($LASTEXITCODE -ne 0) { throw 'DEB evidence failed' }
        }
        'DebianVerify' {
            Write-Host 'PS> docker exec 435l-lab11-debian sh scripts/verify-debian.sh'
            docker exec 435l-lab11-debian sh scripts/verify-debian.sh
            if ($LASTEXITCODE -ne 0) { throw 'DEB verification failed' }
        }
        'RpmBuild' {
            Write-Host 'PS> docker exec 435l-lab11-debian sh -c "rpmbuild ...; rpm -qip ..."'
            docker exec 435l-lab11-debian sh scripts/evidence-rpm-build.sh
            if ($LASTEXITCODE -ne 0) { throw 'RPM evidence failed' }
        }
        'RpmVerify' {
            Write-Host 'PS> docker exec 435l-lab11-fedora sh scripts/verify-fedora.sh'
            docker exec 435l-lab11-fedora sh -c 'rpm -q helloworld-joey-saade >/dev/null && rpm -e helloworld-joey-saade; sh scripts/verify-fedora.sh'
            if ($LASTEXITCODE -ne 0) { throw 'RPM verification failed' }
        }
    }
    Write-Host 'SUCCESS - commands completed without errors' -ForegroundColor Green
    New-Item "build/$Stage.complete" -ItemType File -Force | Out-Null
} catch {
    Write-Host "FAILED: $_" -ForegroundColor Red
    $_ | Out-String | Set-Content "build/$Stage.failed"
} finally {
    Stop-Transcript | Out-Null
}
Write-Host 'Evidence captured from actual execution; close this window when finished.'
