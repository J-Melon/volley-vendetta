# Items, the Court, and the Kit

How items are organised, activated, and managed. Defines the court (active loadout on display in the world), the kit (at-rest storage on the court), authored item roles, ball behaviour, passive FP, and item destruction.

---

## One concept: items

All owned things are items. Every item has a physical place it belongs on the court, authored as its `role`. Placing an item on the court activates it; its effects register, and its visible form (if any) appears at its slot. Putting an item in the kit at-rests it; its effects stop and it begins generating passive FP instead.

This is the whole mechanic. No separate "kit" or "equipment" category, no counted slots, no type split between kit items and court items. One rule for all of them: on the court = active; in the kit = at rest.

---

## The court and the kit

The court is the physical world where items live when active. Items occupy authored places: some on the paddle, some as the ball, some at court-side spots (the bot dock, the jukebox stand, etc.), some as court surface treatments (court lines, markings). Each item knows where it goes; the player does not choose a slot, they choose which items come out.

The kit is the at-rest store. Any item not currently on the court lives in the kit room (see `08c`): a shared gear room at the player's end of the venue, always present, always accessible. Balls sit in a ball rack; paddle gear and small items are on the gear shelving; larger props occupy the floor space. The player goes there to pick up items and bring them to the court, or to put things back after pulling them off.

Moving an item from the kit room onto the court costs FP and triggers a per-role cooldown. Both values are Make Fun Pass tuning targets. The cost keeps the loadout a real decision; the cooldown prevents spam.

---

## Item roles

Each item declares the role it fills. Role names (authored per item):

| Role | Holds | Capacity |
|---|---|---|
| `paddle_handle` | Grip wraps (Grip Tape, Double Knot) | One wrap at a time |
| `paddle_head` | Head-affixed items | Small capacity |
| `paddle_body` | Hanging weights, charms, attached objects | Small capacity |
| `paddle_intrinsic` | Paddle upgrades with no prop (speed, size, reach) | Stacks on the paddle invisibly |
| `ball` | Ball items (Training Ball, The Stray) | Each item here spawns a ball |
| `ball_intrinsic` | Ball upgrades with no prop (start speed, bounce) | Stacks invisibly |
| `court_surface` | Markings, lines, floor treatments | Stackable |
| `court_side` | Standing props (bot dock, jukebox, Spare) | Authored positions; real-estate-limited |

Physical slots show a visible prop on the court when their item is active. Intrinsic slots register effects without spawning a prop; the paddle simply is faster, larger, or more precise.

Each role has capacity authored into it. Exclusive roles (like `paddle_handle`) hold one item; bringing a new one out swaps the previous back to the kit. Additive roles (like `ball`) accept any count and each item adds its presence to the court.

---

## Balls and the court

Ball items sit in the `ball` role. Each one adds a ball to the court: Training Ball alone puts one ball out; Training Ball plus The Stray put two out; three ball items put three out. Taking a ball item back to the kit removes that ball from the court.

Item effects that spawn additional balls (e.g. The Stray's frenzy outcome) create **temporary** balls on top of the permanent ones. Temporary balls are cleared by their expiry condition (miss during frenzy, etc.). The permanent balls remain throughout.

Example: Training Ball and The Stray both on the court = two balls at all times. Frenzy triggers on personal best, spawning additional temporary balls. Miss during frenzy clears the temps; the two permanents stay.

---

## Kit passive FP

All owned items generate FP passively while in the kit. Rate scales with item cost and level. Investing in an item makes it a better at-rest earner even if it never comes onto the court. Every purchase has value beyond its active effect, and the economy sustains itself when the loadout is locked in.

### Surface layer

Your gear earns FP just by being yours. You packed it, you own it, you care for it. A well-stocked kit is a loadout that works for you even when it is at rest. The bench contributes.

Passive FP is communicated through sound, not visuals. Late game the kit can generate significant FP; visual pops would become noise. Instead: a gentle ambient audio texture that grows denser as the kit fills. Not louder, richer. Individual item ticks are near-subaudible. The overall feel is atmosphere rather than UI events.

### Signal layer

The items are proxies for relationships. The FP from the kit is ambient warmth: the emotional residue of connection persisting through proximity and care. The player never needs to read this to understand the mechanic. It is for those paying attention.

The signal bleeds through in three places:

**Sound treatment.** Kit FP arrives differently from hit-earned FP. Hit FP pops. Kit FP glows. Different audio, different feeling. A player paying attention notices the game treats the two differently without being told why.

**Partners.** Partners are who the player is actually training with. They see the loadout. They notice what the player carries. Partner dialogue is where most of the kit signal layer lives: a partner recognising something in the kit, remarking on how much has accumulated over a long run together. Surface: they know your gear. Signal: they can see how much has been held onto and what it means. The Tinkerer and the friend carry their own weight elsewhere; the kit belongs to the partner relationships.

**The friend, once.** Late in pre-break, as the projection begins to lose coherence, the friend notices something in the kit. One line. "I saw you kept that. You don't have to use it." Surface: a friendly observation. Signal: the projection sees what the player is holding onto. After the break the player looks back and understands.

After The Break: the warmth from the kit was always real. It was the main character's memory of it, still generating something in the absence.

---

## Destruction and secret items

Any item can be destroyed at the Tinkerer. Destroying specific items unlocks secret items that cannot be obtained any other way. This is unsignposted. The Tinkerer's destruction dialogue holds its tongue. Most players will never find these.

Secret items are for die-hards: players who destroy things out of curiosity, who pay close attention to what the Tinkerer says, who experiment beyond the obvious loop. The reward is the discovery.

Most item destructions unlock nothing beyond the partial FP refund and the Tinkerer's dialogue. Secret unlocks are rare by design: one per specific item at most, and not every item has one.

Secret items entering the pool conditionally require the shop rotation system to support trigger-gated pool entries. See `04-upgrade-shop.md`.
