# Kasutamine: käivita repo images\gallery kausta seest
#   cd C:\Dev\sillaallika-repo\images\gallery
#   powershell -ExecutionPolicy Bypass -File resize-galerii.ps1
#
# Nõuab ImageMagick'ut (winget install --id ImageMagick.ImageMagick -e)
# Vähendab pildid max 1600px laiuseks, teisendab HEIC->JPG, jätab
# juba väiksed pildid puutumata.

$MaxWidth = 1600
$Quality = 80

$files = Get-ChildItem -Recurse -File -Include *.jpg, *.jpeg, *.png, *.heic, *.HEIC

foreach ($f in $files) {
    $ext = $f.Extension.ToLower()

    if ($ext -eq ".heic") {
        $newPath = [System.IO.Path]::ChangeExtension($f.FullName, "jpg")
        magick "$($f.FullName)" -resize "${MaxWidth}x${MaxWidth}>" -quality $Quality "$newPath"
        Remove-Item $f.FullName
        Write-Host "Teisendatud HEIC -> JPG ja vähendatud: $($f.Name) -> $(Split-Path $newPath -Leaf)"
    } else {
        # Küsi praegune laius ImageMagick identify käsuga
        $width = (magick identify -format "%w" "$($f.FullName)")
        if ([int]$width -gt $MaxWidth) {
            magick "$($f.FullName)" -resize "${MaxWidth}x${MaxWidth}>" -quality $Quality "$($f.FullName)"
            Write-Host "Vähendatud: $($f.Name) (${width}px -> ${MaxWidth}px)"
        } else {
            Write-Host "Vahele jäetud (juba piisavalt väike, ${width}px): $($f.Name)"
        }
    }
}

Write-Host ""
Write-Host "Valmis."
