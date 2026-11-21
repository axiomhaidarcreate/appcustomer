Write-Host "=== Temp folder size (MB) ==="
$temp = Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
[math]::Round($temp.Sum / 1MB, 2)

Write-Host "`n=== Flutter/Dart cache in AppData (MB) ==="
$paths = @(
    "$env:LOCALAPPDATA\Pub\Cache",
    "$env:APPDATA\.dartServer",
    "$env:LOCALAPPDATA\flutter"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        $size = Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$p : $([math]::Round($size.Sum / 1MB, 2)) MB"
    }
}

Write-Host "`n=== Largest folders in C:\Users\AL-NATHER\AppData\Local\Temp\flutter_tools* ==="
Get-ChildItem "$env:TEMP\flutter_tools*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    Write-Host "$($_.Name) : $([math]::Round($size.Sum / 1MB, 2)) MB"
}
