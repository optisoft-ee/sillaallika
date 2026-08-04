# Kasutamine: käivita repo images\gallery kausta seest
#   cd C:\Dev\sillaallika-repo\images\gallery
#   powershell -ExecutionPolicy Bypass -File ..\..\rename-failid.ps1
#
# Nimetab iga kausta sees olevad pildifailid ümber kuju "kaustanimi-01.jpg" jne.
# Turvaline korduskäivitada — juba õigesti nimetatud failid jäävad puutumata.

$Kaustad = @("2ne-tuba", "3ne-tuba", "saun", "sviit", "territoorium", "peoruum-kook")
$ValidExt = @(".jpg", ".jpeg", ".png")

foreach ($kaust in $Kaustad) {
    if (-not (Test-Path $kaust)) {
        Write-Host "Kausta ei leitud, jätan vahele: $kaust"
        continue
    }

    Write-Host "Töötlen kausta: $kaust"
    $i = 1

    $files = Get-ChildItem -Path $kaust -File | Where-Object { $ValidExt -contains $_.Extension.ToLower() } | Sort-Object Name

    foreach ($f in $files) {
        $ext = $f.Extension.ToLower()
        $num = "{0:D2}" -f $i
        $newName = "$kaust-$num$ext"
        $newPath = Join-Path $kaust $newName

        if ($f.FullName -ne $newPath) {
            Rename-Item -Path $f.FullName -NewName $newName
            Write-Host "  $($f.Name) -> $newName"
        }
        $i++
    }
}

Write-Host ""
Write-Host "Valmis. Pildiarvud kausta kohta:"
foreach ($kaust in $Kaustad) {
    if (Test-Path $kaust) {
        $count = (Get-ChildItem -Path $kaust -File | Where-Object { $ValidExt -contains $_.Extension.ToLower() }).Count
        Write-Host "${kaust}: $count"
    }
}
