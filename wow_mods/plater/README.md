# Plater interrupt alert mod

Runs a green pixel glow around the cast bar of listed dangerous casts while
the cast is interruptible and your own interrupt is off cooldown.

The mod does nothing else: cast bar colors, nameplate size and every
unlisted cast are left to Plater and other mods (e.g. Jundies' Enhanced
Castbar, which colors the bar by interrupt state).

## Files

Each file is the body of one Plater Mod hook.

| File | Plater hook | Purpose |
| --- | --- | --- |
| `Initialization.lua` | Initialization | Settings, spell list, interrupt detection, cooldown tracking, event frame; shared by all nameplates |
| `Constructor.lua` | Constructor | Creates the hidden container frame for the glow on each nameplate |
| `Cast_Start.lua` | Cast Start | Checks the spell against the list and starts the glow |
| `Cast_Update.lua` | Cast Update | Shows or hides the glow as interruptibility and your cooldown change |
| `Cast_Stop.lua` | Cast Stop | Stops the glow |
| `Nameplate_Removed.lua` | Nameplate Removed | Same when a plate is recycled mid-cast |

## Installation

1. `/plater` -> Modding, select the mod (or create a new one).
2. Make sure all six hooks above exist.
3. Replace each hook's entire body with the matching file.
4. Save, then `/reload`. Constructor runs once per nameplate, so existing
   plates keep stale state until a reload.
5. Turn on error reporting: `/console scriptErrors 1`, or install
   BugSack + BugGrabber.

## Settings

All at the top of `Initialization.lua`.

| Setting | Default | Meaning |
| --- | --- | --- |
| `INTERRUPT_OVERRIDE` | nil | Force an interrupt spell ID when auto-detection is wrong, e.g. 57994 |
| `KICK_GLOW.color` | 0.10, 1.00, 0.20, 1 (green) | Glow line color |
| `KICK_GLOW.lines` | 8 | Number of glow lines |
| `KICK_GLOW.frequency` | 0.4 | Laps per second; negative reverses direction |
| `KICK_GLOW.thickness` | 2 | Line thickness in pixels |
| `KICK_GLOW.offset` | 2 | Pixels outside the cast bar edge |
| `DEFAULT_COOLDOWN` | 15 s | Interrupt cooldown used when it can be neither read nor looked up |

To add a spell, add `[spellID] = true` to `DangerSpells`.

## Expected behavior

The glow (green lines running around the cast bar, via
`Plater.StartPixelGlow`) shows only when all three hold:

- the spell is in `DangerSpells`,
- the cast is currently interruptible,
- your interrupt is off cooldown (within 0.1 s counts as ready).

The glow ignores range and facing. Using your interrupt hides every glow
immediately; they come back when the cooldown ends. When a cast ends, is
interrupted, or the unit dies or leaves view, the glow stops.

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

Secret values only appear in combat, so the glow must be tested in real
fights. To test without entering a dungeon, find an open-world mob that
casts, look up the spell ID (e.g. with idTip), add it to `DangerSpells`
temporarily, and remove it afterwards.

### Loading

- [ ] No errors after `/reload`
- [ ] No errors after editing and saving the mod (reruns Initialization)

### Glow (in combat)

- [ ] With interrupt ready, interruptible listed casts have green lines
      running around the bar
- [ ] Uninterruptible casts have no glow
- [ ] Unlisted casts have no glow
- [ ] Using your interrupt stops all glows at once
- [ ] Glow returns when the cooldown ends; note how many seconds early or
      late it is compared to the action bar
- [ ] Warlock: test with a Felhunter out and with Grimoire of Sacrifice
- [ ] Druid: glow works as Balance
- [ ] After changing spec or talents, glow still works without `/reload`
- [ ] Glow speed, thickness and color feel right (tune `KICK_GLOW`)

### Stop

- [ ] Glow stops when the cast ends or is interrupted
- [ ] Killing a mob mid-cast leaves no glow on the plate afterwards
- [ ] A listed cast followed by an unlisted cast on the same mob: the second
      one has no glow

### Performance

- [ ] Large pulls (10+ simultaneous casts): frame rate close to the mod being
      disabled

## Known risks and troubleshooting

The interruptible flag (`self.notInterruptible`), enemy spell IDs and spell
cooldowns can all be secret in combat. Secret values are never tested or
compared; they are only passed to APIs that accept them.

Checked against the Plater source (v656):

- On Midnight clients Plater always sets `castBar.CanInterrupt = nil`, so the
  mod reads the raw `castBar.notInterruptible` instead.
- Plater guards its own per-spell cast colors with
  `issecretvalue(self.spellID)`, so spell IDs can be secret. When one is, the
  mod skips that cast, as Plater does.
- `SetAlphaFromBoolean` and `C_CurveUtil.EvaluateColorValueFromBoolean`
  exist and are used by Plater itself.

| Symptom | Likely cause | What to report |
| --- | --- | --- |
| A listed spell sometimes has no glow in combat | The spell ID was secret for that cast, so it could not be looked up | Which spell, in which dungeon, how often |
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
