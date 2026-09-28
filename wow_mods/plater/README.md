# Plater interrupt alert mod

Recolors enemy cast bars for listed spells, enlarges the whole nameplate for
dangerous ones, and runs a green pixel glow around the cast bar while your own
interrupt is off cooldown.

- Danger spells: red when interruptible, purple when not, whole nameplate enlarged.
- Normal spells: yellow when interruptible, purple when not.
- Unlisted spells: left exactly as Plater draws them.

## Files

Each file is the body of one Plater Mod hook.

| File | Plater hook | Purpose |
| --- | --- | --- |
| `Initialization.lua` | Initialization | Settings, spell lists, interrupt detection, cooldown tracking, event frame; shared by all nameplates |
| `Constructor.lua` | Constructor | Creates the hidden container frame for the kick glow on each nameplate |
| `Cast_Start.lua` | Cast Start | Classifies the spell, applies color and size, starts the kick glow |
| `Cast_Update.lua` | Cast Update | Repaints the bar every update, shows or hides the kick glow |
| `Cast_Stop.lua` | Cast Stop | Restores Plater's color and size, stops the kick glow |
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
| `DANGER_PLATE_SCALE` | 1.25 | Scale of the whole nameplate (health bar, name, cast bar, auras) during a danger spell, multiplied onto any scale already set |
| `DEBUG` | false | Print one chat line per listed cast (spell ID, priority, plate scale before and after) and per skipped secret spell ID |
| `INTERRUPT_OVERRIDE` | nil | Force an interrupt spell ID when auto-detection is wrong, e.g. 57994 |
| `COLOR_DANGER` | 1.00, 0.08, 0.08 (red) | Danger spell, interruptible |
| `COLOR_NORMAL` | 1.00, 0.82, 0.08 (yellow) | Normal spell, interruptible |
| `COLOR_LOCKED` | 0.72, 0.16, 0.95 (purple) | Not interruptible |
| `KICK_GLOW.color` | 0.10, 1.00, 0.20, 1 (green) | Glow line color |
| `KICK_GLOW.lines` | 8 | Number of glow lines |
| `KICK_GLOW.frequency` | 0.4 | Laps per second; negative reverses direction |
| `KICK_GLOW.thickness` | 2 | Line thickness in pixels |
| `KICK_GLOW.offset` | 2 | Pixels outside the cast bar edge |
| `DEFAULT_COOLDOWN` | 15 s | Interrupt cooldown used when it can be neither read nor looked up |

To add a spell, add `[spellID] = true` to `DangerSpells`, `NormalSpells` or
`MechanicSpells`. `MechanicSpells` behaves exactly like `DangerSpells`; it is
a separate table only for bookkeeping.

## Expected behavior

| Spell list | Interruptible | Not interruptible | Nameplate size |
| --- | --- | --- | --- |
| `DangerSpells` / `MechanicSpells` | Red | Purple | Whole nameplate x1.25 |
| `NormalSpells` | Yellow | Purple | Unchanged |
| Not listed | Plater default | Plater default | Unchanged |

The kick glow (green lines running around the cast bar, via
`Plater.StartPixelGlow`) shows only when all three hold:

- the spell is in one of the lists above,
- the cast is currently interruptible,
- your interrupt is off cooldown (within 0.1 s counts as ready).

The glow ignores range and facing. Using your interrupt hides every glow
immediately; they come back when the cooldown ends. When a cast ends, is
interrupted, or the unit dies or leaves view, the bar returns to Plater's
default and the glow stops.

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

Specs without an interrupt (e.g. Holy/Discipline Priest) never show the glow.

## In-game test checklist

Secret values only appear in combat, so colors and the glow must be tested
in real fights. To test mechanics without entering a dungeon, find an
open-world mob that casts, look up the spell ID (e.g. with idTip), add it to
`DangerSpells` or `NormalSpells` temporarily, and remove it afterwards.

### Loading

- [ ] No errors after `/reload`
- [ ] No errors after editing and saving the mod (reruns Initialization)

### Color and size (in combat)

- [ ] Danger spell, interruptible: red, whole nameplate larger and still in proportion
- [ ] Danger spell, not interruptible: purple, whole nameplate larger
- [ ] Normal spell, interruptible: yellow, size unchanged
- [ ] Unlisted spell: identical to the mod being disabled
- [ ] Color is not reverted to Plater's default partway through a cast
- [ ] (When it happens) a cast that becomes uninterruptible mid-cast turns purple

### Kick glow (in combat)

- [ ] With interrupt ready, interruptible listed casts have green lines
      running around the bar
- [ ] On an enlarged danger nameplate the lines follow the larger cast bar
- [ ] Uninterruptible casts have no glow
- [ ] Using your interrupt stops all glows at once
- [ ] Glow returns when the cooldown ends; note how many seconds early or
      late it is compared to the action bar
- [ ] Warlock: test with a Felhunter out and with Grimoire of Sacrifice
- [ ] Druid: glow works as Balance
- [ ] After changing spec or talents, glow still works without `/reload`
- [ ] Glow speed, thickness and color feel right (tune `KICK_GLOW`)

### Restore

- [ ] After a cast ends or is interrupted, color and size return to normal
- [ ] With a minor-units scaling mod: a small mob's plate returns to its
      reduced size (not 1.0) after a danger cast
- [ ] Killing a mob mid danger-cast leaves no enlarged or recolored plate on
      other plates afterwards
- [ ] A listed cast followed by an unlisted cast on the same mob: the second
      one looks like Plater's default

### Performance

- [ ] Large pulls (10+ simultaneous casts): frame rate close to the mod being
      disabled

## Known risks and troubleshooting

The interruptible flag (`self.notInterruptible`), enemy spell IDs and spell
cooldowns can all be secret in combat. Secret values are never tested or
compared; they are only passed to APIs that accept them.

Checked against the Plater source (commit `36c2ee7`, 2026-09-27):

- On Midnight clients Plater always sets `castBar.CanInterrupt = nil`, so the
  mod reads the raw `castBar.notInterruptible` instead.
- Plater guards its own per-spell cast colors with
  `issecretvalue(self.spellID)`, so spell IDs can be secret. When one is, the
  mod leaves that cast untouched, as Plater does.
- `C_CurveUtil.EvaluateColorValueFromBoolean` and `SetAlphaFromBoolean` exist
  and are used by Plater itself.

| Symptom | Likely cause | What to report |
| --- | --- | --- |
| Listed spells sometimes look like Plater's default in combat | The spell ID was secret for that cast, so it could not be looked up | Which spell, in which dungeon, how often |
| Error mentioning "secret" inside `Plater.SetCastBarColor` or `SetNameplateScale` | Plater cannot take a value we pass it | Full error text and stack |
| Colors are right out of combat but wrong in combat | Writing a secret color to the bar texture does not stick | What color shows instead |
| Bar shows yellow / orange / dull red instead of red / yellow / purple | Another mod paints the same bar every update; with Jundies' profile this is "Enhanced Castbar - Jundies - Midnight" | Turn off that mod's `showInterruptColor` option (its interrupt tick keeps working), or give this mod a lower Priority than it so this one paints last |
| Nameplate does not grow on danger spells | Unknown yet; turn on `DEBUG` and watch one danger spell being cast | The chat line: whether it printed at all, "secret spell ID", or the two scale numbers |
| Enlarged nameplate overlaps its neighbors | Nameplate stacking uses the unscaled plate size | Whether it hurts readability; lower `DANGER_PLATE_SCALE` |
| Only part of the nameplate grows, or parts drift apart | `SetNameplateScale` takes a different path when Plater's "Use UIParent" option is on | Whether that option is on, a screenshot |
| Nameplate stays enlarged after the cast | Restore did not run for that cast | What happened to the mob (killed, CC'd, out of range) |
| Glow comes back noticeably late | Cooldown is secret, and the fallback uses the base (untalented) cooldown | Class, spec, talent that shortens the interrupt, seconds late |
| Glow never shows for your class | Interrupt not detected; try `INTERRUPT_OVERRIDE` | Class, spec, whether override fixes it |

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

Glow timing offset vs action bar (seconds early/late):
```
