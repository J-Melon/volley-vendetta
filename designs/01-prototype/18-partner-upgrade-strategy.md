# Partner Upgrade Strategy

## Goal

Define how partners scale with the player's progression so that no partner becomes a bottleneck or obsolete as the game advances.

**Points:** Spike
**Dependencies:** Partner AI (`17-partner-ai.md`), First Partner Unlock (`11-first-partner-unlock.md`), Effect System (`07-effect-system.md`), Upgrade Shop (`04-upgrade-shop.md`)

## Problem

Partners read `ItemManager.get_base_stat(&"paddle_speed")` as their speed ceiling: the unupgraded base from `GameRules.BASE_STATS`. As the player upgrades their own paddle through items, their capability pulls ahead of the partner's. Without a way to close this gap, the partner becomes the limiting factor in every streak, which frustrates the player (see `17-partner-ai.md`, principle 1).

Early partners (Martha) don't have this problem because they arrive when the player has few or no upgrades. Both sides struggle at similar speeds. The problem emerges in mid-to-late game when the player's paddle is significantly upgraded and new partners arrive at base stats.

## Design: stat sharing through court items

The player's upgrades lift the active partner through stat-sharing court items. These use the existing `share_stats_with_partner` outcome type from the effect system.

### Why stat sharing

Partner-specific upgrades ("Martha's speed +10%") create two problems:
- They don't transfer. Recruiting a new partner resets progress.
- They create a parallel progression track that competes with the player's own upgrades for FP without feeding into the same system.

Stat sharing solves both:
- Every player stat upgrade also upgrades the partner (once the sharing item is owned)
- New partners immediately benefit from existing sharing items
- The player's investment in their own stats is never wasted; it lifts every partner
- The progression feels like "we're getting better together" not "I'm training one specific partner"

This fits the game's narrative: these are people you're playing alongside. Getting better together is the relationship.

### How it works

Stat-sharing items are court items: purchased once, always active, no kit slot cost. They live in the shop rotation and are subject to existing discovery floor rules. They can be levelled at the Tinkerer like any other item.

When a stat-sharing court item is active, the partner's effective stat becomes a blend: base value plus a share of the player's upgrade delta. The share percentage scales with the court item's level.

The AI config's three knobs (`reaction_delay_frames`, `speed_scale`, `noise`) remain fixed per partner. What changes is the speed ceiling the partner operates within. A partner with `speed_scale = 0.70` and a shared paddle speed of 600 px/s moves at 420 px/s effective, up from 350 px/s at base. The AI algorithm is unchanged; the input values shift.

### What gets shared

The primary stat to share is `paddle_speed`, because it directly determines the partner's physical ceiling (which balls are reachable). Other stats could be shared in future (paddle size, reaction improvements) but speed is the one that matters most for the miss profile.

The `share_stats_with_partner` outcome type already exists and is used by Double Knot (level 3), which shares all player stat buffs with the partner. This is the late-game power spike. Stat-sharing court items provide the gradual ramp before that point.

### Progression stages

**Early game (Martha, no sharing items):**
The player has few upgrades. The partner is tuned to be reliable at base speeds (see `11-first-partner-unlock.md`, Martha's miss profile). No gap exists because the player hasn't outgrown the partner. Stat sharing isn't needed.

**Mid game (first sharing item available):**
The player has upgraded their paddle. A gap has opened between player capability and partner capability. The stat-sharing court item appears in the shop rotation. Purchasing it narrows the gap. Levelling it at the Tinkerer closes it further. The player feels the investment: the partner handles speeds they couldn't before.

**Late game (Double Knot level 3):**
Full stat sharing. The partner receives all player stat buffs. Both paddles operate at the same capability. The ball speed curve is the only ceiling.

### No partner becomes obsolete

Because sharing items apply to the active partner (not a specific partner), recruiting a new partner in a later phase doesn't reset progress. The new partner inherits the same shared stats from the moment they're recruited. Their personality comes from their AI config (different noise, reaction delay, speed scale) and their effects, not from a separate upgrade track.

### Court items need their own shop slot

If stat-sharing court items compete with gameplay items in the main rotation, the player might not see one for several cycles. The discovery floor is a safety net, not a reliable delivery mechanism. For something the player needs to keep their partner useful, "you'll see it eventually" isn't good enough.

Court items should draw from a dedicated pool with a reserved slot in the shop, the same pattern as the shopkeeper's pick (which draws from a separate narrative pool). One of the five shop slots always shows a court item the player doesn't own. When all court items are purchased, the slot joins the main rotation.

This guarantees:
- The player always has a court item available to buy (if any remain unpurchased)
- Court items don't crowd out gameplay items in the rotation
- Stat-sharing items are visible when the player needs them, not when rotation luck delivers them
- The player can choose to invest in court items at their own pace without feeling like they're missing out on gameplay items

Court items have no kit slot cost, so purchasing one doesn't compete with the player's loadout decisions. It's a pure investment in permanent progression.

## Delivery mechanism: Tinkerer prestige

Stat sharing is delivered as a permanent upgrade through the Tinkerer's prestige system (SH-81). The player brings their full item loadout to the Tinkerer, who clears it in exchange for a permanent upgrade. Stat sharing is one of the permanent upgrade options.

This means stat sharing is earned through a full cycle of play, not found in a shop rotation. The player has experienced the gap between their capability and the partner's, and they choose to close it. Court items reset with everything else; they are not the delivery mechanism for permanent upgrades.

See `designs/01-prototype/17-partner-ai.md` for the prestige research and design context.

## Design notes

**Stat sharing is additive, not replacement.** The partner's base stat + a share of the player's upgrade delta, not the player's full stat value. This preserves the partner's identity: a partner with `speed_scale = 0.70` is always slightly slower than the player, even with full sharing. The gap shrinks but never fully inverts.

**No partner becomes obsolete.** Because stat sharing applies to the active partner (not a specific partner), recruiting a new partner in a later phase doesn't reset progress. The new partner inherits the same shared stats. Their personality comes from their AI config and effects, not from a separate upgrade track.
