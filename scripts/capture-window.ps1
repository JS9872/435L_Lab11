param([Parameter(Mandatory=$true)][string]$Title, [Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class LabWindow {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string className, string title);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr handle, out Rect rect);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr handle);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr handle, int command);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr handle, IntPtr after, int left, int top, int width, int height, uint flags);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr handle, IntPtr context, uint flags);
}
'@
[LabWindow]::SetProcessDPIAware() | Out-Null
$handle = [LabWindow]::FindWindow($null, $Title)
if ($handle -eq [IntPtr]::Zero) {
    $process = Get-Process | Where-Object { $_.MainWindowTitle -like "*$Title*" } | Select-Object -First 1
    if ($process) { $handle = $process.MainWindowHandle }
}
if ($handle -eq [IntPtr]::Zero) { throw "Window not found: $Title" }
[LabWindow]::ShowWindow($handle, 9) | Out-Null
[LabWindow]::SetWindowPos($handle, [IntPtr](-1), 50, 50, 1400, 1000, 0) | Out-Null
[LabWindow]::SetForegroundWindow($handle) | Out-Null
Start-Sleep -Milliseconds 700
$rectangle = New-Object LabWindow+Rect
[LabWindow]::GetWindowRect($handle, [ref]$rectangle) | Out-Null
$bitmap = New-Object System.Drawing.Bitmap(($rectangle.Right-$rectangle.Left), ($rectangle.Bottom-$rectangle.Top))
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$context = $graphics.GetHdc()
$captured = [LabWindow]::PrintWindow($handle, $context, 2)
$graphics.ReleaseHdc($context)
if (!$captured) { throw 'Window capture failed' }
$bitmap.Save($Output, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()
[LabWindow]::SetWindowPos($handle, [IntPtr](-2), 50, 50, 1400, 1000, 0) | Out-Null
Write-Host "Captured $Title to $Output"
