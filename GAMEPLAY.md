## 🎮 ROBLOX CLICKER - GAMEPLAY GUIDE (VOLLSTÄNDIGER FUNKTIONEN)

Das Spiel ist jetzt VOLLSTÄNDIG und spielbar! Hier ist was du alles tun kannst:

---

## 🖱️ MAIN GAMEPLAY

### Klicken (Basic)
1. **Klick auf den großen TAP! Button** in der Mitte
2. Du erhältst **+1 Currency** pro Click
3. Eine Zahl schwebt nach oben, die zeigt wieviel du verdient hast

### Critical Hits (Glücksspiel)
- 10% Chance für einen **CRIT hit**
- CRIT verleiht dir **10x den Schaden**
- Beispiel: Normaler Click = +1, CRIT Click = +10

### Floating Numbers (Visual Feedback)
- Grüne Zahlen = Normaler Hit
- Gelbe Zahlen = Critical Hit

---

## 💰 CURRENCY & ECONOMY

### Verdienen
- **Manual Clicks**: Drücke TAP! für Währung
- **Auto-Clicker**: Kaufe im Shop – verdient automatisch
- **Passive Income**: Kaufe im Shop – verdient ständig

### Currency Anzeige (Oben Links)
- **"Currency: XXX"** zeigt dein Gesamtvermögen
- Wird live aktualisiert
- Leuchtet auf wenn du etwas verdienst

---

## 🛍️ SHOP & UPGRADES (WICHTIG!)

Der Shop ist unten am Bildschirm. Es gibt 2 Kategorien:

### 📊 UPGRADES TAB (Klicke "Upgrades" oben im Shop)

#### 1. Double Tap
- **Kosten**: $100
- **Effekt**: Verdoppelt deinen Base Damage
- **Effekt auf**: Alle zukünftigen Klicks
- **Beispiel**: Nach Kauf verdienst du +2 pro Click statt +1

#### 2. Crit Chance +10%
- **Kosten**: $250
- **Effekt**: Erhöht Crit Chance um 10%
- **Standard**: 10% Chance
- **Nach Kauf**: 20% Chance
- **Stackbar**: Du kannst mehrmals kaufen!

#### 3. Crit Multiplier x2
- **Kosten**: $500
- **Effekt**: Verdoppelt den Crit Damage Multiplikator
- **Standard**: 10x Multiplikator
- **Nach Kauf**: 20x Multiplikator
- **Stackbar**: Kaufe mehrmals für noch mehr Schaden!

### ⚙️ PERKS TAB (Klicke "Perks" oben im Shop)

#### 4. Auto Clicker (Lvl 1)
- **Kosten**: $1000
- **Effekt**: +1 automatischer Click pro Sekunde
- **Funktioniert**: Passiv - du brauchst nichts zu tun!
- **Stackbar**: Kaufe mehrmals für mehr Auto-Clicks

#### 5. Passive Generator (Lvl 1)
- **Kosten**: $2000
- **Effekt**: +1 Währung pro Sekunde generieren
- **Funktioniert**: Sofort und ständig
- **Stackbar**: Kaufe mehrmals für höhere Einnahmen

---

## ⚡ STATS PANEL (Oben Rechts)

Das Stats Panel zeigt deine aktuellenWerte:

```
⚡ Stats
Base DMG: 1.0
Crit %: 10%
Crit Mult: x10
```

### Was bedeuten diese?
- **Base DMG**: Der Standard-Schaden pro Click
  - Erhöht sich durch "Double Tap" Upgrades
  - Wird mit Crit Multiplier multipliziert bei Crits

- **Crit %**: Chance für Critical Hit
  - Standard: 10%
  - Nach "Crit Chance +10%": 20%
  - Jedes Upgrade addiert +10%

- **Crit Mult**: Multiplikator für Critical Hits
  - Standard: x10 Multiplikator
  - Nach "Crit Multiplier x2": x20
  - Stackbar unbegrenzt

---

## 🎯 STRATEGIE & OPTIMAL PLAYING

### Early Game ($0-500)
1. Klick ~100 Mal auf den Button
2. Kaufe "Double Tap" ($100)
3. Klick ~250 weitere Male
4. Klick insgesamt solltest du ~$250-300 haben
5. Kaufe "Crit Chance +10%" ($250)

### Mid Game ($500-1500)
1. Weiter klicken oder Auto-Clicker besorgen
2. Spare auf $1000 für Auto-Clicker
3. Mit Auto-Clicker verdienst du passiv
4. Kaufe "Crit Multiplier x2" ($500)
5. Upgrade deine Stats weiter

### Late Game ($1500+)
1. Mit Auto-Clicker & Passive Generator verdienst du schnell
2. Kaufe Upgrades nacheinander
3. Stacke Crit Chance & Crit Multiplier
4. Verdiene exponentiell mehr Währung

---

## 🔄 UPGRADE PROGRESSION

### Empfohlene Reihenfolge:
```
1. Double Tap ($100)
2. Crit Chance ($250)
3. Double Tap 2x ($100) ← Optional, für mehr Base DMG
4. Crit Multiplier ($500)
5. Auto Clicker ($1000) ← Game Changer! Passiv verdienen
6. Crit Chance 2x ($250)
7. Crit Multiplier 2x ($500)
8. Passive Generator ($2000) ← Ultra Passiv!
```

---

## 💡 TIPPS & TRICKS

### Schnell Geld Verdienen
- **Auto-Clicker kaufen** ist der beste Investment
- **Passive Income** verdient selbst im Sleep
- **Crit Upgrades** exponentiell mächtiger

### Stack Multiplier
- Double Tap kann viele Male gekauft werden
- Jeder Kauf verdoppelt nochmal
- Nach 3 Käufen: 1 → 2 → 4 → 8 Base Damage!

### Crit Strategy
- Crit Chance + Crit Multiplier zusammen nutzen
- High Crit Chance (60%+) mit High Multiplier (50x+) = Broken
- Exponentielles Wachstum möglich

---

## 🏆 ENDGAME GOALS

Versuche folgende Milestones zu erreichen:
- [ ] $100 verdienen → Erste Upgrade
- [ ] $500 verdienen → Crit Setup
- [ ] $1000 verdienen → Auto Clicker
- [ ] $5000 verdienen → Passive Generator
- [ ] $50000 verdienen → Upgrade alles
- [ ] Crit Chance 100% + Crit Mult 100x → BROKEN!

---

## 🐛 TECHNISCHE DETAILS

### Server-Side Systems
- ✅ **ClickCurrencyHandler** - Verarbeitet alle Klicks sicher
- ✅ **UpgradeSystem** - Alle Upgrade Käufe & Anwendungen
- ✅ **Auto-Click System** - Fired jeden Sekunde
- ✅ **Passive Income** - Läuft kontinuierlich

### Client-Side Systems
- ✅ **Shop.client.lua** - UI & Kauf-Buttons
- ✅ **ClickButton.client.lua** - Klick Interaktion
- ✅ **CurrencyLabel.client.lua** - Currency Anzeige
- ✅ **Stats.client.lua** - Stats Panel
- ✅ **CameraController.client.lua** - Optimale Kamera

### RemoteEvents (Server ↔ Client)
- `PlayerClick` - Klick vom Client → Server
- `BuyUpgrade` - Upgrade-Kauf vom Client → Server

---

## 🎮 GAMEPLAY LOOP

```
1. Starte das Spiel
2. Klick auf TAP! Button
3. Verdiene Währung
4. Öffne Shop (unten)
5. Kaufe erstes Upgrade ($100)
6. Merke wie dein Verdienst steigt
7. Wiederhole bis $1000
8. Kaufe Auto-Clicker
9. Verdiene jetzt passiv!
10. Kaufe weitere Upgrades
11. Exponentielles Wachstum! 🚀
```

---

## 📊 BEISPIEL PROGRESSION

```
Start:
- Currency: $0
- Base DMG: 1
- Crit: 10%
- Auto: 0/s
- Passive: 0/s

Nach 100 Clicks:
- Currency: $100
- → Kaufe Double Tap

Nach Double Tap:
- Currency: $0 (ausgegeben auf Upgrade)
- Base DMG: 2 (verdoppelt!)
- Verdiene jetzt doppelt schneller!

Nach 150 Clicks:
- Currency: $300
- → Kaufe 2x Crit Chance

Nach Upgrades:
- Base DMG: 2
- Crit: 30%
- Verdiene viel schneller durch mehr Crits!

... später ...

Nach Auto-Clicker:
- Base DMG: 8 (mehrere Double Taps)
- Crit: 60%
- Crit Mult: 40x
- Auto Clicker: Lvl 2
- Passive Income: Lvl 1
- → EXPONENTIAL GROWTH 📈
```

---

## ✅ VERIFIZIERUNG

Um zu überprüfen ob alles funktioniert:

### 1. Klick funktioniert
- [ ] Button TAP! reagiert
- [ ] Zahl schwebt nach oben
- [ ] Currency wächst

### 2. Shop funktioniert
- [ ] Shop Panel ist sichtbar (unten)
- [ ] Tabs wechseln (Upgrades/Perks)
- [ ] Buttons sind klickbar

### 3. Upgrades funktionieren
- [ ] Upgrade kaufen möglich
- [ ] Currency wird abgezogen
- [ ] Stats Panel aktualisiert sich
- [ ] Danach verdienst du mehr!

### 4. Auto-Features
- [ ] Auto Clicker: Verdienst ohne zu klicken
- [ ] Passive Income: Noch mehr passiv Verdienst
- [ ] Wachstum wird exponentiell

---

**VIEL SPASS BEIM SPIELEN! 🚀**

Das Spiel ist jetzt VOLL FUNKTIONSFÄHIG!
