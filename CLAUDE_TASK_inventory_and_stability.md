# Claude Task: Inventory Use, Stability Baseline, and Next Safe Targets

## Baseline
- Repo: `SuperPaperCo_rev_0.0.5`
- Current code baseline: post-rollback from `7ec65cc`
- Local-only fixes after rollback:
  - `scripts/Hazard.gd`: typed parse fix so the project launches
  - `scripts/GameManager.gd`: real inventory counts and consumable use
  - `scripts/PickupItem.gd`: pickups add to inventory instead of auto-consuming
  - `scripts/GameWorld.gd`: `Q` inventory now has actionable use buttons
- Preserve local backups in `backups/`

## What Changed In This Pass

### Inventory is now real, not decorative
- `solvent` and `supplies` are stored in inventory instead of auto-triggering on pickup
- `document` pickups still add XP, but are also counted in inventory summary
- `Q` inventory panel now shows actionable buttons:
  - `Use Solvent`
  - `Use Pen + Notepad`
- Button state is live:
  - Solvent disables if none are owned or stress is already at zero
  - Supplies disable if none are owned or HP is already full

### Files changed
- `scripts/GameManager.gd`
- `scripts/PickupItem.gd`
- `scripts/GameWorld.gd`
- `scripts/Hazard.gd`

## Current Inventory Contract

### `GameManager.gd`
- Added:
  - `signal inventory_changed`
  - `var inventory_items = { "solvent": 0, "supplies": 0, "document": 0 }`
- Added methods:
  - `register_inventory_pickup(pickup_id, item_name, item_kind, value)`
  - `item_count(item_kind)`
  - `use_inventory_item(item_kind)`
- Save/load now persists `inventory_items`

### Item behavior
- `solvent`
  - pickup adds 1+ solvent to inventory
  - using one reduces stress by `18.0`
- `supplies`
  - pickup adds 1+ supplies to inventory
  - using one heals `1 HP`
- `document`
  - pickup increments inventory count
  - pickup also grants XP immediately

### `PickupItem.gd`
- No longer auto-applies heal/stress effects on body enter
- Now routes all collection through:
  - `GameManager.register_inventory_pickup(...)`

### `GameWorld.gd`
- `Q` still toggles the inventory panel
- Inventory now builds action buttons dynamically under the case readout
- Refresh is driven by:
  - `GameManager.inventory_changed`
  - `GameManager.stats_changed`

## What Claude Should Test First
1. Launch project
2. Enter game from title screen
3. Pick up one solvent item
4. Press `Q`
5. Confirm `Use Solvent (1)` is visible and clickable
6. Click it
7. Confirm stress changes and count decrements
8. Repeat with supplies while HP is below max
9. Save and load to confirm inventory counts persist

## High-Risk Areas
- `GameWorld.gd`
  - inventory panel is partly scene-authored, partly built at runtime
- `GameManager.gd`
  - save/load payload shape changed due to `inventory_items`
- `PickupItem.gd`
  - changed user-facing gameplay behavior from “instant effect” to “stored consumable”

## Do Not Do Yet
- Do not reattempt the unified player/NPC rig refactor in this branch
- Do not rewrite the room system into a seamless world
- Do not mix large visual refactors into this inventory stabilization pass

## Recommended Next Safe Tasks
1. Make the inventory buttons navigable by keyboard as well as mouse
2. Add a highlighted item description panel in the inventory
3. Add explicit item stacks/icons in the case grid
4. Add a small “used item” confirmation popup in HUD
5. Only after inventory is solid, return to NPC/player rig unification

## Runtime Truth To Preserve
- The user wants the currently restored gameplay baseline preserved
- This branch is about making that baseline usable, not about architectural cleanup
- Optimize for stable play behavior first
