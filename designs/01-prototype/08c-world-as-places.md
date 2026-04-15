# World as One Place

Replaces the tiling scene layout model from `08-scene-layout.md` with a single-place world: the court, the friend's shop, the tinkerer's workshop, the kit, the bot dock, and the shipment mat all live in one scene and the player attends to each by looking at it. This document is the fourth pass on scene layout and the one we plan to build against; earlier drafts (including the separate-scenes model) are superseded.

---

## Pitch in one breath

There is one place: the venue. The court sits at the centre; the friend's shop is at one end; the tinkerer's workshop is at another; the kit room is at the player's end, a shared gear room where the player's items live when not on the court. The shipment mat is nearby. The camera moves within this scene to focus each interaction. Characters and their places arrive as the player unlocks them and travel with the venue as it migrates across milestones.

No window management, no scene switching, no travel transitions. The player lives in one continuous space.

---

## The court scene

`court.tscn` (renamed from today's `main.tscn`) owns the whole playable world. Its children:

```
court.tscn
├── Arena (existing: paddles, ball, HUD, walls)
├── KitPlace (gear room at the player's end, always present)
│   ├── BallRack (ball items when not on court)
│   ├── GearArea (paddle and equipment items at rest)
│   └── FloorSpace (larger props and court items when inactive)
├── ShipmentMat (where arriving boxes land, near the kit room entrance)
├── ShopPlace (hidden until the friend unlocks)
│   ├── FriendCharacter
│   ├── ShopTable (small items the player takes directly)
│   ├── ShopCatalog (bigger items the player orders)
│   └── ShippingCounter (where the friend seals orders for delivery)
├── WorkshopPlace (hidden until the tinkerer unlocks)
│   ├── TinkererCharacter
│   ├── Workbench (where items in progress sit)
│   └── DropOffBasket (where the player leaves items for work)
├── Roles (authored markers under which `FixtureManager` spawns props for items in each role: bot dock, jukebox, future props)
└── Camera (single framing that holds the whole venue as one readable diorama)
```

The venue is one continuous space. The player attends to each place by looking toward it; the camera follows within the scene. Going to the kit room, the shop, or the workshop stops the rally — the player is away from the court. The bot holds the court in the player's absence when it is active (see `08d`). Interactions that stay courtside (dropping something at the shipment mat, picking up a finished item from the done tray if visible from the court edge) keep the rally live.

Each place stays visible and reachable at all times once present. The player carries items between places on foot within the scene: take an item from the kit room to the workshop drop-off basket, carry a shop table item to the kit room, drag a court item off the paddle back toward the kit room entrance. No gesture teleports items across the venue in one drag; the player physically moves between places.

---

## Character unlocks

The friend, the tinkerer, and future characters (partners aside) unlock on a partner-style track.

### `ProgressionData` addition

```gdscript
var unlocked_characters: Array[StringName] = []
```

Mirrors `unlocked_partners`. Persisted. Each character has a unique key (`&"friend"`, `&"tinkerer"`, etc.).

### Unlock flow

Each character has its own trigger. The prototype starts with three unlocks authored:

| Character | Trigger | Arrives with |
|---|---|---|
| Friend | Reaches a first FP threshold (tuned), or a scripted early beat | The shop (table + catalog + shipping counter) |
| Tinkerer | Later FP threshold or post-friend beat | The workshop (workbench + drop-off basket) |
| Partners (Martha, etc.) | Existing partner track (see `11-first-partner-unlock.md`) | Themselves, in front of the right wall |

Unlocks are narrative moments, not menu events: the character walks in, sets up, the place becomes visible, the court stays busier from then on. The arriving animation plays once; future loads start with the character already present.

### Starting state

Early game: the player on an empty court with the arena, the kit room, and the shipment mat. No shop, no workshop, no partners. The quiet gives the friend's arrival somewhere to land.

---

## The shop

Full treatment in `08e-shop-as-place.md`. Summary for world context:

Once the friend is unlocked, her place is visible in the diorama: a table (pool-gated small items, grab-and-go via the existing `ClearanceBox` drag-drop from `04-shop-drag-drop.md`), a catalog (bigger items, browsed inline, ordered and shipped), and a shipping counter (brief visual beat as orders leave for the shipment mat). Table items go with the player to the kit room on take; catalog orders ship and land on the shipment mat later.

## The workshop

Full treatment in `08f-tinkerer-at-work.md`. Summary for world context:

Once the tinkerer is unlocked, his place is visible in the diorama: a workbench, a done tray, and a drop-off basket. The tinkerer runs a small state machine (resting / procrastinating / working) that determines when commissions make progress; the player drops off items and picks up completed work from the done tray. The tinkerer does not use the shipment system; his work happens in view at his own place.

---

## Shipments: catalog delivery from the shop

The shipment system carries catalog orders from the shop to the court. That is the whole of its role. The tinkerer runs on their own state machine (above) and does not use shipments.

### `ShipmentManager` autoload

Persisted state. Survives quitting and reloading.

```gdscript
class Shipment:
    var id: StringName
    var contents: Array[String]  # item keys from the catalog
    var arrive_at_unix: int      # wall-clock ready-at
    var opened: bool             # landed but not yet unpacked

signal shipment_arrived(shipment: Shipment)

func create(contents: Array[String], duration_seconds: int) -> StringName
func pending() -> Array[Shipment]
```

Wall-clock timing: shipments tick while the game is closed. On resume, any shipment whose `arrive_at_unix` has passed fires `shipment_arrived` in order during court scene ready.

### Why the wait, with no distance

The shop is a short walk away in-frame. The wait is about stewardship, not travel: the friend packs the order, adds a note, decides when to let it go, and carries it over. The delay is the friend taking care of the handover. That framing fits a friend who remembers each item they give you, and it lets per-order timing carry meaning: a quick send-off vs. a slower, more considered one.

### Milestones

The court migrates across milestones. Since all places live in one scene, "migration" redresses the scene rather than relocating characters. Shipments in flight when a milestone fires continue ticking; the box arrives on the shipment mat as it now exists in the new milestone dressing.

### Visual delivery

When a box lands, the friend appears with it: walks in from the shop side, sets the box down, returns to their place. Seeing the friend place the box reinforces that someone did the work, that the wait was on their behalf. Prototype can use a placeholder animation (friend fades in near the mat, box appears, friend fades out); art passes later.

### Tuning knobs (config)

```
shipment_friend_catalog_seconds: int = 30     # Default catalog-to-court time
shipment_offline_cap_seconds: int = 28800     # 8 hours, mirrors locker catch-up cap
```

Per-item overrides possible through `ItemDefinition` if a catalog item wants its own shipping time (e.g. the bot ships slower as a narrative beat).

---

## Single framing

The camera holds one framing that takes in the whole venue as a readable diorama. Arena at the centre, kit room at the player's end, shipment mat near the kit room entrance, shop at one side, workshop at another, bot dock and other fixtures at their authored positions. Everything legible at once.

Art discipline is what makes this work: the prototype layout places each place clearly within the frame without crowding, and the art pass later refines composition. The camera shifts focus within the same scene as the player moves between places — no cuts, no transitions.

---

## What the bot and fixtures do here

The bot is an item with `role = &"court_side"` and a fixture pointing at the bot dock prop (see `08d`). `FixtureManager` spawns the bot dock when the bot item is placed on the court. The dock takes over idle play on the court (space-bar handoff) and parks when the player resumes. No travel, no away-mode: the bot is the idle-play upgrade.

Future item fixtures (jukebox, any other physical prop the player earns by owning an item) follow the same pattern: their prop scene spawns at their authored marker when the item is on the court, runs its own state machine, frees when the item returns to the kit or is destroyed.

Character places and item fixtures coexist in the same court scene as different rendering layers, on different lifecycles (see `08a` section 4).

---

## What lives in the venue (summary)

| Element | Always present? | Gating |
|---|---|---|
| Arena, paddles, ball | Yes | None |
| Kit room (ball rack, gear area, floor space) | Yes | None |
| Shipment mat | Yes | None |
| Shop (friend, table, catalog, shipping counter) | No | `&"friend"` in `unlocked_characters` |
| Workshop (tinkerer, workbench, drop-off basket) | No | `&"tinkerer"` in `unlocked_characters` |
| Bot dock | No | Bot item on the court |
| Jukebox (future) | No | Jukebox item on the court |
| Partners (Martha, etc.) | No | Existing partner unlock track |

---

## What this replaces

From earlier drafts (`08-scene-layout.md`, `08b-scene-layout-rethink.md`, earlier versions of this doc):

- `SceneLayout` tiling and sibling management: the prototype needs one scene.
- `TravelManager` and the travel transition: the player never leaves the court.
- Separate `clearance.tscn` / `workshop.tscn` scenes: child nodes of `court.tscn` instead.
- "Places travel with the player" subsection: the court migrates as a whole; redressing the scene is the mechanism.
- "Away" mode for the bot: idle is the only activation trigger.

What carries forward unchanged:

- Control-based drag-and-drop within a place (shop table, kit, catalog drag-to-box gestures).
- Reusable `item_dragging.tscn` drag preview.
- Stable contract (`can_be_taken` / `can_accept` / `accept`) on every drop target.
- `ShipmentManager` with wall-clock persistence (framing changes, mechanism does not).

---

## Open design decisions

My leanings in brackets.

1. **Catalog browsing UX.** A physical book on the shop counter the player flips through, a stack of cards the friend deals out, or a tablet-shaped prop? [Book or cards; tablet breaks the fiction.]
2. **Does the friend remember what you browsed?** Returning to the catalog after leaving mid-browse: does it open to the last page, or reset? [Opens to the last page; the friend holds your spot.]
3. **Multiple catalog orders in flight?** One at a time, queued at the shipping counter, or parallel? [Parallel; each order is its own shipment.]
4. **Visual density on the court.** Once shop + workshop + bot dock + partners are all unlocked, the court has a lot of characters. Does the camera zoom into the arena hide the periphery during play, or is the full cast always visible? [Camera framing keeps the arena tight during play; the periphery rides the edges.]
5. **Tinkerer level-up ETA: per level, or per item?** [Per item, via `ItemDefinition.tinker_seconds_per_level`; authors tune it alongside cost scaling.]

---

## Relationship to other designs

- **Items on the court tech addendum (`08a`):** sections 3–4 define roles, fixtures, and the character-vs-fixture split this doc builds on. Section 7 (kit passive FP) is unchanged. Section 8 (UI surface) is the kit visible in the diorama.
- **The shop (`08e`):** the friend's place, the table, the catalog, and the shipping counter; ordering flow and shipment framing.
- **The tinkerer (`08f`):** the workshop, the state machine, the commission queue, and the done tray.
- **Shop drag-drop (`04-shop-drag-drop.md`):** the table interaction (`ShopItem` / `ClearanceBox` / `item_dragging.tscn`) is unchanged, just loaded as a child of `court.tscn` rather than a standalone scene.
- **The bot (`08d`):** item with `role = &"court_side"` and a fixture; idle-only activation.
- **First partner unlock (`11`):** partners follow their own track; their unlock shows them on the court alongside the friend and tinkerer.
- **Idle play (`10`):** the space-bar handoff remains; the bot upgrades how idle feels once owned.

---

## Rough ticket outline

Not filing yet.

World-level tickets. Shop-specific tickets live in `08e`; tinkerer-specific tickets live in `08f`.

1. `court.tscn` rebuild: kit room (ball rack, gear area, floor space), shipment mat, reserved markers for character places and role positions, single-framing camera.
2. Character unlock system: `unlocked_characters` on `ProgressionData`, arrival narrative beats, show/hide of child scenes.
3. `ShipmentManager` autoload: wall-clock persistence, offline catch-up, arrival signal firing on scene ready. Used by the shop's catalog only.
4. Diorama layout pass: place the shop, workshop, kit room, shipment mat, and fixture markers so the whole venue reads clearly in one frame.
5. Milestone migration hook: scene redress on milestone change, character and commission state preserved.

Overlap with the kit/locker, shop, and tinkerer projects will need reconciling when the work is filed.
