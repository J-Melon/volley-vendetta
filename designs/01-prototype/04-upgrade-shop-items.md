# Stat Modifiers and Prototype Items

Spike output for SH-40. Defines the item effect framework and 8 prototype items.

---

## Design principle

Items are gameplay-first. The effect is immediately perceptible - the player figures out what an item does by owning it, not by reading a description. Most items will be causality-driven; passive stat boosts are a subset of the same system.

The Tinkerer carries the narrative meaning of each item. The item itself just does its thing.

FP is Act 1's incentive currency. Act 2 (battle mode) and Act 3 (enemy mode) introduce different objectives, so items designed for those acts may target different incentives entirely. Act 1 prototype items are FP-focused, but the framework must not assume FP is always the reward worth designing around. Items that carry across acts should stay useful under different objective conditions.

---

## Item effect framework

Every item effect is: **trigger + condition + outcome**.

A passive stat modifier is a causality effect with trigger `always`. There is no separate system.

---

### Triggers

Only triggers used by owned items need to be implemented.

#### Active

| Trigger | Fires when |
|---|---|
| `always` | Passively, while the item is owned |
| `on_miss` | Ball contacts a miss wall |
| `on_personal_best` | Streak exceeds the player's personal best |

<details>
<summary>Ideas</summary>

| Trigger | Fires when |
|---|---|
| **Rally** | |
| `on_hit` | Any paddle hit registers |
| `on_streak_start` | First hit of a new rally, immediately after a miss |
| `on_streak_milestone(n)` | Streak reaches threshold n, once per rally |
| `on_streak_multiple(n)` | Every n-th hit repeatedly (at n, 2n, 3n...) |
| `on_streak_lost_above(n)` | Missed while streak was above n |
| `on_consecutive_misses(n)` | Player has missed n times in a row |
| `on_long_rally(seconds)` | Rally has been running for n seconds |
| **Ball** | |
| `on_max_speed_reached` | Ball hits the speed ceiling for the first time this rally |
| `on_hit_at_max_speed` | Hit registered while ball is already at max speed |
| `on_speed_maintained(seconds)` | Ball stays at max speed continuously for n seconds |
| `on_speed_tier(speed)` | Ball crosses a specific speed threshold |
| `on_speed_approaching_max(margin)` | Ball is within margin px/s of the ceiling |
| `on_speed_reset` | Ball speed resets to min after a miss |
| `on_wall_bounce` | Ball bounces off top or bottom wall |
| **Skill** | |
| `on_near_miss` | Ball passes within a small margin of the paddle edge without hitting |
| `on_perfect_center_hit` | Ball hits the center zone of the paddle |
| `on_edge_hit` | Ball hits the extreme edge of the paddle |
| **Session / time** | |
| `on_session_start` | Game opens |
| `on_return_after_idle` | Player returns after being away |
| `on_time_elapsed(seconds)` | Fires every n seconds while the game is running |
| **Economy** | |
| `on_item_purchased` | Any item bought from the shop |
| `on_item_destroyed` | Any item destroyed at the Tinkerer |
| `on_shop_refresh` | Shop rotation turns over |
| `on_fp_spent(amount)` | Cumulative FP spent crosses a threshold |
| `on_balance_threshold(amount)` | FP balance crosses a threshold (high or low) |
| **World (future)** | |
| `on_partner_rally_started` | Partner joins a rally |
| `on_ball_returned_by_partner` | Partner hits the ball back |
| `on_record_approached(margin)` | Personal best is within margin of the world record |
| **Meta** | |
| `on_item_synergy_active(item_id)` | A specific other item is also owned |
| `on_owned_item_count(n)` | Player owns exactly n items |

</details>

---

### Conditions

Optional. If omitted the outcome always fires when the trigger does. Multiple conditions on one effect are all required (AND logic). OR logic is handled by authoring multiple effects on one item.

#### Active

| Condition | Description |
|---|---|
| `game_state_is(state)` | A named item-driven game state is currently active |
| `game_state_is_not(state)` | A named item-driven game state is not currently active |

<details>
<summary>Ideas</summary>

| Condition | Description |
|---|---|
| **Streak** | |
| `streak_above(n)` | Current streak is greater than n |
| `streak_below(n)` | Current streak is less than n |
| **Ball state** | |
| `ball_at_max_speed` | Ball is currently at the speed ceiling |
| `ball_above_speed(n)` | Ball is above a specific speed threshold |
| `ball_below_speed(n)` | Ball is below a specific speed threshold |
| **Economy** | |
| `fp_above(n)` | Player has more than n FP |
| `fp_below(n)` | Player has less than n FP |
| **Ownership** | |
| `item_owned(id)` | A specific other item is owned |
| `item_at_level(id, level)` | A specific other item is at a given level |
| `items_owned_above(n)` | Player owns more than n items total |
| **Rate limiting** | |
| `cooldown(seconds)` | Outcome cannot fire again until cooldown expires |
| **Firing limits** | |
| `first_occurrence` | Fires only the first time ever, then never again |
| `once_per_session` | Fires once per session, resets on game open |
| `times_triggered_below(n)` | Fires at most n times total across all sessions |
| **Chance** | |
| `chance(percent)` | Fires with a given probability |

**Firing limit balance note:** items using `first_occurrence`, `once_per_session`, or `times_triggered_below` must have effects large enough to justify the purchase. `first_occurrence` should pair with permanent or long-lasting outcomes. `once_per_session` should set up the whole session. When in doubt, make the effect bigger.

</details>

---

### Outcomes

#### Active

| Outcome | Description | Parameters |
|---|---|---|
| `modify_stat` | Add a delta to a stat key. Permanent while owned | `key`, `delta` |
| `multiply_stat_temporary` | Multiply a stat key by a factor for a duration or until a state exits | `key`, `multiplier`, `duration_seconds` or `until_state_exits(state)` |
| `spawn_ball` | Add an additional ball to the game | none |
| `clear_extra_balls` | Remove all balls except the original | none |
| `set_game_state(state)` | Enter or exit a named item-driven game state. Null clears the state | `state: String` or null |

<details>
<summary>Ideas</summary>

| Outcome | Description | Parameters |
|---|---|---|
| **Stat modification** | | |
| `modify_stat_temporary` | Add a delta to a stat key for a duration | `key`, `delta`, `duration_seconds` |
| `modify_stat_until_miss` | Add a delta to a stat key until the next miss | `key`, `delta` |
| `modify_stat_until_hit(n)` | Add a delta to a stat key until n more hits register | `key`, `delta`, `hits` |
| `set_stat_temporary` | Override a stat key to a specific value for a duration | `key`, `value`, `duration_seconds` |
| **Ball control** | | |
| `set_ball_speed` | Immediately set ball to a specific speed | `value` |
| `boost_ball_speed` | One-off speed burst on top of current speed | `delta` |
| **FP economy** | | |
| `award_friendship_points` | Award a flat FP amount | `amount` |
| `award_friendship_points_per_streak` | Award FP equal to `streak * multiplier` | `multiplier` |
| `award_friendship_points_percentage_of_balance` | Award a percentage of the current FP balance | `percent` |
| `award_friendship_points_per_items_owned` | Award FP per item currently owned | `amount_per_item` |
| `award_friendship_points_on_session_end` | Bank FP to be paid out when the game closes | `amount` |
| `multiply_friendship_points_temporary` | All FP earnings are multiplied for a duration | `multiplier`, `duration_seconds` |
| `subtract_friendship_points` | Remove a flat FP amount | `amount` |
| `subtract_friendship_points_per_streak` | Remove FP proportional to streak length (cursed) | `multiplier` |
| **Streak manipulation** | | |
| `extend_streak_on_miss` | Streak does not reset on the next miss | none |
| `boost_streak` | Add n to the current streak count | `amount` |
| **Persistence** | | |
| `carry_streak_between_sessions` | Streak survives closing the game | none |

</details>

---

### Stat keys

All values items can target via `modify_stat` or `modify_stat_temporary`.

#### Active

| Key | Target | Base value | Unit |
|---|---|---|---|
| `paddle_speed` | Paddle movement speed | 500.0 | px/s |
| `paddle_size` | Paddle collision height | 50.0 | px |
| `ball_speed_min` | Ball starting/reset speed | 500.0 | px/s |
| `ball_speed_max_range` | Speed ceiling offset added to min | 600.0 | px/s |
| `ball_speed_increment` | Speed increase per paddle hit | 15.0 | px/s |
| `friendship_points_per_hit` | FP awarded per paddle hit | 1 | FP |

`ball_speed_max_range` is not the absolute ceiling. Ceiling = `ball_speed_min + ball_speed_max_range`. At base values: 1100 px/s.

<details>
<summary>Ideas</summary>

| Key | Target | Base value | Unit |
|---|---|---|---|
| `offline_friendship_points_rate` | FP per minute during idle/offline | 0 | FP/min |

`offline_friendship_points_rate` is 0 until idle play lands. Pre-defined so idle items need no framework changes later.

</details>

---

### Signals

Emitted by ItemManager for presentation layer consumers (HUD, entities, audio, VFX). Payloads contain only what downstream consumers need — current game state is queryable directly.

#### Active

| Signal | Payload | When |
|---|---|---|
| `game_state_entered(state, item_key)` | `state: String`, `item_key: String` | Named game state activated; drives frenzy fire VFX and equivalent |
| `game_state_exited(state, item_key)` | `state: String`, `item_key: String` | Named game state deactivated; drives explosion VFX and equivalent |
| `ball_spawned(item_key)` | `item_key: String` | Extra ball added to the game |
| `extra_balls_cleared(item_key)` | `item_key: String` | All extra balls removed |
| `item_buff_started(stat_key, duration, item_key)` | `stat_key: String`, `duration: float`, `item_key: String` | Temporary stat modification begins; entity starts visual state, duration drives countdown |
| `item_buff_expired(stat_key, item_key)` | `stat_key: String`, `item_key: String` | Temporary stat modification ends; entity stops visual state |

<details>
<summary>Ideas</summary>

| Signal | Payload | When |
|---|---|---|
| `friendship_points_burst(amount, item_key)` | `amount: int`, `item_key: String` | Causality item awards FP; HUD scales pop animation by amount |
| `streak_saved(item_key)` | `item_key: String` | `extend_streak_on_miss` fires; suppresses normal miss reaction |
| `fp_multiplier_changed(multiplier)` | `multiplier: float` | FP multiplier window starts or ends; HUD shows active state above 1.0, clears at 1.0 |
| `ball_speed_changed_by_item(item_key)` | `item_key: String` | Item directly sets ball speed; distinct from natural acceleration |

</details>

---

## Item categories

Every item belongs to one category. Category is authored per item, not player choice.

### Kit items

Default category. Equipping requires a kit slot. Causality effects and active stat modifiers only fire while equipped. Start with 3 kit slots; slots can be expanded by permanent items.

Swapping kit items is allowed at any time but costs FP and triggers a per-slot cooldown. Both the FP cost and cooldown duration are Make Fun Pass tuning targets. The combined cost means swapping is a real decision without being a hard lock.

### Locker items

Designed to sit in the locker. High passive FP generation, weak or no active effect. Their value is bench income. Never need a kit slot.

### Permanent items

Always-on. No slot cost. Authored as permanently active from the moment of purchase. Visually present in the background of the game space rather than in the kit UI.

Some permanent items expand kit slot count. These are early priority purchases — meta-progression that unlocks more active capacity.

Permanent items can be destroyed at the Tinkerer. Destroying them is the heaviest decision in the game and carries the heaviest Tinkerer dialogue.

---

## Locker and passive FP

All owned items generate FP passively while in the locker. Rate scales with item cost or level — investing in an item makes it a better bench earner even if it is never equipped. This gives every purchase value beyond its active effect and sustains the idle economy when the kit is locked in.

### Surface layer

Your gear earns FP just by being yours. You packed it, you own it, you care for it. A well-stocked locker is a kit that works for you even when you're not on the court. The bench contributes.

Passive FP is communicated through sound, not visuals. Late game the locker can be generating significant FP — visual pops would become noise. Instead: a gentle ambient audio texture that grows denser as the locker fills. Not louder, richer. Individual item ticks are near-subaudible. The overall feel is atmosphere, not UI events.

### Signal layer

The items are proxies for relationships. The FP from the locker is ambient warmth — the emotional residue of connection persisting through proximity and care. The player never needs to read this to understand the mechanic. It is for people paying attention.

The signal bleeds through in three places:

**Sound treatment.** Locker FP arrives differently from hit-earned FP. Hit FP pops. Locker FP glows. Different audio, different feeling. A player paying attention notices the game treats them differently without being told why.

**Partners.** Partners are who you are actually training with. They see your kit. They notice what you carry. Partner dialogue is where most of the locker signal layer lives — a partner noticing you still wear something, recognising something in your bag, remarking on how much you have accumulated after a long run together. Surface: they know your gear. Signal: they can see how much you have held onto and what it means. The Tinkerer and Shopkeeper carry their own weight elsewhere; the locker belongs to the partner relationships.

**The Shopkeeper, once.** Late Act 1, as the projection starts losing coherence, the Shopkeeper notices something in the locker. One line. Something like "I saw you kept that. You don't have to use it." Surface: friendly observation. Signal: the projection is aware of what the player is holding onto. After The Break the player looks back and understands what that line meant.

After The Break: the warmth from the locker was always real. It just was not the friend's warmth. It was the main character's memory of it, still generating something in the absence.

---

## Destruction and secret items

Any item can be destroyed at the Tinkerer. Destroying specific items unlocks secret items that cannot be obtained any other way. This is not signposted. The Tinkerer's destruction dialogue does not hint at it. Most players will never find these.

Secret items are for die-hards: players who destroy things out of curiosity, who pay close attention to what the Tinkerer says, who experiment beyond the obvious loop. The reward is the discovery itself.

Most item destructions do not unlock anything. The partial FP refund and the Tinkerer's dialogue are the only return. Secret unlocks are rare by design — one per specific item at most, and not every item has one.

Secret items entering the pool conditionally require the shop rotation system to support trigger-gated pool entries. See `04-upgrade-shop.md`.

---

## Items

Items are designed around a **thing + twist** formula. The thing is a physical object. The twist gives it character and hints at the gameplay without explaining it. The physical description is for art direction and may differ from the name and description text.

Descriptions are short — a fragment of thought from the main character's mind. No second person. Leave the narrative to the other characters.

Because descriptions are short they can change dynamically. Variant text is keyed to item state and swapped silently in the UI — no announcement, no tooltip. The player notices the text has shifted and understands why through play.

Every item has exactly 3 variants: default, item power revealed (triggers once the player has witnessed the effect), and narrative revealed (Post-Break for Act 1 items; tied to the relevant story beat for Act 2 and Act 3 items).

Item card format:
```
Category | Thing + twist | Physical description
Name
Descriptions (state → text)
Effects per level
Cost | Scaling
```

Items have 3 levels: base (purchased), upgraded, max.
Cost is the purchase price at level 1. Cost scaling formula: `cost = base_cost * scaling^current_level`.

---

### The Stray

Kit | Lost ball + gunpowder | Worn ball dusted lightly in gunpowder, slightly singed around the seams

| State | Description |
|---|---|
| Default | "Nobody trained it." |
| After frenzy triggers once | "Fast. Too fast." |
| Post-Break | "It was always going to do that." |

| Level | Extra balls (cap) | Frenzy trigger |
|---|---|---|
| 1 | 1 ball (cap 2) | On personal best |
| 2 | 2 balls (cap 3) | On personal best |
| 3 | 3 balls (cap 4) | On personal best or streak milestone (tuning target) |

```
Effect 1
  trigger: on_miss
  condition: game_state_is_not("frenzy")
  outcome: spawn_ball [capped per level]

Effect 2
  trigger: on_personal_best [levels 1-2] / on_personal_best or on_streak_milestone(n) [level 3]
  outcome: set_game_state("frenzy")
  outcome: multiply_stat_temporary(ball_speed_min, 2.0, until_state_exits("frenzy"))

Effect 3
  trigger: on_miss
  condition: game_state_is("frenzy")
  outcome: clear_extra_balls
  outcome: set_game_state(null)
```

Base cost: 60 FP | Scaling: 1.7

---

## Notes for SH-41 (Item system core)

- `friendship_points_per_hit` must be exposed as a query. Currently hardcoded as `1` in `game.gd:_on_paddle_hit()`.
- `ball_speed_increment` must be exposed as a query. Currently hardcoded as `GameRules.BALL_SPEED_INCREMENT` in `ball.gd:increase_speed()`.
- Causality items require ItemManager to subscribe to game signals and evaluate owned items on each trigger. Temporary outcomes need an expiry model (timer or per-frame tick).
- Named game states (for `set_game_state`, `game_state_is`) need a lightweight state registry in ItemManager or a dedicated GameStateManager.
- Multi-ball requires a ball spawner and a reference list of active balls in the scene. `clear_extra_balls` removes all but the original.
- `GameRules.BALL_SPEED_MIN` (400.0) and `GameRules.BALL_SPEED_MAX` (700.0) are unused. Remove in SH-41.
