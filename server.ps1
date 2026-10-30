$ErrorActionPreference = 'Stop'
$root = 'C:\Users\MY LAP\.zcode\workspace\326782e5-e041-4f48-9a6a-893e877beeb7'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://127.0.0.1:8137/')
$listener.Start()
Write-Output 'Serving on http://127.0.0.1:8137/'
$types = @{
  '.html' = 'text/html; charset=utf-8'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.webp' = 'image/webp'
  '.ico'  = 'image/x-icon'
}
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    if ($path -eq '/') { $path = '/index.html' }
    $fp = Join-Path $root ($path.TrimStart('/') -replace '/', '\')
    if ([IO.File]::Exists($fp)) {
      $ext = [IO.Path]::GetExtension($fp).ToLower()
      $ct = if ($types.ContainsKey($ext)) { $types[$ext] } else { 'application/octet-stream' }
      $bytes = [IO.File]::ReadAllBytes($fp)
      $ctx.Response.ContentType = $ct
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
  } catch { $ctx.Response.StatusCode = 500 }
  finally { $ctx.Response.OutputStream.Close() }
}
