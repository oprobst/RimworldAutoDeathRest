# Zeichnet About/ModIcon.png (64x64) — kleine Sarg-Silhouette für die Mod-Liste / Ladebildschirm.
# Aufruf: pwsh -File make-modicon.ps1

Add-Type -AssemblyName System.Drawing

$outPath = Join-Path $PSScriptRoot "About\ModIcon.png"
$S = 64

$bmp = New-Object System.Drawing.Bitmap($S, $S)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Transparenter Hintergrund — RimWorld zeigt Mod-Icons auf unterschiedlichen Hintergründen.
$g.Clear([System.Drawing.Color]::Transparent)

# Sarg-Polygon (6-Punkt Silhouette, an 64x64 angepasst)
$cx = 32
$top = 6
$shoulderY = 18
$bottom = 58

$coffin = @(
    (New-Object System.Drawing.PointF(($cx - 10), $top)),
    (New-Object System.Drawing.PointF(($cx + 10), $top)),
    (New-Object System.Drawing.PointF(($cx + 20), $shoulderY)),
    (New-Object System.Drawing.PointF(($cx + 13), $bottom)),
    (New-Object System.Drawing.PointF(($cx - 13), $bottom)),
    (New-Object System.Drawing.PointF(($cx - 20), $shoulderY))
)

# Holz-Fuellung mit Vertikal-Gradient
$coffinBounds = New-Object System.Drawing.RectangleF(
    ($cx - 20), $top, 40, ($bottom - $top))
$woodBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $coffinBounds,
    [System.Drawing.Color]::FromArgb(255, 96, 58, 32),
    [System.Drawing.Color]::FromArgb(255, 48, 28, 16),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g.FillPolygon($woodBrush, $coffin)

# Dunkler Rahmen
$edgePen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(255, 18, 8, 2), 2.0)
$edgePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawPolygon($edgePen, $coffin)

# Bluttropfen-Akzent
$bloodBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(255, 150, 14, 14))
$g.FillEllipse($bloodBrush, ($cx + 6), 14, 3, 4)

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Output "ModIcon geschrieben: $outPath"
