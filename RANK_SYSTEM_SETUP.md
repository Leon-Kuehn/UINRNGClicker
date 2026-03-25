# Rank System Setup Guide

This guide explains how to set up and use the new Rank system with world-space rank boards.

## File Structure

All new and modified files follow this structure:

### New Files Created
- **`src/ReplicatedStorage/Modules/RankConfig.luau`** — Hardcoded rank list with costs and multipliers
- **`src/ReplicatedStorage/Modules/RankUtils.luau`** — Utility functions for rank lookups
- **`src/ServerScriptService/RankManager.server.luau`** — Server rank logic and progression
- **`src/ServerScriptService/WorldRankBoardManager.server.luau`** — Creates and manages world rank boards

### Modified Files
- **`src/ServerScriptService/Modules/PlayerData.luau`** — Added `rankIndex` field (defaults to 1)
- **`src/ServerScriptService/CurrencyManager.server.luau`** — Applies rank multiplier to taps
- **`src/ServerScriptService/BackpackManager.server.luau`** — Applies rank multiplier to coin conversion
- **`src/ServerScriptService/GameInit.server.luau`** — Saves/loads rank from DataStore

## Rank System Details

### Rank Progression
Players start at **Novice** (rank index 1) and can progress through 5 ranks:

| Rank | Cost | Multiplier |
|------|------|-----------|
| Novice | 0 | 1.0x |
| Adept | 100 | 1.5x |
| Expert | 300 | 2.0x |
| Master | 800 | 2.5x |
| Legend | 2000 | 3.0x |

### Multiplier Application
The rank multiplier is applied to:
- **Souls earned per tap** — Multiplied into the base souls gained calculation
- **Coins from soul conversion** — When selling souls, coins are multiplied by the rank multiplier

Example: A Legend rank player gets 3× more souls per tap and 3× more coins when selling souls.

### How Rank Upgrades Work
1. Player clicks the **RANK UP** button on a rank board
2. Server validates that the player has enough coins
3. Server deducts the coin cost and increments the rank index
4. Server sends updated rank data back to the client
5. Board UI updates to show the new rank and next rank info

If the player cannot afford the rank upgrade, the board displays "Not enough coins" in red text.

---

## Studio Setup: Required Remote Events

Before testing or playing, you must create these RemoteEvent objects in ReplicatedStorage.

### Step 1: Create the Events Folder
1. In Roblox Studio, navigate to **ReplicatedStorage**
2. Insert a **Folder** and name it **Events**

### Step 2: Create RemoteEvents
Inside the **Events** folder, insert the following **RemoteEvent** objects:

1. **RankUpRequest** — Client → Server, fired when the rank up button is clicked
2. **RankDataUpdated** — Server → Client, fired to update rank display on boards

(These are in addition to any existing RemoteEvents like `PlayerClick`, `SellSouls`, `UpdateCurrency`, `UpdateInventory`, etc.)

### Verification
After creating the Events folder and RemoteEvents, your ReplicatedStorage should look like:

```
ReplicatedStorage
├── Events
│   ├── EnterZone
│   ├── PlayerClick
│   ├── RankDataUpdated  [NEW]
│   ├── RankUpRequest    [NEW]
│   ├── SellSouls
│   ├── UpdateCurrency
│   └── UpdateInventory
└── Modules
    ├── ClickerUXConfig.luau
    ├── EconomyConfig.luau
    ├── ... (other modules)
    ├── RankConfig.luau           [NEW]
    └── RankUtils.luau            [NEW]
```

---

## Placing a Rank Board in the World

### Step 1: Create a Part for the Board
1. In the Workspace, insert a **Part** (e.g., a wall or board shape)
2. Scale and position it where you want the rank board to appear
3. Rename it to something descriptive, e.g., `RankBoard_01`

### Step 2: Tag the Part
1. Select the part
2. In the **Properties** panel, scroll down to find the **Attributes** section (or use the Tag Editor plugin if available)
3. Add a **collectible tag** (or use the Tag Editor plugin to add a tag):
   - Tag name: **`RankBoard`**
4. Save/confirm the tag

### Step 3: Verify
1. Run the game (play in Studio)
2. The **WorldRankBoardManager** will automatically detect the tagged part
3. A **SurfaceGui** with the rank board UI will be created on the front face of the part
4. The board should display your current rank, multiplier, next rank, and a RANK UP button

---

## Board Design & Interaction

### What the Board Shows
- **RANK BOARD** (title)
- **Current Rank** — Name of your current rank (e.g., "Novice")
- **Multiplier** — Current rank multiplier (e.g., "x1.5")
- **Next Rank** — Name and coin cost of the next rank (or "Max rank reached!" if at max)
- **Status Messages** — Feedback like "Not enough coins" or "Rank up!" (fades after 2 seconds)
- **Coins** — Current available coins
- **RANK UP button** — Click to attempt a rank upgrade

### Interaction
1. Look at the board (SurfaceGui)
2. Click the **RANK UP** button
3. If successful, you'll see "Rank up!" and the display will update
4. If you don't have enough coins, you'll see "Not enough coins" in red

---

## Testing Checklist

- [ ] RemoteEvents created in ReplicatedStorage/Events
- [ ] RankManager script exists in ServerScriptService
- [ ] WorldRankBoardManager script exists in ServerScriptService
- [ ] RankConfig and RankUtils modules exist in ReplicatedStorage/Modules
- [ ] Play in Studio and verify:
  - [ ] You see your initial rank data on any board (Novice, 1.0x multiplier)
  - [ ] Board displays "Next: Adept (100 coins)"
  - [ ] Coins display correctly
  - [ ] Clicking RANK UP shows "Not enough coins" if you have < 100 coins
  - [ ] After selling souls to get coins, clicking RANK UP upgrades your rank
  - [ ] Board updates to show new rank and multiplier
  - [ ] Taps now give more souls with the new multiplier applied
  - [ ] Selling souls now converts at your new multiplier rate

---

## Multiplier Stacking

Multipliers stack multiplicatively. For example, if you have:
- Rank: Adept (1.5×)
- Weapon: Rarity Divine (10×) × Weapon Divine Godbreaker (2.0×)
- Rebirth: 2 rebirths (1 + 2 × 0.5 = 2.0×)

Total tap multiplier: `1.5 × 10 × 2.0 × 2.0 × (1 + BonusZone if applicable) = 60×` base souls per tap!

---

## Optional Enhancements

### Customizing Ranks
Edit `src/ReplicatedStorage/Modules/RankConfig.luau`:
```luau
RANKS = {
    { name = "Novice", cost = 0, multiplier = 1.0 },
    { name = "Adept", cost = 100, multiplier = 1.5 },
    -- Add more ranks or adjust costs/multipliers here
}
```

### Changing Board Colors or Text
Edit `src/ServerScriptService/WorldRankBoardManager.server.luau` to modify:
- `BackgroundColor3` for the board background
- `TextColor3` for text colors
- Button styling (color, text size, etc.)

### Hooking Rank Upgrades to Other Systems
Edit `src/ServerScriptService/RankManager.server.luau`'s `handleRankUpRequest` function to add triggers for:
- Achievements or badges
- Sound effects
- Particle effects
- Save events logging

---

## Troubleshooting

### Board doesn't appear
- Verify the part is tagged with `"RankBoard"` exactly
- Check that WorldRankBoardManager script is in ServerScriptService and running
- Verify RemoteEvent `RankDataUpdatedEvent` exists in ReplicatedStorage/Events

### "Loading rank data..." persists
- Check that RankManager script exists and is running
- Ensure RankDataUpdatedEvent is firing (`print()` statements help debug)
- Verify there are no errors in RankManager or the board client script

### Rank upgrades not working
- Check that `RankUpRequest` RemoteEvent exists in ReplicatedStorage/Events
- Verify the rank index is stored in PlayerData (check in script inspector)
- Ensure coins are being properly deducted (watch via PlayerData or print statements)

### Multiplier not applying to taps
- Confirm `RankUtils.getMultiplier()` is being called in CurrencyManager
- Verify ranks are loading correctly from DataStore after a rejoin
- Test on a fresh character vs. a returning player

---

## Integration with Existing Systems

The rank system integrates seamlessly with:
- **CurrencyManager** — Rank multiplier applied to tap souls
- **BackpackManager** — Rank multiplier applied to coin conversion
- **GameInit** — Rank persists via DataStore
- **PlayerData** — Rank stored in-memory and loaded on startup
- **World Boards** — CollectionService tagging for dynamic board detection

No changes needed to ClickerUI, RollUI, LeaderboardUI, or other existing systems beyond what's already done.

---

## Summary

✅ Rank system fully integrated
✅ Multipliers apply to taps and soul-to-coin conversion
✅ Rank persists via DataStore
✅ World-space boards created dynamically from tagged parts
✅ Player-friendly UI with status feedback
✅ Extensible architecture for future enhancements
