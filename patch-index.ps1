$ErrorActionPreference = 'Stop'
$root = 'C:\Users\MY LAP\.zcode\workspace\326782e5-e041-4f48-9a6a-893e877beeb7'
$file = Join-Path $root 'index.html'
$c = [IO.File]::ReadAllText($file)

# ---- 1. static WhatsApp hrefs -> Arabic (new default language) ----
$oldHref = 'https://wa.me/201004943581?text=Hi%20Adel%2C%20I%27m%20interested%20in%20building%20a%20Shopify%20store%20for%20my%20brand.%20I%27d%20like%20to%20discuss%20my%20requirements%20and%20get%20a%20project%20quote.'
$newHref = 'https://wa.me/201004943581?text=%D8%A3%D9%87%D9%84%D9%8B%D8%A7%D8%8C%20%D8%B4%D9%88%D9%81%D8%AA%20%D8%B4%D8%BA%D9%84%D9%83%20%D9%88%D8%AD%D8%A7%D8%A8%D8%A8%20%D8%A3%D8%AA%D9%83%D9%84%D9%85%20%D9%85%D8%B9%D8%A7%D9%83%20%D8%B9%D9%86%20%D9%85%D8%AA%D8%AC%D8%B1%20%D8%A7%D9%84%D8%A8%D8%B1%D8%A7%D9%86%D8%AF%20%D8%A8%D8%AA%D8%A7%D8%B9%D9%8A%20%D8%B9%D9%84%D9%89%20%D8%B4%D9%88%D8%A8%D9%8A%D9%81%D8%A7%D9%8A.%20%D9%85%D9%85%D9%83%D9%86%20%D9%86%D9%86%D8%A7%D9%82%D8%B4%20%D8%A7%D9%84%D8%AA%D9%81%D8%A7%D8%B5%D9%8A%D9%84%D8%9F'
$n = ([regex]::Matches($c, [regex]::Escape($oldHref))).Count
$c = $c.Replace($oldHref, $newHref)
Write-Output ("WA hrefs replaced: " + $n)

# ---- 2. AR dictionary: Shopify -> شوبيفاي (scoped to the AR line) ----
$arn = 0
$c = [regex]::Replace($c, '(?s)(var AR=\{.*?\};)', { param($m) $script:arn = ([regex]::Matches($m.Groups[1].Value, 'Shopify')).Count; $m.Groups[1].Value.Replace('Shopify', [char]0x0634 + [char]0x0648 + [char]0x0628 + [char]0x064A + [char]0x0641 + [char]0x0627 + [char]0x064A) })
Write-Output ("AR dict Shopify replaced: " + $arn)

# ---- 3. META ar line: Shopify -> شوبيفاي ----
$mn = 0
$c = [regex]::Replace($c, '(ar:\{title:"[^"]*عادل[^"]*\})', { param($m) $script:mn = ([regex]::Matches($m.Groups[1].Value, 'Shopify')).Count; $m.Groups[1].Value.Replace('Shopify', [char]0x0634 + [char]0x0648 + [char]0x0628 + [char]0x064A + [char]0x0641 + [char]0x0627 + [char]0x064A) })
Write-Output ("META ar Shopify replaced: " + $mn)

# ---- 4. splice base64 images ----
$map = @{
  '__COVER_FLO__'          = 'cover-flo.jpg'
  '__COVER_THRIVEFIT__'    = 'cover-thrivefit.jpg'
  '__COVER_VERSUS7__'      = 'cover-versus7.jpg'
  '__COVER_LITTLEBUDDY__'  = 'cover-littlebuddy.jpg'
  '__COVER_GLOWEAR__'      = 'cover-glowear.jpg'
  '__LOGO_NALA__'          = 'logo-nala.png'
  '__LOGO_HIBTAM__'        = 'logo-hibtam.png'
  '__LOGO_CIEL__'          = 'logo-ciel.webp'
  '__LOGO_MOVEON__'        = 'logo-moveon.png'
  '__LOGO_FLO__'           = 'logo-flo.png'
  '__LOGO_THRIVEFIT__'     = 'logo-thrivefit.png'
  '__LOGO_VERSUS7__'       = 'logo-versus7.png'
  '__LOGO_LITTLEBUDDY__'   = 'logo-littlebuddy.png'
  '__LOGO_GLOWEAR__'       = 'logo-glowear.png'
}
$mime = @{ '.jpg' = 'image/jpeg'; '.png' = 'image/png'; '.webp' = 'image/webp' }
foreach ($k in $map.Keys) {
  $p = Join-Path $root ('out\' + $map[$k])
  $uri = 'data:' + $mime[[IO.Path]::GetExtension($map[$k])] + ';base64,' + [Convert]::ToBase64String([IO.File]::ReadAllBytes($p))
  $cnt = ([regex]::Matches($c, [regex]::Escape($k))).Count
  $c = $c.Replace($k, $uri)
  Write-Output ("{0} -> {1} occurrence(s)" -f $k, $cnt)
}

# ---- 5. sanity checks ----
$left = ([regex]::Matches($c, '__COVER_|__LOGO_')).Count
Write-Output ("placeholders left: " + $left)
Write-Output ("old WA hrefs left: " + ([regex]::Matches($c, [regex]::Escape('Hi%20Adel'))).Count)
Write-Output ("latin Shopify left in AR dict: " + ([regex]::Matches(([regex]::Match($c, '(?s)var AR=\{.*?\};')).Value, 'Shopify')).Count)
[IO.File]::WriteAllText($file, $c, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("final bytes: " + ([IO.FileInfo]::new($file)).Length)
