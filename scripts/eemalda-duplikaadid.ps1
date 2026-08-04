# Kasutamine: käivita repo juurest
#   cd C:\Dev\sillaallika-repo
#   powershell -ExecutionPolicy Bypass -File eemalda-duplikaadid.ps1
#
# Leiab duplikaadid (MD5 checksummi järgi) üle kogu images\gallery kausta,
# jätab igast grupist esimese faili (tähestikulises järjekorras) alles,
# kustutab ülejäänud. Prindib täpselt, mida kustutas.

$GalleryDir = "images\gallery"

if (-not (Test-Path $GalleryDir)) {
    Write-Host "Kausta $GalleryDir ei leitud. Käivita see repo juurkaustast."
    exit 1
}

$files = Get-ChildItem -Path $GalleryDir -Recurse -File -Include *.jpg, *.jpeg, *.png

$hashes = $files | ForEach-Object {
    [PSCustomObject]@{
        Hash = (Get-FileHash -Path $_.FullName -Algorithm MD5).Hash
        Path = $_.FullName
    }
}

$groups = $hashes | Group-Object -Property Hash | Where-Object { $_.Count -gt 1 }

if ($groups.Count -eq 0) {
    Write-Host "Duplikaate ei leitud."
    exit 0
}

$totalDeleted = 0

foreach ($g in $groups) {
    $sorted = $g.Group | Sort-Object Path
    $keep = $sorted[0]
    $remove = $sorted[1..($sorted.Count - 1)]

    Write-Host "Jätan alles: $($keep.Path)"
    foreach ($r in $remove) {
        Remove-Item -Path $r.Path
        Write-Host "  Kustutatud: $($r.Path)"
        $totalDeleted++
    }
    Write-Host ""
}

Write-Host "Valmis. Kustutatud kokku: $totalDeleted faili."
Write-Host "Jooksuta nüüd rename-failid.ps1, et numeratsioon uuesti järjestikuseks teha."
