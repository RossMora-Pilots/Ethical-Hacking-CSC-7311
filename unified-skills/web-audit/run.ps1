param(
  [string]$Domain = "www.myunitedway.ca"
)
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path (Join-Path $here "..")
Set-Location $root

$out = "artifacts/webscan"
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }

function Find-Python {
  foreach ($exe in @("python3","py -3","python")) {
    try {
      if ($exe -like "py*") {
        $v = & py -3 -V 2>$null
        if ($LASTEXITCODE -eq 0) { return "py -3" }
      } else {
        $v = & $exe -V 2>$null
        if ($LASTEXITCODE -eq 0) { return $exe }
      }
    } catch {}
  }
  throw "Python not found in PATH"
}

$py = Find-Python
Write-Host "Running web scan for $Domain ..." -ForegroundColor Cyan
if ($py -eq 'py -3') {
  & py -3 "scripts/webscan.py" --domain $Domain --out $out
} else {
  & $py "scripts/webscan.py" --domain $Domain --out $out
}
Write-Host "Done. See $out\results.json and $out\summary.md" -ForegroundColor Green
