Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = 'C:\Users\MY LAP\.zcode\workspace\326782e5-e041-4f48-9a6a-893e877beeb7'
$out = Join-Path $root 'out'
New-Item -ItemType Directory -Force -Path $out | Out-Null

function Save-Jpeg($img, $path, $quality) {
  $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
  $img.Save($path, $jpegCodec, $ep)
}

function Resize-SquareToJpeg($src, $dst, $size, $q) {
  $img = [System.Drawing.Image]::FromFile($src)
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($img, 0, 0, $size, $size)
  $g.Dispose()
  Save-Jpeg $bmp $dst $q
  $bmp.Dispose()
  $img.Dispose()
}

function Resize-LogoToPng($src, $dst, $targetH) {
  $img = [System.Drawing.Image]::FromFile($src)
  $w = [int][math]::Round($img.Width * $targetH / $img.Height)
  $bmp = New-Object System.Drawing.Bitmap($w, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($img, 0, 0, $w, $targetH)
  $g.Dispose()
  $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  $img.Dispose()
}

# --- 5 new covers -> 800x800 jpeg q82 ---
$covers = @{
  'Flo.png'               = 'cover-flo'
  'Thrive Fit.png'        = 'cover-thrivefit'
  'Versus.png'            = 'cover-versus7'
  'Little Buddy Wear.png' = 'cover-littlebuddy'
  'GloWear.png'           = 'cover-glowear'
}
foreach ($k in $covers.Keys) {
  $src = Join-Path $root "assets\Project Cover\$k"
  $dst = Join-Path $out ($covers[$k] + '.jpg')
  Resize-SquareToJpeg $src $dst 800 82
}

# --- 9 active logos -> height 160 png ---
$logos = @{
  'Nala Kids.png'           = 'logo-nala'
  'Hibtam.png'              = 'logo-hibtam'
  'Ciel.webp'               = $null   # webp: copied as-is
  'Move On.png'             = 'logo-moveon'
  'Flo.png'                 = 'logo-flo'
  'Thrive Fit.png'          = 'logo-thrivefit'
  'VERSUS.png'              = 'logo-versus7'
  'Little Buddy Wear.png'   = 'logo-littlebuddy'
  'GLO WEAR.png'            = 'logo-glowear'
}
foreach ($k in $logos.Keys) {
  $src = Join-Path $root "assets\Brands Logos\$k"
  if ($null -eq $logos[$k]) {
    Copy-Item $src (Join-Path $out 'logo-ciel.webp') -Force
    continue
  }
  $dst = Join-Path $out ($logos[$k] + '.png')
  Resize-LogoToPng $src $dst 160
}

# --- base64 outputs ---
Get-ChildItem $out -File | ForEach-Object {
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))
  $mime = switch ($_.Extension.ToLower()) {
    '.jpg'  { 'image/jpeg' }
    '.png'  { 'image/png' }
    '.webp' { 'image/webp' }
  }
  $txt = 'data:' + $mime + ';base64,' + $b64
  [IO.File]::WriteAllText((Join-Path $out ($_.BaseName + '.b64.txt')), $txt)
  Write-Output ('{0}  {1}KB  b64chars={2}' -f $_.Name, [int]($_.Length/1KB), $b64.Length)
}
