# Fix: "ProcessStarter: application control policy blocked" + snapshot build failure (NOT your app code).
# Run from project:  Set-ExecutionPolicy -Scope Process Bypass -Force; .\scripts\unblock_flutter_windows.ps1
# Better: copy SDK to C:\dev\flutter first, then:  .\scripts\unblock_flutter_windows.ps1 -FlutterRoot C:\dev\flutter
# Admin: allows Windows Defender folder exclusion (optional but helps).

param(
  [string] $FlutterRoot = "$env:USERPROFILE\Downloads\flutter_windows_3.41.6-stable\flutter"
)

$ErrorActionPreference = 'Continue'

if (-not (Test-Path -LiteralPath $FlutterRoot)) {
  Write-Host "Introuvable: $FlutterRoot" -ForegroundColor Red
  Write-Host "Utilisez: -FlutterRoot 'C:\dev\flutter' (apres avoir deplace le dossier Flutter hors de Telechargements)" -ForegroundColor Yellow
  exit 1
}

Write-Host "1/3 Unblock-File (telechargement / SmartScreen)..." -ForegroundColor Cyan
Get-ChildItem -LiteralPath $FlutterRoot -Recurse -File -ErrorAction SilentlyContinue | Unblock-File
Write-Host "   OK" -ForegroundColor Green

$dart = Join-Path $FlutterRoot "bin\cache\dart-sdk\bin\dart.exe"
if (Test-Path -LiteralPath $dart) {
  Write-Host "2/3 Test dart.exe ..." -ForegroundColor Cyan
  & $dart --version
  if ($LASTEXITCODE -ne 0) { Write-Host "   dart a echoue — deplacez Flutter vers C:\dev\flutter et reessayez." -ForegroundColor Red }
} else {
  Write-Host "2/3 dart.exe pas encore la (premier lancement). OK apres deblocage + deplacement." -ForegroundColor Yellow
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
  try {
    Write-Host "3/3 Exclusion Windows Defender (admin)..." -ForegroundColor Cyan
    Add-MpPreference -ExclusionPath $FlutterRoot -ErrorAction Stop
    Write-Host "   Exclusion ajoutee: $FlutterRoot" -ForegroundColor Green
  } catch {
    Write-Host "   Add-MpPreference impossible: $($_.Exception.Message)" -ForegroundColor Yellow
  }
} else {
  Write-Host "3/3 (optionnel) Relancez ce script en Administrateur pour ajouter une exclusion Defender sur ce dossier." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "OBLIGATOIRE si erreur persiste: deplacer TOUT le dossier flutter hors de \Downloads\ vers p.ex. C:\dev\flutter" -ForegroundColor White
Write-Host "Puis: mettez a jour PATH (Variables d'environnement) -> ...\C:\dev\flutter\bin" -ForegroundColor White
Write-Host "Puis: flutter doctor -v" -ForegroundColor White
Write-Host ""
Write-Host "La ligne 'crumb' est un bruit secondaire; l'echec snapshot = politique Windows / Antivirus sur dart.exe." -ForegroundColor DarkGray
