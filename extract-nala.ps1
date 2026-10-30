$c = [IO.File]::ReadAllText('index.html')
$m = [regex]::Match($c, '(?s)id="p-nala".*?src="data:image/([a-z+]+);base64,([A-Za-z0-9+/=]+)"')
Write-Output ('fmt: ' + $m.Groups[1].Value)
$b64 = $m.Groups[2].Value
Write-Output ('b64 len: ' + $b64.Length)
[IO.File]::WriteAllBytes('embedded-nala.bin', [Convert]::FromBase64String($b64))
Add-Type -AssemblyName System.Drawing
$i = [System.Drawing.Image]::FromFile((Resolve-Path 'embedded-nala.bin'))
Write-Output ('dims: ' + $i.Width + 'x' + $i.Height)
$i.Dispose()
