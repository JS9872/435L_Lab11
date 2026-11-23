param([string]$WixBin = "$env:TEMP\435L-Lab11-tools\wix")
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$build = Join-Path $root 'build\windows'
$output = Join-Path $root 'deliverables'
New-Item $build, $output -ItemType Directory -Force | Out-Null
$compiler = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
& $compiler /nologo /target:exe /platform:x64 /optimize+ "/out:$build\helloworld.exe" "$root\src\windows\HelloWorld.cs"
if ($LASTEXITCODE -ne 0) { throw 'C# compilation failed' }
& "$WixBin/candle.exe" -nologo -arch x64 "-dPayloadDir=$build" "-dDocsDir=$root/docs" -out "$build/Product.wixobj" "$root/packaging/windows/Product.wxs"
if ($LASTEXITCODE -ne 0) { throw 'WiX compilation failed' }
& "$WixBin/light.exe" -nologo -sice:ICE91 -out "$output/helloworld_joey_saade.msi" "$build/Product.wixobj"
if ($LASTEXITCODE -ne 0) { throw 'MSI linking or validation failed' }
& "$build/helloworld.exe"
Write-Host "MSI built and validated: $output/helloworld_joey_saade.msi"
