# whatsapp-bridge als Windows-service (NSSM)

De bridge draait als Windows-service **`whatsapp-bridge`** via
[NSSM](https://nssm.cc/) (`tools\nssm\nssm.exe`), zodat hij permanent
aanstaat: start bij boot, draait ook zonder login, herstart automatisch
bij een crash. Zonder service gingen berichten verloren zodra de laptop
in slaapstand ging of de bridge afsloot (geleerd 1 sep 2026).

## Installatie / herinstallatie

```powershell
# als Administrator (UAC-prompt):
powershell -ExecutionPolicy Bypass -File C:\Users\Vkpet\Apps\whatsapp-mcp\whatsapp-bridge\tools\install-service.ps1
```

Het script is idempotent (verwijdert een bestaande registratie eerst),
stopt handmatige bridge-instanties, zet werkmap + logrotatie (10 MB),
auto-start en herstart-bij-crash, en start de service.

## Beheer

```powershell
Get-Service whatsapp-bridge          # status
Restart-Service whatsapp-bridge      # als Administrator
sc.exe qc whatsapp-bridge            # config bekijken
```

- Logs: `store\bridge-service.log` / `store\bridge-service.err.log` (rotatie 10 MB).
- Werkt met dezelfde `store\` (messages.db, whatsapp.db) als voorheen.

## QR-rekoppeling bij verlopen sessie (~20 dagen)

De WhatsApp-sessie verloopt na ~20 dagen. De bridge print dan de QR-code
naar stdout → `store\bridge-service.log`. Die QR uit het logbestand tonen
en met de telefoon scannen (WhatsApp → Gekoppelde apparaten → Apparaat
koppelen). Daarna herstarten: `Restart-Service whatsapp-bridge` (admin).

## Let op

- Starten/stoppen van de service vereist admin (LocalSystem-service).
- `whatsapp-bridge.exe~` en lokale main.go-aanpassingen horen bij de
  PR-bevriezing (zie `_Shared/WERKWIJZE-whatsapp.md`), niet bij deze tooling.
