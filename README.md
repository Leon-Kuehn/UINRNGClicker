# 🎮 Roblox UI RNG Clicker - Complete Edition

Ein vollständig funktionierendes **Clicker Game** in Roblox mit beeindruckender 3D-Welt, Shop-System und Upgrade-Mechaniken!

## 🚀 Quick Start

### Mit Rojo (Empfohlen)
```bash
rojo serve
```
Dann in **Roblox Studio**:
1. Öffne `roblox-ui-rng-clicker.rbxlx`
2. Klick **Rojo** Button (rechts oben)
3. Klick **Connect**
4. Spiel starten (F5 oder Play Button)

### Oder Build & Run
```bash
rojo build -o "roblox-ui-rng-clicker.rbxlx"
```
Dann öffne die Datei in Roblox Studio und klick Play!

## 🎯 Was ist enthalten

### 🌍 Spielwelt
- ✨ Spawn-Plattform mit rotierendem Energy Ring
- 🏛️ Pyramid Tower (5 Ebenen)
- 🌀 Spiral Tower (10 Blöcke)
- 🎯 5 Floating Parkour Platforms
- 🔮 4 schwebende Orbs mit Animationen
- 💎 3 Kristall-Formationen
- 🏪 Monster Spawn Area
- 🔴 Monolith Structure
- 💡 Atmosphärische Beleuchtung

### 🎮 Gameplay
- 🖱️ Klickbar Click-Button (Tap!)
- 💰 Echtzeit Währungs-Anzeige
- ⚡ Stats Panel (Base DMG, Crit %, Crit Mult)
- 🛍️ Shop mit Upgrades & Perks
  - Double Tap
  - Crit Chance +10%
  - Crit Multiplier x2
  - Auto Clicker
  - Passive Income

### 🎨 UI Features
- Responsive Design
- Shop mit Tab-System (Upgrades/Perks)
- Floating Damage Numbers
- Crit Flash Animations
- Glowing Stats Panel
- Currency Gain Alerts

## 📂 Projekt-Struktur

```
src/
├── server/
│   ├── main.server.lua                    (🌍 Welt-Generator)
│   └── (Weitere Server-Module)
├── client/
│   └── CameraController.client.lua        (📷 Kamera Setup)
├── ServerScriptService/
│   └── ClickCurrencyHandler.server.lua    (💰 Klick-Economy)
└── StarterGui/
    └── ClickerUI/
        ├── ClickButton.client.lua         (🎯 Click-Button)
        ├── CurrencyLabel.client.lua       (💵 Währung)
        ├── Shop.client.lua                (🛍️ Shop)
        └── Stats.client.lua               (⚡ Stats)
```

## 🔧 Requirements

- **Rojo** 7.0+ ([Download](https://github.com/rojo-rbx/rojo/releases))
- **Roblox Studio**
- **Luau Language Support** (Optional, für VSCode)

## 🎮 Gameplay Features

### Click System
- Basis-Klick: +1 Währung
- Crit Chance: 10% für 10x Damage
- Klick-Animationen mit floatenden Nummern

### Upgrade System
- Upgrades können im Shop gekauft werden
- Basis-DMG Scaling
- Crit-Chance und Crit-Multiplier Verbesserungen
- Auto-Clicker (kommt bald)
- Passive Income (kommt bald)

### Visual Feedback
- ✨ Floating Damage Numbers
- 🌟 Crit Flash auf Currency Label
- 💫 Button Press Animation
- 🎨 Glowing Neon Objects in der Welt

## 📝 Code Highlights

### Main Server (Auto-Generated World)
- Alle 80+ Welt-Objekte werden beim Server-Start generiert
- TweenService für flüssige Animationen
- RunService für kontinuierliche Rotationen

### Click Economy (Server-Authority)
- Server verarbeitet alle Klicks für AntiCheat
- Crit-Berechnung server-seitig
- Client erhält Feedback über RemoteEvent

### Responsive UI
- UICorner für abgerundete Ecken
- UIStroke für Neon-Effekte
- UIPadding für Spacing
- UIListLayout für automatische Anordnung

## 🎯 Nächste Steps

1. **Setup**: Rojo starten und in Studio connecten
2. **Spielen**: Auf den Button klicken und Währung sammeln
3. **Upgraden**: Im Shop am unteren Rand neue Skills kaufen
4. **Explore**: Die Welt erkunden (Parkour auf den Platforms!)

## 🐛 Troubleshooting

### Ich sehe nichts!
1. **Überprüfe Output Console** (View → Output)
2. Schaue nach Success-Meldungen wie:
   ```
   ✓ World generated successfully!
   ✓ Server initialization complete!
   ```
3. Falls Fehler: Stage → Restart

### Rojo verbindet nicht
1. Stelle sicher dass `rojo serve` läuft
2. Roblox Studio neustarten
3. Rojo → Connect erneut versuchen

### Button/UI sind nicht sichtbar
1. Überprüfe ScreenGui ResetOnSpawn: false
2. UI Position überprüfen (sollten am Rand sein)
3. Zoom anpassen (Mousewheel)

## 📊 Performance

- ✅ 80+ Parts optimiert
- ✅ Neon Material für visuellen Effekt
- ✅ Selective Transparency für Performance
- ✅ ClientSide Animationen wo möglich

## 🎓 Lernwert

Dieses Projekt zeigt:
- ✅ Server-Client Architektur
- ✅ RemoteEvents für Kommunikation
- ✅ TweenService Animationen
- ✅ GuiObject Styling & Layout
- ✅ Part-based 3D World Building
- ✅ Economy/Progression Systems

## 📄 License

Frei verwendbar für Lern- und Entwicklungszwecke!

---

**Viel Spaß beim Spielen! 🚀**

Next, open `roblox-ui-rng-clicker.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).