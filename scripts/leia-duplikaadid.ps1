# Kasutamine: käivita repo juurest (kus asub images\gallery\)
#   cd C:\Dev\sillaallika-repo
#   powershell -ExecutionPolicy Bypass -File leia-duplikaadid.ps1
#
# Leiab täpselt samasisulised pildid (MD5 checksummi järgi) üle KÕIGI
# galerii kategooriate. Ei kustuta midagi, ainult näitab duplikaadid.

$GalleryDir = "images\gallery"

if (-not (Test-Path $GalleryDir)) {
    Write-Host "Kausta $GalleryDir ei leitud. Käivita see repo juurkaustast."
    exit 1
}

Write-Host "Otsin duplikaate kaustast: $GalleryDir"
Write-Host ""

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
} else {
    Write-Host "=== Duplikaadid (sama sisu, erinevad failid) ==="
    foreach ($g in $groups) {
        Write-Host ""
        Write-Host "Duplikaadigrupp:"
        foreach ($item in $g.Group) {
            Write-Host "  $($item.Path)"
        }
    }
}

Write-Host ""
Write-Host "Valmis. Kontrolli ülal loetletud gruppe ja otsusta, milline igast grupist alles jätta."
