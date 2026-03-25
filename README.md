# UINRNGClicker

A **Roblox RNG Weapon Clicker** game built with [Rojo](https://rojo.space/) and pure Luau.  
Click to earn coins → spend coins to roll random weapons → equip the best weapon to earn more coins faster.

---

## Project structure

```
src/
├── ReplicatedStorage/
│   └── Modules/                  # Shared code (server + client)
│       ├── RarityConfig.luau     # Rarity table with weights, colours, multipliers
│       ├── WeaponConfig.luau     # Weapon pool per rarity
│       ├── RNGUtils.luau         # Weighted random selection
│       └── FormatUtils.luau      # Number / percentage formatting
│
├── ServerScriptService/
│   ├── Modules/
│   │   └── PlayerData.luau       # In-memory player state (server-only)
│   ├── GameInit.server.luau      # Player lifecycle + DataStore persistence
│   ├── CurrencyManager.server.luau
│   ├── WeaponRNGManager.server.luau
│   ├── PlayerWeaponManager.server.luau
│   ├── WorldInteractionManager.server.luau
│   └── LeaderboardManager.server.luau
│
├── StarterGui/
│   ├── ClickerUI/
│   │   └── ClickerController.client.luau  # TAP button, currency bar, crit text
│   ├── RollUI/
│   │   └── RollController.client.luau     # Roll panel + rarity chances
│   └── LeaderboardUI/
│       └── LeaderboardController.client.luau  # Top-10 coins panel
│
└── StarterPlayer/StarterPlayerScripts/
    └── WorldUIController.client.luau      # Zone toast notifications
```

### RemoteEvents (`ReplicatedStorage.Events`)

| Event name        | Direction        | Payload                                   |
|-------------------|------------------|-------------------------------------------|
| `PlayerClick`     | Client → Server  | *(none)*                                  |
| `RollWeapon`      | Client → Server  | *(none)*                                  |
| `EquipWeapon`     | Client → Server  | `index: number` (1-based inventory slot)  |
| `SellWeapon`      | Client → Server  | `index: number`                           |
| `UpdateCurrency`  | Server → Client  | `coins: number, critAmount: number?`      |
| `UpdateInventory` | Server → Client  | `inventory: table, equippedWeapon: table?`|
| `UpdateLeaderboard`| Server → Client | `entries: {rank,name,coins,display}[]`    |
| `EnterZone`       | Server → Client  | `zoneName: string, entering: boolean`     |

---

## Prerequisites

- [Aftman](https://github.com/LPGhatguy/aftman) (toolchain manager)
- Roblox Studio

---

## Step 1 – Install tools

```bash
aftman install
```

This reads `aftman.toml` and installs **Rojo 7.4.4** locally.

---

## Step 2 – Run Rojo

```bash
rojo serve
```

Rojo will print a URL (default `http://localhost:34872`).

---

## Step 3 – Connect from Roblox Studio

1. Open Roblox Studio with a **blank baseplate** place.
2. Install the **Rojo Studio plugin** from the Roblox plugin marketplace (search "Rojo").
3. Click the Rojo plugin button → **Connect** → confirm the address matches what the CLI printed.
4. Studio will sync the full `src/` tree into the DataModel automatically.

---

## Step 4 – Manual Studio setup

### Add world zone parts

All world geometry is built by hand. To wire up the game systems, tag parts with
[CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tags.

**Tag Editor plugin** (free on Marketplace): select a part → open Tag Editor → type the tag name.

| Tag name           | Effect                                                                  |
|--------------------|-------------------------------------------------------------------------|
| `RollStation`      | Touching fires `EnterZone("RollStation")` → highlights the Roll panel  |
| `BonusZone`        | While inside, all clicks give **2× coins**                              |
| `LeaderboardBoard` | A `SurfaceGui` leaderboard is auto-created on the **Front** face        |

#### Example: Bonus Zone

1. Insert a large, flat `Part` in the Workspace (e.g. a glowing floor tile).
2. Set `CanCollide = false` and `Transparency = 0.7` so players walk through it.
3. Tag it `BonusZone`.

#### Example: Roll Station

1. Insert any Part or Model near the centre of your map.
2. Tag the main BasePart `RollStation`.
3. Players who walk near it see a toast: *"Roll Station nearby – use the Roll panel →"*.

#### Example: Leaderboard Board

1. Insert a tall, thin `Part` (like a sign board) wherever you want the scoreboard.
2. Scale it to ~4 studs wide × 6 studs tall.
3. Tag it `LeaderboardBoard`.
4. The server auto-creates a `SurfaceGui` on the **Front** face with the top-10 list.

---

## Extending the game

| Feature        | File(s) to edit                                               |
|----------------|---------------------------------------------------------------|
| New rarities   | `RarityConfig.luau` – add an entry to `Rarities`             |
| New weapons    | `WeaponConfig.luau` – add entries under the rarity key       |
| Roll cost      | `WeaponRNGManager.server.luau` – change `ROLL_COST`          |
| Crit rate      | `CurrencyManager.server.luau` – change `CRIT_CHANCE`         |
| Sell values    | `PlayerWeaponManager.server.luau` – update `SELL_VALUE`      |
| Rebirths UI    | Add a `RebirthUI` ScreenGui + server handler in a new script |
| More zones     | `WorldInteractionManager.server.luau` – add to the tag list  |

---

## License

MIT
