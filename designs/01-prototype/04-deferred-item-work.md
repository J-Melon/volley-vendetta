# Deferred item work

Tracking incomplete item features for later ticketing.

---

## Double Knot (level 3)

- `share_stats_with_partner`: partner paddle receives all player stat buffs
- `on_edge_hit` trigger: fires when ball hits the extreme edge of the paddle
- `momentum_boost` outcome: temporary surge for both paddles

---

## Spare

- Kit slot system: nothing reads `kit_slots` stat yet; UI needs to enforce slot limits, show slots, handle equip/unequip

---

## Item effect VFX

- No art/VFX design doc exists for item effects
- The items design doc lists signals for presentation (frenzy fire, gravity distortion, colour flash, ball deflect flash, etc.) but no visual spec
- Needs: VFX style guide per effect type, art direction alignment, particle/shader scope
- Blocked on Art Direction (v0.2-0.3 Alpha in art roadmap)
