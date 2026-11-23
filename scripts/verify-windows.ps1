$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$msi = Join-Path $root 'deliverables\helloworld_joey_saade.msi'
$logs = Join-Path $root 'evidence\logs'
New-Item $logs -ItemType Directory -Force | Out-Null
$installer = New-Object -ComObject WindowsInstaller.Installer
$database = $installer.OpenDatabase($msi, 0)
$view = $database.OpenView('SELECT `Property`, `Value` FROM `Property`')
$view.Execute()
$properties = @{}
while ($record = $view.Fetch()) { $properties[$record.StringData(1)] = $record.StringData(2) }
$properties.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize
$properties | ConvertTo-Json | Set-Content "$logs/msi-properties.json"
$view.Close()
$productCode = $properties['ProductCode']
Write-Host 'COMMAND: msiexec /i helloworld_joey_saade.msi /qb /norestart'
$process = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qb /norestart /l*v `"$logs/msi-install-verbose.log`"" -Wait -PassThru
Write-Host "MSI install exit code: $($process.ExitCode)"
if ($process.ExitCode -ne 0) { throw 'MSI installation failed' }
$folder = Join-Path $env:LOCALAPPDATA 'Programs\JoeySaadeHelloWorld'
$output = & "$folder/helloworld.exe"
Write-Host $output
if ($LASTEXITCODE -ne 0 -or $output -cne 'Hello, World from Joey_Saade!') { throw 'Installed output differs' }
foreach ($document in @('README.md', 'help.txt', 'user_guide.txt')) {
    if ((Get-FileHash "$root/docs/$document").Hash -ne (Get-FileHash "$folder/$document").Hash) { throw "Document mismatch: $document" }
}
$entry = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$productCode"
if ($entry.DisplayName -ne 'Hello World - Joey Saade') { throw 'Installed-program registration missing' }
$entry | Select-Object DisplayName, DisplayVersion, Publisher, UninstallString | Format-List
Get-ChildItem $folder | Select-Object Name, Length | Format-Table -AutoSize
Write-Host 'Checking uninstall and reinstall...'
$process = Start-Process msiexec.exe -ArgumentList "/x $productCode /qn /norestart /l*v `"$logs/msi-uninstall-verbose.log`"" -Wait -PassThru
if ($process.ExitCode -ne 0 -or (Test-Path "$folder/helloworld.exe")) { throw 'Uninstall verification failed' }
if (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$productCode") { throw 'Uninstall registration remained' }
$process = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart /l*v `"$logs/msi-reinstall-verbose.log`"" -Wait -PassThru
if ($process.ExitCode -ne 0) { throw 'Reinstall failed' }
Write-Host 'PASS: MSI installation, output, documentation, registration, removal and reinstall'
