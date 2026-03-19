# Claude Project Status — 2026-03-19

## Stable Baseline
- Working commit base: `7ec65cc`
- Current local state is the restored post-rollback prototype plus inventory fixes
- This state is considered playable again and should be preserved before major progression/UI changes

## Local Backups
- `backups/work_in_P_0.1.3_post_rollback_20260319-020254`
- `backups/work_in_P_0.1.4_pre_progression_20260319-021936`

## Current Important Local Changes

### 1. Parse/stability fix
- `scripts/Hazard.gd`
- Fixed a typed warning treated as parse error:
  - `var seed: int = ...`
- Without this, the restored baseline fails to launch

### 2. Inventory is now real
- `scripts/GameManager.gd`
- Added:
  - `inventory_changed` signal
  - persistent `inventory_items` dictionary
  - `register_inventory_pickup(...)`
  - `item_count(...)`
  - `use_inventory_item(...)`
- Save/load now persists inventory counts

### 3. Pickups no longer all auto-consume
- `scripts/PickupItem.gd`
- Pickups now route into inventory state
- `document` still grants XP immediately
- `solvent` and `supplies` are stored as inventory items
- `supplies` now also auto-heal one heart on pickup if player is injured

### 4. Q menu is actionable now
- `scripts/GameWorld.gd`
- Inventory panel now has:
  - `Use Solvent`
  - `Use Pen + Notepad`
  - live item counts
  - disabled state when item cannot be used
- The panel refreshes from both stat changes and inventory changes

### 5. Existing Claude task file
- `CLAUDE_TASK_inventory_and_stability.md`
- This still applies and should be kept as reference for the inventory branch

## Current Gameplay Rules

### Inventory
- `solvent`
  - stored in inventory
  - usable from Q menu
  - reduces stress
- `supplies`
  - auto-heal 1 heart on pickup if injured
  - remaining stored supplies stay usable from Q menu
- `document`
  - counted
  - grants XP on pickup

## What Still Needs Work
- bottom-left control legend on HUD
- quarter-heart health model
- hazard-specific damage tiers:
  - solvent: quarter-heart type damage/effect
  - forklift: one heart
  - paper roll: two hearts
- 100 XP heart gain progression
- XP-weighted skills such as synthesis/evasion
- more Tunic-style isometric rooms without literal doors

## What Not To Break
- working Q inventory
- restored room-based architecture
- hallway-threshold style transitions
- currently functioning pickup flow
- current music integration (`SuperPaperCo.mp3`)

## Recommended Next Work Order
1. Preserve this state in git
2. Fork into a new local folder for the progression pass
3. Add HUD shortcut legend
4. Change HP to quarter-heart units under the hood
5. Add XP milestone heart growth
6. Add lightweight skill scaffolding
7. Add first new doorless Tunic-style rooms

## Warning
- Do not restart the unified Player/NPC rig refactor in this branch until the progression and HUD pass is stable
- Do not reattempt seamless-world stitching here
