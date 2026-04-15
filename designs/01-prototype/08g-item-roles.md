# Item Roles: Technical Doc

How items find their physical place on the court. Defines the role system, the authoring contract between `ItemDefinition` and `court.tscn`, the capacity rules per role, and the resolution from "this item moves onto the court" to "this prop sits at this world position."

**Dependencies:** Items on the Court (`08`, `08a`), World as One Place (`08c`).

---

## What a role is

A **role** is a named location-plus-function on the court where items belong. Roles are authored into `court.tscn` as markers, named and positioned by the level designer. Each item declares the role it fills as `ItemDefinition.role: StringName`. When the player moves an item onto the court, the role registry looks up where the role lives in the scene and places the item's visible form there.

Roles carry two things:

1. **A position** (a Marker2D/Marker3D node in `court.tscn`, or a set of positions for multi-occupant roles).
2. **A capacity rule** (exclusive, additive, additive-small), registered on `ItemManager`.

Roles are not themselves items. They do not appear in `item_levels`, they have no persistence, they have no effects. They are pure positional structure authored into the court.

---

## Role kinds

Three capacity rules cover the prototype needs. Each is a registry entry:

| Kind | Behaviour | Example roles |
|---|---|---|
| `exclusive` | Holds one item at a time. Moving a new item in evicts the current occupant back to the kit. | `paddle_handle`, `paddle_head` |
| `additive` | Accepts any number of items. Each occupant registers its effects and (if it has a fixture) spawns its prop. | `ball`, `court_surface`, `court_side`, `paddle_intrinsic`, `ball_intrinsic` |
| `additive_small` | Accepts up to a per-role configured maximum. Entry beyond that evicts the oldest occupant back to the kit. | `paddle_body` (cap of 3, say) |

Adding a new role kind means adding an entry to the registry. No data-model change.

### Registry on `ItemManager`

```gdscript
# Illustrative
const _ROLE_REGISTRY: Dictionary[StringName, Dictionary] = {
    &"paddle_handle":    {"kind": &"exclusive"},
    &"paddle_head":      {"kind": &"exclusive"},
    &"paddle_body":      {"kind": &"additive_small", "cap": 3},
    &"paddle_intrinsic": {"kind": &"additive"},
    &"ball":             {"kind": &"additive"},
    &"ball_intrinsic":   {"kind": &"additive"},
    &"court_surface":    {"kind": &"additive"},
    &"court_side":       {"kind": &"additive"},
}
```

Config-driven, hot-reloadable. The registry is the single source of truth for "what does this role name mean."

---

## Authoring a role

A role exists when two things are true:

1. A marker node in `court.tscn` named `Role_<role_name>` (or inside a known group, see below) declares a position.
2. An entry in the role registry declares its capacity rule.

Both are prerequisites: an item with a `role` that has no marker has nowhere to go; a marker with no registry entry has no rule for what fits.

### Marker convention

All role markers live under a single `Roles` node in `court.tscn`, grouped by parent (the paddle, the ball origin, the court surface):

```
court.tscn
├── ...
└── Roles
    ├── Paddle
    │   ├── Handle           (Marker2D, one position)
    │   ├── Head             (Marker2D, one position)
    │   └── Body             (Node holding multiple child Marker2D, for additive_small)
    ├── Ball
    │   ├── SpawnOrigin      (Marker2D; ball items spawn relative to this)
    │   └── Intrinsic        (Marker2D, abstract position for ball_intrinsic items)
    ├── Court
    │   ├── Surface          (Marker2D, abstract centre of the playing floor)
    │   └── Sides            (Node holding multiple child Marker2D for court_side positions)
    └── Intrinsic            (Marker2D, abstract collector for paddle_intrinsic items)
```

### Why intrinsic roles have markers at all

Intrinsic roles don't spawn a visible prop, but they still need a conceptual address for the role registry to resolve. The marker's position is used for debug visualisation and for any UI indicator (a small emblem row near the paddle) that shows what intrinsic items are active.

### Additive-small role positions

An `additive_small` role like `paddle_body` authors a set of child positions (e.g. three `Marker2D` children under `Roles/Paddle/Body`). When multiple items occupy the role, each picks a free child position in order. On eviction, remaining occupants stay where they are.

### Additive role positions (multiple props, no cap)

An `additive` role like `court_side` authors several positions too (each a separate prop location on the court side). When items with `role = &"court_side"` land there, each picks the next free position. Authored position count caps the practical number of props, even though the registry rule is "additive unbounded."

---

## Placement resolution

When `ItemManager.move_to_court(item_key)` succeeds, the path from "item owned" to "prop visible" is:

1. `ItemManager` adds the item to `on_court[role]` per role kind (exclusive replaces, additive appends, additive-small appends and evicts oldest if over cap).
2. `ItemManager` registers the item's effects with `EffectManager`.
3. `FixtureManager` (subscribed to `court_changed`) checks whether the item has a `fixture`.
4. If yes, `FixtureManager` asks `ItemManager` for the authored position for this item at this role (helper: `get_role_position(role, item_key) -> Vector2`).
5. `FixtureManager` spawns the fixture's `prop_scene` and places it at that position (setting the prop's `global_position`).
6. If no fixture, steps 4-5 are skipped. The item is still active (effects registered) but has no visible prop.

### `get_role_position` logic

Given the role registry kind and the marker layout:

```gdscript
func get_role_position(role: StringName, item_key: String) -> Vector2:
    var registry_entry := _ROLE_REGISTRY[role]
    match registry_entry["kind"]:
        &"exclusive":
            return _marker_for(role).global_position
        &"additive", &"additive_small":
            var position_index := on_court[role].find(item_key)
            return _child_markers_for(role)[position_index].global_position
        _:
            push_error("Unknown role kind: %s" % registry_entry)
            return Vector2.ZERO
```

Exclusive roles resolve to their single marker. Additive roles resolve to the child marker at the item's index in the role's occupancy array.

---

## Capacity rules in detail

### Exclusive

- Entry: if occupied, the current occupant is moved to the kit as part of the same gesture (one atomic `swap_at_role` call, one `court_changed` signal).
- The incoming item charges its swap cost and starts the role cooldown once.
- The outgoing item does not charge a second time; its move-to-kit is a side effect.

### Additive

- Entry: appended to `on_court[role]`. No eviction.
- Each item still pays its own swap cost on entry.
- Per-role cooldown applies to the role as a whole: rapid-fire entries into the same additive role are rate-limited.

### Additive-small

- Entry: appended, unless `on_court[role].size() >= cap`, in which case the oldest occupant is evicted back to the kit.
- Eviction preserves order (new item appended at end, first item removed).
- One `court_changed` signal per gesture.

---

## Drag-and-drop interaction with roles

Drag-and-drop lives in the kit and court surfaces (see `08a` section 8 and `08c`). From the role system's perspective:

- **Kit → court:** the player picks up an item in the kit room and carries it to the court. On arrival at the court, `ItemManager.move_to_court(item_key)` runs; the item snaps to its authored role.
- **Court → kit:** the player picks up an active item from its court position and carries it to the kit room. `ItemManager.move_to_kit(item_key)` fires on placement in the appropriate zone.
- **Court → court (swap):** carrying a kit item to an occupied exclusive role fires `swap_at_role(role, new_key)`; the previous occupant returns to the kit room.
- **Visual feedback during carry:** the authored markers for the item's target role highlight as the player approaches the court with the item in hand. A `RoleHighlighter` helper listens to carry-start events and lights the target markers.

Drops onto the wrong area (e.g. dragging a `paddle_handle` item onto the court surface) fall back to the item's authored role automatically. The player cannot place an item at the wrong role, because the role is baked into the item. The drop gesture is "bring this onto the court"; the role is "where on the court."

---

## Fixture coordination

Fixtures (see `08a` section 4) sit at role-resolved positions.

- `FixtureManager` listens to `court_changed` and spawns/frees props on role occupancy.
- Spawn position is always resolved via `ItemManager.get_role_position(role, item_key)`.
- The prop's `global_position` is set on spawn; the prop does not reposition itself afterward (unless its own animation moves it, e.g. the bot paddle moving in to play).
- On free, the prop is `queue_free`'d; the role position becomes available for the next occupant.

Fixtures and roles are loosely coupled. A fixture does not know about its role directly; it only knows where it was spawned. A role does not know about fixtures; it only knows occupancy. `FixtureManager` is the glue.

---

## Character places vs item roles

Roles hold **items**. Character places (the shop, the workshop) hold **characters**. They look similar (both live at authored positions in `court.tscn`, both are gated by some condition) but they are on different lifecycles and use different authoring:

- Roles: authored under `Roles/`, gated by item occupancy, managed by `ItemManager` + `FixtureManager`.
- Character places: authored as top-level child scenes of `court.tscn`, gated by `unlocked_characters`, shown/hidden directly.

An item at a `court_side` role can sit *near* the shop place; they are neighbours in `court.tscn`, but neither is parented under the other. This separation keeps the two systems independent.

---

## Authoring a new role kind

Adding a new role kind (e.g. a `net` kind with its own capacity rule) is a four-step authoring change:

1. Add the registry entry: `&"net": {"kind": &"exclusive"}` (or whichever kind fits).
2. Add the marker node(s) in `court.tscn` under `Roles/Net` (or wherever makes sense).
3. Declare items that target it: `role = &"net"` on the relevant `ItemDefinition`s.
4. If the capacity rule is genuinely new (not one of exclusive/additive/additive-small), add a branch to `ItemManager`'s move logic and the `get_role_position` resolver.

Most new roles will fit an existing capacity rule, so step 4 is rarely needed.

---

## Testing

Unit-testable without a Viewport:

- Occupancy behaviour per role kind (exclusive swap, additive append, additive-small eviction).
- `get_role_position` returns the right marker for each kind.
- `court_changed` fires the correct signals on each transition.
- Role cooldown timing per role.
- Missing-marker error cases (item declares a role that has no authored marker) surface cleanly.

End-to-end drag tests are manual, matching the shop pattern.

---

## Open design decisions

1. **Debug visualisation.** Should a dev-only overlay draw each role marker and its current occupant? Leaning: yes, behind a keypress. Valuable during art and layout passes.
2. **Role priority on the paddle.** If the paddle ever has multiple head roles (a paddle_head_left and paddle_head_right), how does an item choose? Leaning: author each as its own named role; do not auto-pick.
3. **Overflow visual for additive roles.** If `court_side` authors three positions but the player tries to place a fourth, what happens? Leaning: registry enforces `additive` as unbounded; practical cap is position count; overflow items get stacked at the last authored position. Alpha can refine.
4. **Role cooldown: per role or per item?** Currently per role (rapid moves into the same role are limited). Keep that, even when the items are different. The cooldown models "the paddle was just handled" more than "this specific item."

---

## Rough ticket outline

Not filing yet.

1. Role registry on `ItemManager`: kinds, capacity rules, validation.
2. `ItemDefinition.role` field + authoring pass across existing items.
3. `Roles/` node hierarchy in `court.tscn` with markers for the initial role set.
4. `ItemManager.get_role_position(role, item_key)` resolver.
5. `FixtureManager` integration: spawn at resolved position, free on role vacancy.
6. Drag-visual role highlighter (`RoleHighlighter` helper that listens to drag start and lights the target markers).
7. Dev-only role overlay for debug.

Overlap with the Locker and Kit and the Desktop Experience projects will need reconciling.
