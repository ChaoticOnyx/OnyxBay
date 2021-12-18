$x86 = "C:\Windows\System32\IEChooser.exe"
$x64 = "C:\WINDOWS\SysWOW64\F12\IEChooser.exe"

if (Test-Path $x64) {
    Start-Process -FilePath $x64
}
elseif (Test-Path $x86) {
    Start-Process -FilePath $x86
}
else {
    Write-Error "IEChooser.exe не обнаружен."
}
