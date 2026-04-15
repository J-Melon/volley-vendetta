# Scene Layout

The world lives in one scene: see `08c-world-as-places.md` for the court and everything in it. This document is the narrow companion covering UI chrome and resolution: HUD placement and stretch mode.

**Dependencies:** `08c-world-as-places.md` for the world layout itself.

---

## Root scene

`court.tscn` is the root of the running game. It holds the arena, the kit room, the shipment mat, character places (shop, workshop), reserved markers for fixtures, and the single-framing camera. Nothing sits above or beside the venue at the scene level.

---

## HUD

The HUD is a `CanvasLayer` child of `court.tscn`, rendering in screen space above the world. Volley counter, FP balance, personal best, pause/settings button, and new-arrival highlights live here. The HUD stays lean: the world speaks for itself through the diorama, so the HUD's job is indicators and system controls rather than navigation.

HUD elements use anchors so they hold their screen positions across resolutions. No HUD element is tied to a world-space node.

New-arrival highlights (a shipment arriving on the mat, a finished commission on the done tray, a character just unlocked) can surface through a subtle HUD cue: a small pulse near the relevant world element or a brief label. The goal is to point the player's eye without pulling the camera or opening anything.

---

## Resolution and stretch

The project runs under Godot's `canvas_items` stretch mode with a `keep` aspect ratio. The court scene sizes itself to the viewport; the HUD `CanvasLayer` sizes itself to screen space. Neither depends on a wrapping `SubViewport`.

Steam Deck, desktop, and phone targets all receive the same root scene at their native aspect; the stretch mode handles the letterboxing.

---

## What carries forward from earlier drafts

The earlier tiling design (with `SceneLayout`, `SubViewportContainer`, and secondary-scene slots) is superseded by the single-place model in `08c`. The surviving principles:

- The game fills whatever space the display gives it.
- The HUD is always available.
- Diegetic framing: the player sees the world, not a menu stack.

---

## Out of scope

- Windowed desktop mode and its multi-window behaviour: `SH-51` territory, builds on this root without replacing it.
- Camera framing: detailed in `08c`.
- Panels, sibling scenes, tiling negotiation: the `08c` rewrite uses a single diorama framing instead.
