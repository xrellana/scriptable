# Plater interrupt alert mod

Recolors and enlarges enemy cast bars for listed spells, and draws a green
border around the cast bar while your own interrupt is off cooldown.

- Danger spells: red when interruptible, purple when not, bar enlarged.
- Normal spells: yellow when interruptible, purple when not.
- Unlisted spells: left exactly as Plater draws them.

## Files

Each file is the body of one Plater Mod hook.

| File | Plater hook | Purpose |
| --- | --- | --- |
| `Initialization.lua` | Initialization | Settings, spell lists, interrupt detection, cooldown tracking, event frame; shared by all nameplates |
| `Constructor.lua` | Constructor | Creates the (hidden) kick border on each nameplate |
| `Cast_Start.lua` | Cast Start | Classifies the spell, applies color, size and border |
| `Cast_Update.lua` | Cast Update | Recolors when interruptibility flips, refreshes the border |
| `Cast_Stop.lua` | Cast Stop | Restores Plater's color and size, hides the border |
| `Nameplate_Removed.lua` | Nameplate Removed | Same restore when a plate is recycled mid-cast |

## Installation

1. `/plater` -> Modding, select the mod (or create a new one).
2. Make sure all six hooks above exist. Initialization and Nameplate Removed
   were added in this version and must be added by hand.
3. Replace each hook's entire body with the matching file. The old
   Constructor held the spell tables; do not keep them there.
4. Save, then `/reload`. Constructor runs once per nameplate, so existing
   plates keep stale state until a reload.
5. Turn on error reporting: `/console scriptErrors 1`, or install
   BugSack + BugGrabber.

## Settings

All at the top of `Initialization.lua`.

| Setting | Default | Meaning |
| --- | --- | --- |
| `WIDTH_SCALE` | 1.20 | Width multiplier for danger spells |
| `HEIGHT_SCALE` | 1.50 | Height multiplier for danger spells |
| `INTERRUPT_OVERRIDE` | nil | Force an interrupt spell ID when auto-detection is wrong, e.g. 57994 |
| `COLOR_DANGER` | 1.00, 0.08, 0.08 (red) | Danger spell, interruptible |
| `COLOR_NORMAL` | 1.00, 0.82, 0.08 (yellow) | Normal spell, interruptible |
| `COLOR_LOCKED` | 0.72, 0.16, 0.95 (purple) | Not interruptible |
| `DEFAULT_COOLDOWN` | 15 s | Interrupt cooldown used when it can be neither read nor looked up |

To add a spell, add `[spellID] = true` to `DangerSpells`, `NormalSpells` or
`MechanicSpells`. `MechanicSpells` behaves exactly like `DangerSpells`; it is
a separate table only for bookkeeping.

## Expected behavior

| Spell list | Interruptible | Not interruptible | Bar size |
| --- | --- | --- | --- |
| `DangerSpells` / `MechanicSpells` | Red | Purple | Width x1.2, height x1.5 |
| `NormalSpells` | Yellow | Purple | Unchanged |
| Not listed | Plater default | Plater default | Unchanged |

The green kick border (3 px) shows only when all three hold:

- the spell is in one of the lists above,
- the cast is currently interruptible,
- your interrupt is off cooldown (within 0.1 s counts as ready).

The border ignores range and facing. Using your interrupt hides every border
immediately; they come back when the cooldown ends. When a cast ends, is
interrupted, or the unit dies or leaves view, the bar returns to Plater's
default and the border hides.

Interrupt auto-detection takes the first known spell in this order:

| Class | Spells |
| --- | --- |
| Warrior | Pummel 6552 |
| Paladin | Rebuke 96231 |
| Hunter | Counter Shot 147362, Muzzle 187707 |
| Rogue | Kick 1766 |
| Priest | Silence 15487 (Shadow only) |
| Death Knight | Mind Freeze 47528 |
| Shaman | Wind Shear 57994 |
| Mage | Counterspell 2139 |
| Warlock | Spell Lock 119910, 132409, 19647 |
| Monk | Spear Hand Strike 116705 |
| Druid | Skull Bash 106839, Solar Beam 78675 |
| Demon Hunter | Disrupt 183752 |
| Evoker | Quell 351338 |

Specs without an interrupt (e.g. Holy/Discipline Priest) never show the border.

## In-game test checklist

Secret values only appear in combat, so colors and the border must be tested
in real fights. To test mechanics without entering a dungeon, find an
open-world mob that casts, look up the spell ID (e.g. with idTip), add it to
`DangerSpells` or `NormalSpells` temporarily, and remove it afterwards.

### Loading

- [ ] No errors after `/reload`
- [ ] No errors after editing and saving the mod (reruns Initialization)

### Color and size (in combat)

- [ ] Danger spell, interruptible: red, bar clearly larger
- [ ] Danger spell, not interruptible: purple, bar larger
- [ ] Normal spell, interruptible: yellow, size unchanged
- [ ] Unlisted spell: identical to the mod being disabled
- [ ] Color is not reverted to Plater's default partway through a cast
- [ ] (When it happens) a cast that becomes uninterruptible mid-cast turns purple

### Kick border (in combat)

- [ ] With interrupt ready, interruptible listed casts have the green border
- [ ] Uninterruptible casts have no border
- [ ] Using your interrupt hides all borders at once
- [ ] Border returns when the cooldown ends; note how many seconds early or
      late it is compared to the action bar
- [ ] Warlock: test with a Felhunter out and with Grimoire of Sacrifice
- [ ] Druid: border works as Balance
- [ ] After changing spec or talents, border still works without `/reload`

### Restore

- [ ] After a cast ends or is interrupted, color and size return to normal
- [ ] Killing a mob mid danger-cast leaves no enlarged or recolored bar on
      other plates afterwards
- [ ] A listed cast followed by an unlisted cast on the same mob: the second
      one looks like Plater's default

### Performance

- [ ] Large pulls (10+ simultaneous casts): frame rate close to the mod being
      disabled

## Known risks and troubleshooting

The code assumes enemy spell IDs are plain values, while the interruptible
flag (`self.CanInterrupt`) and spell cooldowns can be secret in combat.
Secret values are never tested or compared; they are only passed to APIs
that accept them.

| Symptom | Likely cause | What to report |
| --- | --- | --- |
| In combat, bars are only ever red/yellow, never purple | `C_CurveUtil.EvaluateColorValueFromBoolean` does not exist under that name; the mod falls back to priority colors | Whether purple ever appears in combat vs out of combat |
| Border shows on uninterruptible casts in combat | `SetAlphaFromBoolean` and the `C_CurveUtil` fallback are both missing, so the border is always shown | Same as above |
| Error mentioning "secret" in `Cast_Start.lua` at the spell table lookup | Enemy spell IDs are secret after all | Full error text |
| Error mentioning "secret" inside `Plater.SetCastBarColor` or `SetCastBarSize` | Plater cannot take a value we pass it | Full error text and stack |
| Out of combat, listed spells are always purple and never have a border | `self.CanInterrupt` is not set by this Plater version | Plater version |
| Color flips back to Plater's default mid-cast | Plater recolors on its own; the mod only reapplies on interruptibility changes | When during the cast it happens |
| Border comes back noticeably late | Cooldown is secret, and the fallback uses the base (untalented) cooldown | Class, spec, talent that shortens the interrupt, seconds late |
| Border never shows for your class | Interrupt not detected; try `INTERRUPT_OVERRIDE` | Class, spec, whether override fixes it |

Notes on the cooldown fallback: when the cooldown can be read (usually out of
combat), its real duration is remembered and used later. Otherwise the mod
records when you last cast the interrupt (`UNIT_SPELLCAST_SUCCEEDED` for
player and pet) and adds the base cooldown. Effects that shorten the cooldown
after a successful interrupt are not tracked.

Initialization creates a global frame named `PlaterKickAlertEventFrame` and
reuses it on every rerun.

## Feedback template

```
Client version / Plater version:
Class / spec / key talents:
Where tested (dungeon, open world, dummy):

Checklist items that failed:
- <item>: what happened instead

Errors (full text from BugSack or the error frame):

Border timing offset vs action bar (seconds early/late):
```
