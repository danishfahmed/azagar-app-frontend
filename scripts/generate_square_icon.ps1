Add-Type -AssemblyName System.Drawing

$sourcePath = 'd:/azager/assets/images/logo.png'
$outputPath = 'd:/azager/assets/images/logo_icon_square.png'
$size = 1024
$padding = 90

$src = [System.Drawing.Image]::FromFile($sourcePath)
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.Clear([System.Drawing.Color]::White)
$gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$targetW = $size - (2 * $padding)
$ratio = $src.Width / $src.Height
$drawW = [int]$targetW
$drawH = [int]($drawW / $ratio)
if ($drawH -gt ($size - (2 * $padding))) {
  $drawH = $size - (2 * $padding)
  $drawW = [int]($drawH * $ratio)
}

$x = [int](($size - $drawW) / 2)
$y = [int](($size - $drawH) / 2)
$gfx.DrawImage($src, $x, $y, $drawW, $drawH)

$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$gfx.Dispose()
$bmp.Dispose()
$src.Dispose()
Write-Output "Generated $outputPath"
