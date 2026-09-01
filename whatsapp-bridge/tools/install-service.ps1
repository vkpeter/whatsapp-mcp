# install-service.ps1 — whatsapp-bridge als Windows-service via NSSM
# Uitvoeren als Administrator (UAC). Idempotent: herlopen is veilig.
$ErrorActionPreference = 'Stop'

$dir  = 'C:\Users\Vkpet\Apps\whatsapp-mcp\whatsapp-bridge'
$nssm = "$dir\tools\nssm\nssm.exe"
$exe  = "$dir\whatsapp-bridge.exe"

# 1) Bestaande handmatige instanties stoppen (anders sqlite-lock in de store)
Get-Process -Name 'whatsapp-bridge' -ErrorAction SilentlyContinue | Stop-Process -Force

# 2) Oude registratie weghalen (als die bestaat), dan opnieuw installeren
if (Get-Service -Name 'whatsapp-bridge' -ErrorAction SilentlyContinue) {
    & $nssm remove whatsapp-bridge confirm | Out-Null
    Start-Sleep -Seconds 1
}
& $nssm install whatsapp-bridge $exe
if ($LASTEXITCODE -ne 0) { throw "nssm install mislukt ($LASTEXITCODE)" }

# 3) Parameters: werkmap, logs met rotatie, auto-start, herstart bij crash
& $nssm set whatsapp-bridge AppDirectory $dir
& $nssm set whatsapp-bridge AppStdout "$dir\store\bridge-service.log"
& $nssm set whatsapp-bridge AppStderr "$dir\store\bridge-service.err.log"
& $nssm set whatsapp-bridge AppRotateFiles 1
& $nssm set whatsapp-bridge AppRotateBytes 10485760
& $nssm set whatsapp-bridge Start SERVICE_AUTO_START
& $nssm set whatsapp-bridge AppExit Default Restart
& $nssm set whatsapp-bridge AppRestartDelay 5000
& $nssm set whatsapp-bridge Description 'WhatsApp bridge (whatsmeow) - permanent gekoppeld apparaat voor HolieVault'

# 4) Service starten
Start-Service -Name 'whatsapp-bridge'
Write-Host 'Service whatsapp-bridge geïnstalleerd en gestart.'
