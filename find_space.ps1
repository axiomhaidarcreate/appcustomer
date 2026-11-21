Write-Host "=== C: Drive Free Space ==="
[math]::Round((Get-PSDrive C).Free / 1GB, 2)

Write-Host "`n=== Largest folders in C:\Users\AL-NATHER (top 10) ==="
Get-ChildItem "C:\Users\AL-NATHER" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{ Folder = $_.Name; SizeMB = [math]::Round($size / 1MB, 2) }
} | Sort-Object SizeMB -Descending | Select-Object -First 10 | Format-Table -AutoSize

Write-Host "`n=== Largest folders in AppData\Local (top 10) ==="
Get-ChildItem "C:\Users\AL-NATHER\AppData\Local" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{ Folder = $_.Name; SizeMB = [math]::Round($size / 1MB, 2) }
} | Sort-Object SizeMB -Descending | Select-Object -First 10 | Format-Table -AutoSize
