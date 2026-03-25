## ✅ Roblox Clicker - Setup Checkliste

Folge diese Schritte um das Spiel zu starten und die Welt zu sehen:

### 📋 Installations-Checkliste

#### Schritt 1: Rojo installieren (falls noch nicht geschehen)
- [ ] Rojo von https://github.com/rojo-rbx/rojo/releases herunterladen
- [ ] Rojo installieren
- [ ] Terminal öffnen und testen: `rojo --version`

#### Schritt 2: Projekt öffnen
- [ ] Zum Projekt-Verzeichnis navigieren: `c:\DEV\roblox-ui-rng-clicker`
- [ ] Terminal hier öffnen (Shift + Rechtsklick → PowerShell)

#### Schritt 3: Rojo Server starten
- [ ] Command eingeben: `rojo serve`
- [ ] Warten bis: `Listening on 127.0.0.1:34872` angezeigt wird
- [ ] Terminal **nicht schließen!**

#### Schritt 4: Roblox Studio öffnen
- [ ] Roblox Studio starten
- [ ] Datei öffnen: `roblox-ui-rng-clicker.rbxlx`
- [ ] Warten bis Studio vollständig geladen ist

#### Schritt 5: Mit Rojo verbinden
- [ ] Im Studio: Schaue nach **"Rojo"** Button (rechts oben in der Toolbar)
- [ ] Klick auf **Rojo** → **Connect**
- [ ] Erwartete Meldung: "Connected to localhost:34872" (grüner Text)

#### Schritt 6: Spiel starten
- [ ] Klick **Play** Button (oder F5 oder Ctrl+P)
- [ ] Warte bis das Spiel lädt
- [ ] Du solltest die Welt sehen!

### 🔍 Nach dem Start überprüfen

#### Output Console (sehr wichtig!)
- [ ] View → Output (oder Ctrl+G)
- [ ] Suche nach diesen Meldungen:

```
✓ World generated successfully!
✓ Spawn platform with energy ring
✓ Pyramid Tower (Rechts)
✓ Spiral Tower (Links)
✓ 4 Floating Orbs
✓ 3 Crystal Formations
✓ Monolith Structure
✓ Monster Area
✓ Lighting configured
✓ Atmospheric light orbs placed
✓ Server initialization complete!
```

#### Sichtbare Objekte im Spiel
- [ ] Leuchtende Spawn-Plattform in der Mitte
- [ ] Rotierender türkis Ring um die Plattform
- [ ] 4 Neon-Säulen an den Ecken
- [ ] Große Pyramid-Struktur rechts
- [ ] Spiral-Tower links
- [ ] 5 schwebende Plattformen
- [ ] 4 leuchtende Orbs (floaten auf/ab)
- [ ] Kristall-Formationen
- [ ] Schöne Beleuchtung (blau/pink/grün)

#### UI Elements
- [ ] Click Button "TAP!" in der Mitte
- [ ] Currency Label oben links
- [ ] Stats Panel oben rechts
- [ ] Shop Panel unten (mit Tab-Navigation)

### ❌ Wenn etwas nicht funktioniert

#### "Rojo: Connection refused"
- [ ] Überprüfe: Läuft `rojo serve` noch im Terminal?
- [ ] Falls nein: Terminal öffnen, `rojo serve` eingeben
- [ ] Im Studio erneut: Rojo → Connect

#### "Nichts zu sehen im Spiel"
- [ ] Überprüfe die **Output Console**
- [ ] Gibt es Error-Meldungen?
- [ ] Wurde die Welt generiert? (Suche: "World generated")
- [ ] Falls nein:
  - Studio neustarten
  - `rojo serve` Terminal neu starten
  - Erneut Connect versuchen

#### "Button/UI nicht sichtbar"
- [ ] Überprüfe: Zoom im Studio (Mousewheel oder +/-)
- [ ] UI sollte am unteren/oberen Rand sein
- [ ] Falls noch nicht sichtbar: Überprüfe ScreenGui Position

#### "Rojo findet ClickButton nicht"
- [ ] Überprüfe: Sind die neuen Lua-Files erstellet?
- [ ] Überprüfe: Sind die Dateien im korrekten Pfad?
  - `src/server/main.server.lua` ✅
  - `src/client/CameraController.client.lua` ✅
  - `src/StarterGui/ClickerUI/ClickButton.client.lua` ✅

### 🎮 Wenn alles funktioniert

#### Du solltest sehen:
1. ✨ Eine vollständig generierte 3D-Welt
2. 🖱️ Einen großen Click-Button zum Klicken
3. 💰 Currency-Anzeige oben links
4. ⚡ Stats Panel oben rechts
5. 🛍️ Shop Panel unten mit Upgrades
6. 🏛️ Beeindruckende Architektur-Strukturen

#### Jetzt kannst du:
- 👆 Auf den Button klicken um Währung zu verdienen
- 🛍️ Im Shop neue Upgrades kaufen
- 📈 Deine Stats im Panel beobachten
- 🎯 Die Welt erkunden

### 📞 Support

Wenn du immer noch Probleme hast:
1. Überprüfe die Dateistruktur
2. Lese die detaillierte README.md
3. Überprüfe die Output Console auf spezifische Fehler
4. Stelle sicher dass alle `.lua` Dateien existieren

---

**Viel Spaß! 🚀**

*Letzte Aktualisierung: 25.03.2026*
