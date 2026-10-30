$ErrorActionPreference = 'Stop'
$root = 'C:\Users\MY LAP\.zcode\workspace\326782e5-e041-4f48-9a6a-893e877beeb7'
$file = Join-Path $root 'index.html'
$c = [IO.File]::ReadAllText($file)
$sh = [string]([char]0x0634) + [char]0x0648 + [char]0x0628 + [char]0x064A + [char]0x0641 + [char]0x0627 + [char]0x064A
$mn = 0
$c = [regex]::Replace($c, 'ar:\{title:"[^"]*",desc:"[^"]*"\}', { param($m) $script:mn = ([regex]::Matches($m.Groups[0].Value, 'Shopify')).Count; $m.Groups[0].Value.Replace('Shopify', $sh) })
Write-Output ("META ar Shopify replaced: " + $mn)
[IO.File]::WriteAllText($file, $c, (New-Object System.Text.UTF8Encoding($false)))
# verification sweep
$m = [regex]::Match($c, 'ar:\{title:"[^"]*",desc:"[^"]*"\}').Value
Write-Output ("META ar now: " + $m.Substring(0, [Math]::Min(90, $m.Length)))
Write-Output ("latin Shopify in META ar: " + ([regex]::Matches($m, 'Shopify')).Count)
