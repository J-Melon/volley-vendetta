# Items on the Court: Technical Addendum

Implementation design for the item system described in `08-kit-and-locker.md`. Covers the data model, the move-to-court / move-to-kit flow, authored roles (see `08g`), the Fixture resource for physical props, swap economics, ball handling, passive FP, and UI surface. This document is the output of the spike ticket SH-95.

**Dependencies:** Effect System (07), Items on the Court (08), World as One Place (08c), Item UI (09), Shop Drag-and-Drop (`04-shop-drag-drop.md`).

---

## 1. Data model

Ownership lives on `ProgressionData.item_levels: Dictionary[String, int]`. The court/kit split is expressed as a second field that says which owned items are currently active on the court and in which role. Kit membership is derived: everything owned, not on the court, not destroyed.

### New `ProgressionData` fields

```gdscript
# Items placed on the court, keyed by their authored role.
# For exclusive roles (paddle_handle, etc.): role -> single item key.
# For additive roles (ball, court_side, court_surface): role -> array of item keys.
var on_court: Dictionary[StringName, Variant] = {}

var destroyed_items: Array[String] = []   # Permanently removed at the Tinkerer
var kit_accumulated_points: float = 0.0   # Unclaimed passive FP (see section 7)
var kit_last_tick_unix: int = 0           # Wall-clock seconds at last tick commit
```

The `on_court` dictionary is the single source of truth for active items and their positions. The kit is derived: every owned, non-destroyed item whose key is not in `on_court` is in the kit.

`destroyed_items` prevents a destroyed item reappearing if `item_levels` is ever re-derived. Destruction also sets `item_levels[key] = 0`; the list is the durable record.

Swap cooldowns are session-only; see section 5.

### Derived queries (on `ItemManager`)

```gdscript
func get_court_items() -> Array[String]              # flattened from on_court
func get_kit_items() -> Array[String]                # owned + not on court + not destroyed
func is_on_court(item_key: String) -> bool
func role_occupants(role: StringName) -> Array[String]
```

### Why extend `ItemManager` rather than add a new manager

`ItemManager` already owns item ownership, effect registration, save triggers, and balance arithmetic. Court/kit membership is a thin layer over those. Splitting it into a new autoload duplicates the effect registration path and forces cross-autoload save ordering. A single autoload with grouped sections stays under ~300 lines and keeps save atomicity trivial.

**Ticket:** `ItemManager` court/kit data model + derived queries.

---

## 2. Move to court, move to kit

Activation and deactivation run through one pair of methods. Placing an item on the court registers its effects and spawns its fixture (if any) at its authored role. Returning it to the kit unregisters the effects and frees the fixture.

### New `ItemManager` methods

```gdscript
func move_to_court(item_key: String) -> bool
func move_to_kit(item_key: String) -> bool
func swap_at_role(role: StringName, item_key: String) -> bool   # atomic exit + entry
```

### Move-to-court flow

1. Reject if the item is destroyed, not owned, already on the court, or its role cooldown is active.
2. Charge `court_swap_friendship_cost` from the balance. Reject if insufficient.
3. Resolve the item's authored `role`. If the role is exclusive and occupied, atomically move the current occupant to the kit (swap).
4. Add the item to `on_court[role]` (single or array, per role kind).
5. Call `_effect_manager.register_source(item, level)`.
6. If the item has a fixture, spawn it via `FixtureManager` at the role's marker on the court.
7. Start the role's cooldown. Save.
8. Emit `court_changed`.

### Move-to-kit flow

Same in reverse: unregister effects, free the fixture (if any), remove from `on_court`, start the role cooldown. No FP cost on move-to-kit alone (cost is attached to entering the court).

### `swap_at_role` (atomic)

A single gesture that moves a new item onto the court at a role while moving the current occupant back to the kit. One signal emission, one save write.

### Refactor of `_set_level`

`_set_level` no longer eagerly registers effects. After this change:

- Levelling via `purchase()` writes `item_levels` only. If the item is currently on the court, the change triggers a re-register at the new level.
- `take()` keeps its current behaviour: writes `item_levels`, no registration.
- Activation is the only path that registers effects, via `move_to_court`.

The dev panel moves off `purchase()` to a dev-only `purchase_and_place(key)` that acquires the item and places it on the court. The one-click dev experience is preserved.

### SH-93 resolution

SH-93 (shop `take()` currently inert) closes when `move_to_court` lands. `ClearanceBox.accept` remains unchanged: `take()` stays inert by design. The player places the item on the court from the kit once acquired.

**Ticket:** move-to-court / move-to-kit methods, `_set_level` refactor, dev-panel update, SH-93 close-out.

---

## 3. Roles and capacity

Each `ItemDefinition` declares its `role: StringName` (see `08g` for the full role system). Role kinds and their capacity rules are authored in a small registry on `ItemManager`:

```gdscript
const _ROLE_KINDS: Dictionary[StringName, StringName] = {
    &"paddle_handle":    &"exclusive",
    &"paddle_head":      &"exclusive",
    &"paddle_body":      &"additive_small",   # configured max, e.g. 3
    &"paddle_intrinsic": &"additive",         # unlimited
    &"ball":             &"additive",
    &"ball_intrinsic":   &"additive",
    &"court_surface":    &"additive",
    &"court_side":       &"additive",
}
```

`exclusive` roles swap on entry. `additive` roles accept any count. `additive_small` roles accept up to a per-role maximum; entry beyond that evicts the oldest occupant back to the kit.

Adding a new role kind means adding a registry entry and authoring items to use it. No data-model change.

**Ticket:** role registry, `ItemDefinition.role` field, per-role capacity handling.

---

## 4. Fixtures: physical props on the court

Items with a physical form on the court carry a `Fixture` resource. Items without one (intrinsic upgrades, stat items) leave `fixture` null.

### `ItemDefinition` additions

```gdscript
@export var role: StringName            # which role this item fills
@export var fixture: Fixture                  # Optional; spawns a prop when on the court
```

### The Fixture resource

A two-field resource. Pure authoring data.

```gdscript
class_name Fixture
extends Resource

@export var prop_scene: PackedScene    # What appears on the court
@export var dock_marker: StringName    # Marker name on the court to spawn at
```

All runtime state, interactivity, signals, and system overrides (music, input, etc.) live on the prop scene's root script. The `Fixture` resource is just "what to spawn and where."

### `FixtureManager` on the court scene

A thin subscriber to `ItemManager.court_changed`. Spawns and frees fixture props based on court presence.

```gdscript
class_name FixtureManager
extends Node

func _on_court_changed() -> void:
    for item_key in _expected_spawned_keys():
        if not _spawned.has(item_key):
            _spawn(item_key)
    for item_key in _spawned.keys():
        if not _is_still_on_court(item_key):
            _free(item_key)
```

### Prop conventions

Every fixture prop's root script:

- Adds itself to the `&"fixture"` group on `_ready`.
- Owns its own state (the jukebox's `is_playing`, the bot dock's `is_active`).
- Hooks whatever runtime system it overrides directly, not through the item system.
- Frees cleanly on `queue_free`; unhooks overrides so nothing leaks after removal.

Props extend standard Godot node types and duck-type any shared behaviour via the `&"fixture"` group. Each prop stays independent, with only the group name as its shared surface.

### Character places vs item fixtures

The court holds two kinds of installed thing, on different lifecycles:

- **Character places** (the shop table, the tinkerer's bench): gated by character unlocks (`unlocked_characters`, see `08c`). Child scenes of the court, hidden until their character arrives, visible from that moment on.
- **Item fixtures** (bot dock, jukebox): gated by court presence of the item carrying the fixture. Spawned by `FixtureManager`, freed when the item returns to the kit.

Both render into the same court scene. `FixtureManager` puts fixtures at their authored markers; character places have their own dedicated positions authored into `court.tscn`.

**Ticket:** `Fixture` resource, `FixtureManager`, prop group convention.

---

## 5. Swap cost and per-role cooldown (by role)

Both values are tuning knobs per the canon doc. They live in the existing balance config.

### Config (proposed keys)

```
court.swap_friendship_cost: int = 0      # Prototype starts free; Make Fun Pass raises it
court.swap_cooldown_seconds: float = 0.0 # Prototype starts at 0 for playtesting
```

Both hot-reload through `ConfigHotReload` so we can iterate without a restart.

### Per-role cooldown state

Held on `ItemManager` as `_role_cooldowns_until: Dictionary[StringName, float]`, keyed by role name. Not persisted. Cooldown is a moment-to-moment pressure on the move decision. Persisting it across sessions blocks the player on launch for reasons they have forgotten.

### UI surface

Each role on the kit (and each target role on the court) shows a thin radial or linear fill while its cooldown is active. The FP cost is shown on the drag preview when a court-ward drag is in progress.

**Ticket:** Swap cost and per-role cooldown config, signal surface.

---

## 6. Balls on the court

The `ball` role is additive. Every item authored with `role = &"ball"` adds a ball to the court when placed there. The game's ball manager reconciles visible balls against the contents of `on_court[&"ball"]`.

### `ItemDefinition` implications

Any item whose `role == &"ball"` contributes a ball. No separate `spawns_permanent_ball` flag needed: the role is the flag.

### `BallReconciler` on the court scene

Listens to `ItemManager.court_changed` and reconciles the permanent-ball set:

```
expected_permanent_count = size of on_court[&"ball"]
current_permanent_count  = count of live balls tagged "permanent"
diff and spawn/despawn to match
```

Temporary balls (from effects like The Stray's frenzy) are tagged separately and are not touched by the reconciler; they clear on their own expiry.

### Effect-driven temporary balls

Effects that spawn temporary balls use a new outcome type alongside `StatOutcome`:

```gdscript
# scripts/items/effect/outcomes/spawn_ball_outcome.gd
class_name SpawnBallOutcome
extends Outcome

@export var count: int = 1
@export var expiry: StringName = &"on_miss"    # matches existing trigger types
@export var speed_override: float = 0.0        # 0 = inherit current ball speed
```

Temporary balls carry their expiry condition. The `BallReconciler` only manages the permanent set; temporary balls are owned by the effect system.

### Why split permanent and temporary

Permanent and temporary balls have different authoring surfaces (role membership vs effect outcome), different lifecycles (court state vs effect condition), and different owners (reconciler vs effect system). Keeping them parallel lets each stay local to its trigger.

**Ticket:** `BallReconciler`, `SpawnBallOutcome`, authoring for Training Ball and The Stray against the `ball` role.

---

## 7. Passive friendship-point generation (kit)

### Cadence

`ItemManager._process(delta)` accumulates:

```
rate_per_second = sum over kit items of _kit_rate_for(item)
kit_accumulated_points += rate_per_second * delta
```

On each whole unit crossing (`floor(kit_accumulated_points) > last_committed_whole`) emit `kit_points_ticked(item_key, 1)` for the audio layer, and add 1 to the balance via `add_friendship_points`. The fractional remainder stays in `kit_accumulated_points`.

Per-item attribution for the tick is weighted by each item's contribution to `rate_per_second`: the item that tips the accumulator over each whole-unit crossing is the one whose rate carries the highest probability. Weighted pick over exact attribution because the audio layer only needs a plausible source.

### Formula

Cost-weighted by default, with a per-item override:

```gdscript
# ItemDefinition
@export var kit_rate_override: float = 0.0  # FP per second; 0 means use default

# ItemManager (illustrative)
func _kit_rate_for(item: ItemDefinition) -> float:
    var level := get_level(item.key)
    if item.kit_rate_override > 0.0:
        return item.kit_rate_override * level
    return item.base_cost * level * kit_rate_coefficient
```

```
kit_rate_coefficient: float = 0.0005  # Default multiplier, config key
```

Investment in an item is the primary driver, with authoring room to set a specific item's rate when narrative weight diverges from cost.

### Offline / idle handling

On `_ready`, if `kit_last_tick_unix > 0` and the wall-clock gap is positive, compute the catch-up FP and award it as a single lump into `add_friendship_points`. Cap the gap at `kit_offline_cap_seconds` (default 8 hours) to avoid absurd payouts after a week away. The audio layer does not play catch-up ticks: it gets one "welcome back" cue from the UI layer instead.

`kit_last_tick_unix` is updated every save.

### Save frequency

Current `SaveManager.save()` is called on every balance change. With continuous kit ticks that becomes a per-second disk write. Gate it: kit-driven `add_friendship_points` calls skip the autosave, and a 30-second timer flushes the accumulated state. User-driven balance changes (purchases, court moves) save immediately as before.

**Ticket:** Kit passive FP (cadence, formula, offline catch-up, save throttling).

---

## 8. Kit room

The `KitPlace` child scene of `court.tscn` is the gear room at the player's end of the venue. It is always present and always accessible. The player navigates to it the same way as the shop or workshop: by moving toward it, with the camera following within the scene. See `08c` for the venue layout and framing.

### Physical layout

Three zones inside the kit room, each a distinct physical surface:

- **Ball rack:** ball items at rest (Training Ball, The Stray, etc.). A rack or low hopper holds them visibly when not in play on the court.
- **Gear area:** paddle and equipment items (Grip Tape, Cadence, Seven Years, The Call, Ankle Weights, etc.). Shelving or an open case keeps these legible at room scale.
- **Floor space:** larger props and court items when inactive (Spare cone, Dead Weight, etc.). These sit on the floor at their natural scale.

Items active on the court are not present in the kit room — they are at their court positions. Items in the kit room are those currently at rest.

### Player flow

The player enters the kit room by moving toward it. The rally stops on entry; the bot holds the court if active (see `08d`). Inside the room:

- **Kit → court:** the player picks up an item from its zone and carries it to the court. On arriving at the court with the item, `ItemManager.move_to_court(key)` fires; the item snaps to its authored role and the FP cost is charged.
- **Court → kit:** the player picks up an active item from its court position and carries it to the kit room. `ItemManager.move_to_kit(key)` fires on drop in the appropriate zone.
- **Role swap:** carrying a kit item to an occupied exclusive role on the court fires `ItemManager.swap_at_role(role, new_key)`; the previous occupant returns to the kit room.

### Cooldown and cost display

When the player picks up an item in the kit room intending to bring it to the court, the FP cost and any active role cooldown are shown on the carry preview. Role cooldown overlays appear on the relevant court-side role marker as the player approaches with the item.

**Ticket:** Kit room scene: ball rack, gear area, floor space, player navigation, carry-to-court interaction, cooldown and cost display.

---

## 9. Signal surface

`ItemManager` gains:

```
signal court_changed                            # Any move-to-court / move-to-kit / swap
signal role_cooldown_changed(role: StringName)  # Cooldown start/expire
signal kit_points_ticked(item_key, amount)       # Audio hook
```

Existing signals (`friendship_point_balance_changed`, `item_level_changed`) keep their semantics.

---

## 10. Testing

Unit-testable without a Viewport:

- `move_to_court` / `move_to_kit` / `swap_at_role` state transitions and FP debits.
- Role capacity behaviour (exclusive swap, additive stacking, small-additive eviction).
- Ball reconciliation (adding / removing / multiple ball items).
- Kit passive FP rate arithmetic (drive a fixed delta, assert accumulated points).
- Offline catch-up and the offline cap.

End-to-end drag flows are manual play-test, matching the shop pattern.

---

## 11. Follow-up tickets (proposed)

Candidate implementation tickets. These are candidates only; creation is gated on the current cycle needing them.

1. `ItemManager` court/kit data model + derived queries and signals.
2. Move-to-court / move-to-kit / swap-at-role methods, `_set_level` refactor, dev-panel update, SH-93 close-out.
3. Role registry + `ItemDefinition.role` field + per-role capacity handling.
4. `Fixture` resource, `FixtureManager`, prop group convention.
5. Swap cost + per-role cooldown config + signal surface.
6. `BallReconciler` + `SpawnBallOutcome` + Training Ball and The Stray authored against the `ball` role.
7. Kit passive FP (cadence + formula + offline catch-up + save throttling).
8. Kit UI on the court: drag wiring, role visualisation, cooldown overlays.
9. Refactor the shop into the single-place world: friend unlock gates the shop's visibility as a child of `court.tscn`; kit items stay on the friend's table via the existing `ClearanceBox` drag-drop; catalog items move to the catalog surface and order through the shipment system; the shop sits in the diorama rather than opening as a secondary scene. Design reference: `08c-world-as-places.md`.
10. Kit passive-FP audio layer (post-prototype polish).

Nine in-prototype tickets plus one polish ticket. Each is independently shippable behind the kit staying out of the UI until tickets 1, 2, and 8 are all in.
