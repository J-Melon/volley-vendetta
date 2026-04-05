# Item UI — Diegetic Drag and Drop

Design notes for how items are presented and manipulated in the UI.

---

## Core concept

Items are diegetic objects. They exist as physical cards or objects in the world that the player drags between slots. No abstract menus. The player sees their kit laid out in front of them and physically moves items between kit slots and the locker.

---

## Interaction model

- Items are draggable objects (Control or Node2D scene)
- Each item scene holds a reference to its `Item` resource and reads it for display data (sprite, name, description state)
- Slots are drop targets: kit slots and locker slots
- Dragging an item from one slot to another triggers equip/unequip logic in ItemManager

---

## In-panel drag-and-drop

The clear-out, kit, and locker all use Control node drag-and-drop within a single UI panel. This is standard Godot UI: draggable Control nodes dropped onto slot targets. No spike needed.

- Clear-out: drag items from the friend's things into the box to take them
- Kit/locker: drag items between kit slots and locker slots to equip/unequip

---

## Desktop experience: cross-window drag-and-drop

The game runs as multiple OS windows on desktop. The open question is how to drag items between separate windows (e.g. dragging an item from a locker window into a kit window).

A fullscreen mode is also planned to support portable devices (e.g. Steam Deck), where multiple OS windows are not available. The cross-window drag solution must have a fullscreen equivalent.

This is the scope of SH-51.

---

## Open questions

- Cross-window drag: OS-level drag, shared viewport, or something else?
- How does cross-window drag translate to fullscreen mode on portables?
- What happens visually when a slot is full (swap vs reject)?
- How does item level and degradation state show on the card?
- Can items be dragged during a rally, or only between rounds?

---

## Notes

- The `Item` resource is pure data — no visual nodes. The draggable scene owns visuals and reads from the resource.
- ItemManager handles all registration/equip logic triggered by drop events.
