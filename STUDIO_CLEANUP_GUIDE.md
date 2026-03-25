# 🎮 STUDIO PLACE CLEANUP GUIDE

## 📝 Overview
This guide walks you through cleaning up your Roblox Studio place file to remove all objects and scripts related to the old clicker architecture, keeping only the new RNG weapon system.

---

## ⚠️ BEFORE YOU START

**IMPORTANT**: Make a backup of your place file before making any changes!

```
1. File → Save As
2. Name it: roblox-ui-rng-clicker-backup-[DATE].rbxlx
3. Store it safely
```

---

## 🎯 WHAT STAYS vs. WHAT GOES

### ✅ MUST KEEP - Critical System Objects

Expand each folder in the **Explorer** and verify these exist:

#### 1. **ReplicatedStorage** (Data & Events)
```
ReplicatedStorage
├── Events (Folder)
│   ├── ClickRequest (RemoteEvent)
│   ├── CurrencyUpdated (RemoteEvent)
│   ├── RollRequest (RemoteEvent)
│   ├── RollResult (RemoteEvent)
│   ├── WeaponEquipped (RemoteEvent)
│   └── WorldInteraction (RemoteEvent)
└── Modules (Folder)
    ├── RarityConfig (ModuleScript)
    ├── WeaponConfig (ModuleScript)
    ├── RNGUtils (ModuleScript)
    └── FormatUtils (ModuleScript)
```
**Action**: ✅ Do NOT delete anything here. This is the backbone of the RNG system.

---

#### 2. **ServerScriptService** (Game Logic)
```
ServerScriptService
├── Main (Script) [creates ClickerHouseWorld]
├── CurrencyManager (Script)
├── WeaponRNGManager (Script)
├── PlayerWeaponManager (Script)
├── WorldInteractionManager (Script)
└── UpgradeSystem (Script)
```
**Action**: ✅ Keep all these. They are the active managers.

---

#### 3. **StarterPlayer** (Player Entry Point)
```
StarterPlayer
├── StarterCharacterScripts/ (empty folder)
└── StarterPlayerScripts/
    ├── CameraController (LocalScript)
    └── WorldUIController (LocalScript)
```
**Action**: ✅ Keep both LocalScripts. Delete any other scripts in this folder.

---

#### 4. **StarterGui** (User Interface)
```
StarterGui
├── ClickerUI (ScreenGui)
│   ├── ClickButton (TextButton)
│   ├── CurrencyLabel (TextLabel)
│   ├── ClickButtonLocal (LocalScript)
│   ├── CurrencyLabelLocal (LocalScript)
│   ├── ShopLocal (LocalScript)
│   ├── StatsLocal (LocalScript)
│   └── WeaponDisplayLocal (LocalScript)
│
└── RollUI (ScreenGui)
    └── RollUILocal (LocalScript)
```
**Action**: ✅ Keep all GUI elements and LocalScripts. This is the entire user interface.

---

### 🗑️ DELETE FROM WORKSPACE

These are the old world objects that should be removed. Expand **Workspace** in Explorer and look for:

#### **Old Generation System Objects**

| Object Name | Type | Old System | Delete |
|-------------|------|-----------|--------|
| **BaseGround** | Part | WorldBuilder.server.lua | 🗑️ |
| **SpawnCenter** | Part/Model | WorldBuilder.server.lua | 🗑️ |
| **Towers** | Model(s) | Old decoration | 🗑️ |
| **Platforms** | Model(s) | Old platforming | 🗑️ |
| **Crystals** | Model(s) | Old collectibles | 🗑️ |
| **Items** | Folder | ItemSpawner.server.lua | 🗑️ |
| **Baseplate** | Part | Default Roblox | 🗑️ |
| **CurrencyItems** | Folder | ItemSpawner.server.lua | 🗑️ |
| **Terrain** | Terrain | Old voxel data | ⚠️ |
| **ClickerHouseWorld** | Model | **KEEP** ← Might become this | ✅ |

---

## 🔍 STUDIO CLEANUP STEPS

### **STEP 1: Open Explorer & Verify Current State**

```
1. In Roblox Studio, open the Explorer window (View → Explorer)
2. Note down what you see in Workspace
3. Identify which objects match the "DELETE" list above
```

**Expected Current State** (if old files were synced):
- Multiple old parts/models from WorldBuilder
- Items folder (empty or with old items)
- Possibly some old scripts

---

### **STEP 2: Update default.project.json**

✅ **Already done for you!** The file at `c:\DEV\roblox-ui-rng-clicker\default.project.json` is clean.

**Verify:** If using Rojo live sync:
```bash
cd C:\DEV\roblox-ui-rng-clicker
rojo serve
```

Then in Studio: **File → Connect to Rojo → localhost:34872**

This will NOT sync old scripts anymore.

---

### **STEP 3: Delete Old Workspace Objects**

Using the Roblox Studio **Explorer** panel:

#### **Delete WorldBuilder Objects**
```
1. In Explorer, right-click on Workspace
2. Look for: BaseGround, SpawnCenter, Towers, Platforms, Crystals
3. Select each one individually (Ctrl+Click to multi-select)
4. Press Delete key
5. Confirm deletions
```

**Example Series:**
1. Right-click **BaseGround** → Delete ✓
2. Right-click **SpawnCenter** → Delete ✓
3. Right-click **Towers** (if exists) → Delete ✓
4. Right-click **Platforms** (if exists) → Delete ✓
5. Right-click **Crystals** (if exists) → Delete ✓

#### **Delete ItemSpawner Objects**
```
1. In Explorer, look for: Items, CurrencyItems folders
2. Right-click → Delete
3. Confirm
```

#### **Delete Default Baseplate**
```
1. In Explorer, find "Baseplate" Part
2. Right-click → Delete
3. Confirm
```

#### **Delete Old Terrain (if Old Voxel Data)**
```
1. In Explorer, find "Terrain" object
2. Right-click → Delete
3. Confirm
```

---

### **STEP 4: Verify Remaining World Objects**

After deletions, your Workspace should look like:

```
Workspace
├── ClickerHouseWorld (Model) ← Created by main.server.lua
│   ├── SpawnCenter
│   ├── Board
│   └── [other auto-generated parts]
│
├── Camera (Standard Roblox)
└── Humanoid (Standard Roblox)
```

**If you don't see ClickerHouseWorld:**
- Run the game once (Play button or Ctrl+P)
- It will be auto-generated by main.server.lua
- The world is created at runtime, not stored in the place

---

### **STEP 5: Verify ServerScriptService**

```
In Explorer → ServerScriptService

Look for OLD scripts to DELETE:
  ❌ ClickCurrencyHandler
  ❌ WorldBuilder
  ❌ ItemSpawner
  ❌ LightingSetup

Keep ONLY:
  ✅ Main
  ✅ CurrencyManager
  ✅ WeaponRNGManager
  ✅ PlayerWeaponManager
  ✅ WorldInteractionManager
  ✅ UpgradeSystem
```

If you see old scripts:
1. Right-click → Delete
2. Confirm

---

### **STEP 6: Verify ReplicatedStorage**

```
In Explorer → ReplicatedStorage

DELETE old RemoteEvents at top level:
  ❌ PlayerClick
  ❌ BuyUpgrade
  ❌ UpgradePurchaseResult
  ❌ BuyUpgradeRequest

KEEP:
  ✅ Events (Folder with 6 RemoteEvents)
  ✅ Modules (Folder with 4 scripts)
```

1. Right-click old events → Delete
2. Confirm each

---

### **STEP 7: Verify StarterGui**

```
In Explorer → StarterGui

KEEP:
  ✅ ClickerUI (ScreenGui with all children)
  ✅ RollUI (ScreenGui with RollUILocal script)

DELETE:
  ❌ Any other ScreenGui or Frame objects
  ❌ Old UI remnants
```

---

### **STEP 8: Verify StarterPlayer**

```
In Explorer → StarterPlayer → StarterPlayerScripts

KEEP:
  ✅ CameraController
  ✅ WorldUIController

DELETE:
  ❌ Any other scripts
  ❌ main.client.lua (if exists)
  ❌ Old client scripts
```

---

### **STEP 9: TEST - Play the Game**

```
1. Press F5 or Ctrl+P (or click Play button)
2. Wait 2-3 seconds for startup
3. Verify:
```

#### **Checklist During Gameplay**

- [ ] **Camera** - Can look around normally? Camera moves smoothly?
- [ ] **Spawn** - Player spawns in world? Can move?
- [ ] **Click Button** - See "TAP!" button on screen?
- [ ] **Click Works** - Press button, see number go up?
- [ ] **Currency Display** - "Coins: X" shows and updates?
- [ ] **Shop** - Click on Shop tab, see upgrades?
- [ ] **Stats** - See damage, crit%, multiplier values?
- [ ] **Roll** - Click "Roll Weapon", animation plays?
- [ ] **No Errors** - Output log is clean (no red errors)?

**If all pass** ✅ Cleanup successful!

**If something breaks** ⚠️ Check "Troubleshooting" section below.

---

## 🐛 TROUBLESHOOTING

### Issue: "Game doesn't start / Black screen"
**Solution:**
1. Check **Output** window for error messages
2. If you see error about missing script/module - UNDO your deletions
3. You may have accidentally deleted an active system
4. Restore from your backup and try again more carefully

### Issue: "Click button not visible"
**Solution:**
1. Check **StarterGui → ClickerUI** exists in Explorer
2. Verify ClickButton exists and Name is "ClickButton"
3. In ClickButton properties, check **Visible = true**
4. Check DisplayOrder is reasonable (not -1000)

### Issue: "Currency doesn't update"
**Solution:**
1. Check **ServerScriptService → CurrencyManager** exists
2. Check **ReplicatedStorage → Events → ClickRequest** exists
3. In Output, you should see currency messages like:
   ```
   [CurrencyManager] Player gained X coins
   ```
4. If no messages, CurrencyManager isn't running - check for script errors

### Issue: "New world (ClickerHouseWorld) doesn't appear"
**Solution:**
1. This is normal! ClickerHouseWorld is created at **runtime**
2. Run the game (Play button)
3. Wait a few seconds for main.server.lua to execute
4. The world should appear in Workspace
5. If it doesn't, check Output for errors in Main script

### Issue: "Old objects are coming back after I delete them"
**Solution:**
1. You likely have old server scripts still running
2. Check if ClickCurrencyHandler, WorldBuilder, or other old scripts exist
3. Delete them from ServerScriptService
4. Rebuild with Rojo: `rojo build -o "test.rbxlx"`
5. Open the new file and verify old objects don't regenerate

### Issue: "Errors appear in Output window"
**Solution:**
1. Read the error message carefully
2. Common errors:
   - `ClassName mismatch` → Object type changed in place
   - `Child not found` → Script references deleted object
   - `Can't save place` → Corrupted RBXLX file (restore backup)
3. Restore from backup if confused

---

## ✅ FINAL VERIFICATION CHECKLIST

Before saving and committing, verify:

### **Explorer Structure**
- [ ] ReplicatedStorage → Events (6 events) ✅
- [ ] ReplicatedStorage → Modules (4 modules) ✅
- [ ] ServerScriptService (6 scripts only, no old handlers) ✅
- [ ] StarterGui → ClickerUI (with children) ✅
- [ ] StarterGui → RollUI (with RollUILocal) ✅
- [ ] StarterPlayer → StarterPlayerScripts (CameraController + WorldUIController) ✅

### **No Old Objects**
- [ ] Workspace has NO: BaseGround, SpawnCenter, Towers, etc. ✅
- [ ] Workspace has NO: Items, CurrencyItems folders ✅
- [ ] Workspace has NO: Baseplate (normal) ✅
- [ ] ReplicatedStorage has NO: PlayerClick, BuyUpgrade, etc. ✅
- [ ] ServerScriptService has NO: ClickCurrencyHandler, WorldBuilder, etc. ✅

### **Game Works**
- [ ] Click button visible ✅
- [ ] Click works (currency increases) ✅
- [ ] Shop opens ✅
- [ ] Currency displays ✅
- [ ] No errors in Output ✅
- [ ] Camera works ✅

---

## 💾 FINAL SAVE

```
1. File → Save (Ctrl+S)
2. Or: File → Save As → roblox-ui-rng-clicker-clean.rbxlx
3. Wait for save to complete
```

---

## 🚀 NEXT STEPS (After Cleanup)

1. **Update Repository:**
   ```bash
   cd C:\DEV\roblox-ui-rng-clicker
   .\CLEANUP.ps1              # Delete old Lua files
   git add .
   git commit -m "Clean: Remove obsolete code and place objects"
   git push
   ```

2. **Archive Old Files (Optional):**
   ```bash
   # Keep backups of old place files for reference
   rename roblox-ui-rng-clicker.rbxlx roblox-ui-rng-clicker-OLD.rbxlx
   rename roblox-ui-rng-clicker-complete.rbxlx roblox-ui-rng-clicker-complete-OLD.rbxlx
   ```

3. **Build Clean Version:**
   ```bash
   rojo build -o "roblox-ui-rng-clicker-clean.rbxlx"
   ```

4. **Document Changes:**
   - Update README.md to reflect new architecture
   - Reference GIT_DIFF_SUMMARY.md for what changed
   - Note that old files are no longer needed

---

## 📞 SUPPORT

If you encounter issues:

1. **Check GIT_DIFF_SUMMARY.md** for detailed info on what was removed
2. **Restore from backup:** `File → Open → roblox-ui-rng-clicker-backup-[DATE].rbxlx`
3. **Review dependency analysis** in the project
4. **Look at Output window** for specific error messages

---

**Last Updated:** 2026-03-25
**Applies To:** Roblox RNG Weapon Clicker System
**Risk Level:** LOW (all safe deletions verified)
