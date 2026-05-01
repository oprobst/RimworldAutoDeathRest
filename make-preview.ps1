# Zeichnet About/Preview.png via System.Drawing.
# Aufruf: pwsh -File make-preview.ps1    (Windows PowerShell 5.1 reicht ebenfalls.)

Add-Type -AssemblyName System.Drawing

$outPath = Join-Path $PSScriptRoot "About\Preview.png"
$W = 640
$H = 640

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# --- Hintergrund: radialer Look via zwei lineare Gradienten ---
$bgRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bgRect,
    [System.Drawing.Color]::FromArgb(255, 24, 10, 14),
    [System.Drawing.Color]::FromArgb(255,  6,  2,  4),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g.FillRectangle($bgBrush, $bgRect)

# Dezenter roter Glow um den Sarg herum
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(80, 80, $W - 160, $H - 160)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(90, 140, 10, 10)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$g.FillPath($glowBrush, $glowPath)

# --- Sarg-Polygon (klassische 6-Punkt-Silhouette) ---
$cx = 320
$top    = 70
$shoulderY = 170
$bottom = 580

$coffin = @(
    (New-Object System.Drawing.PointF(($cx - 80), $top)),       # oben links (Kopf)
    (New-Object System.Drawing.PointF(($cx + 80), $top)),       # oben rechts
    (New-Object System.Drawing.PointF(($cx + 170), $shoulderY)),# Schulter rechts
    (New-Object System.Drawing.PointF(($cx + 110), $bottom)),   # unten rechts
    (New-Object System.Drawing.PointF(($cx - 110), $bottom)),   # unten links
    (New-Object System.Drawing.PointF(($cx - 170), $shoulderY)) # Schulter links
)

# Holz-Fuellung mit Gradient
$coffinBounds = New-Object System.Drawing.RectangleF(
    ($cx - 170), $top, 340, ($bottom - $top))
$woodBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $coffinBounds,
    [System.Drawing.Color]::FromArgb(255, 82, 50, 28),
    [System.Drawing.Color]::FromArgb(255, 42, 24, 14),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g.FillPolygon($woodBrush, $coffin)

# Holzmaserung - senkrechte Linien
$grainPen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(60, 20, 10, 4), 1.5)
for ($x = ($cx - 140); $x -le ($cx + 140); $x += 18) {
    $g.DrawLine($grainPen, $x, ($top + 20), $x, ($bottom - 20))
}

# Rahmen um den Sarg
$edgePen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(255, 18, 8, 2), 6)
$edgePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawPolygon($edgePen, $coffin)

# Innerer Highlight-Rahmen
$innerPen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(120, 150, 90, 50), 2)
$innerPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$innerInset = @(
    (New-Object System.Drawing.PointF(($cx - 66), ($top + 18))),
    (New-Object System.Drawing.PointF(($cx + 66), ($top + 18))),
    (New-Object System.Drawing.PointF(($cx + 148), ($shoulderY + 4))),
    (New-Object System.Drawing.PointF(($cx + 92), ($bottom - 22))),
    (New-Object System.Drawing.PointF(($cx - 92), ($bottom - 22))),
    (New-Object System.Drawing.PointF(($cx - 148), ($shoulderY + 4)))
)
$g.DrawPolygon($innerPen, $innerInset)

# --- Sanguophagen-Emblem: zwei Reisszaehne mit fallendem Blutstropfen ---
# Etwa halbe Sargbreite: ~120 px Gesamtbreite an der Basis (cx +/- 60).
$emblemTopY = 240
$fangHeight = 110

$leftFang = @(
    (New-Object System.Drawing.PointF(($cx - 60), $emblemTopY)),                # Basis aussen
    (New-Object System.Drawing.PointF(($cx - 12), $emblemTopY)),                # Basis innen
    (New-Object System.Drawing.PointF(($cx - 22), ($emblemTopY + $fangHeight))) # Spitze (leicht innen)
)
$rightFang = @(
    (New-Object System.Drawing.PointF(($cx + 12), $emblemTopY)),
    (New-Object System.Drawing.PointF(($cx + 60), $emblemTopY)),
    (New-Object System.Drawing.PointF(($cx + 22), ($emblemTopY + $fangHeight)))
)

# Schatten unter den Reisszaehnen
$shadowOffset = 5
$fangShadowBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(150, 0, 0, 0))
$leftShadow  = $leftFang  | ForEach-Object { New-Object System.Drawing.PointF(($_.X + $shadowOffset), ($_.Y + $shadowOffset)) }
$rightShadow = $rightFang | ForEach-Object { New-Object System.Drawing.PointF(($_.X + $shadowOffset), ($_.Y + $shadowOffset)) }
$g.FillPolygon($fangShadowBrush, $leftShadow)
$g.FillPolygon($fangShadowBrush, $rightShadow)

# Elfenbein-Verlauf fuer die Reisszaehne
$fangRect = New-Object System.Drawing.RectangleF(($cx - 60), $emblemTopY, 120, $fangHeight)
$fangBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $fangRect,
    [System.Drawing.Color]::FromArgb(255, 245, 235, 215),
    [System.Drawing.Color]::FromArgb(255, 195, 175, 135),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g.FillPolygon($fangBrush, $leftFang)
$g.FillPolygon($fangBrush, $rightFang)

# Dunkler Umriss
$fangPen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(255, 30, 18, 8), 2)
$fangPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawPolygon($fangPen, $leftFang)
$g.DrawPolygon($fangPen, $rightFang)

# --- Blutstropfen unter den Reisszaehnen ---
$dropTopY  = $emblemTopY + $fangHeight + 8
$dropH     = 50
$dropHalfW = 18

function New-DropPath([double]$ox, [double]$oy) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddBezier(
        (New-Object System.Drawing.PointF(($cx + $ox), ($dropTopY + $oy))),
        (New-Object System.Drawing.PointF((($cx - $dropHalfW) + $ox), (($dropTopY + $dropH * 0.55) + $oy))),
        (New-Object System.Drawing.PointF((($cx - $dropHalfW) + $ox), (($dropTopY + $dropH * 0.78) + $oy))),
        (New-Object System.Drawing.PointF(($cx + $ox), (($dropTopY + $dropH) + $oy))))
    $p.AddBezier(
        (New-Object System.Drawing.PointF(($cx + $ox), (($dropTopY + $dropH) + $oy))),
        (New-Object System.Drawing.PointF((($cx + $dropHalfW) + $ox), (($dropTopY + $dropH * 0.78) + $oy))),
        (New-Object System.Drawing.PointF((($cx + $dropHalfW) + $ox), (($dropTopY + $dropH * 0.55) + $oy))),
        (New-Object System.Drawing.PointF(($cx + $ox), ($dropTopY + $oy))))
    $p.CloseFigure()
    return $p
}

# Schatten
$dropShadowPath = New-DropPath 4 4
$dropShadowBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(140, 0, 0, 0))
$g.FillPath($dropShadowBrush, $dropShadowPath)

# Tropfen mit radialem Glanz
$dropPath = New-DropPath 0 0
$dropFillBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($dropPath)
$dropFillBrush.CenterPoint = New-Object System.Drawing.PointF($cx, ($dropTopY + $dropH * 0.65))
$dropFillBrush.CenterColor = [System.Drawing.Color]::FromArgb(255, 200, 30, 30)
$dropFillBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(255, 110, 8, 8))
$g.FillPath($dropFillBrush, $dropPath)

# Umriss
$dropPen = New-Object System.Drawing.Pen(
    [System.Drawing.Color]::FromArgb(220, 60, 0, 0), 1.5)
$g.DrawPath($dropPen, $dropPath)

# --- Titel unten ---
$titleFont   = New-Object System.Drawing.Font("Trajan Pro", 34, [System.Drawing.FontStyle]::Bold)
if ($titleFont.Name -ne "Trajan Pro") {
    $titleFont.Dispose()
    $titleFont = New-Object System.Drawing.Font("Georgia", 34, [System.Drawing.FontStyle]::Bold)
}
$subtitleFont = New-Object System.Drawing.Font("Georgia", 16, [System.Drawing.FontStyle]::Italic)

$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = [System.Drawing.StringAlignment]::Center

# Schatten fuer den Titel
$titleShadowBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(200, 0, 0, 0))
$g.DrawString("Auto-Deathrest", $titleFont, $titleShadowBrush,
    (New-Object System.Drawing.RectangleF(0, 22, $W, 50)), $fmt)

$titleBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(255, 230, 200, 150))
$g.DrawString("Auto-Deathrest", $titleFont, $titleBrush,
    (New-Object System.Drawing.RectangleF(0, 18, $W, 50)), $fmt)

$subBrush = New-Object System.Drawing.SolidBrush(
    [System.Drawing.Color]::FromArgb(220, 200, 170, 130))
$g.DrawString("for Sanguophages", $subtitleFont, $subBrush,
    (New-Object System.Drawing.RectangleF(0, 595, $W, 30)), $fmt)

# --- Speichern ---
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Output "Preview geschrieben: $outPath"
