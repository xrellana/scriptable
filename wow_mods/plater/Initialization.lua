function (modTable)

    ----------------------------------------------------------------
    -- SETTINGS
    ----------------------------------------------------------------

    modTable.WIDTH_SCALE  = 1.20
    modTable.HEIGHT_SCALE = 1.50

    -- Set this when auto-detection picks the wrong interrupt,
    -- e.g. 57994 for Wind Shear. nil = auto-detect.
    modTable.INTERRUPT_OVERRIDE = nil

    modTable.COLOR_DANGER = { 1.00, 0.08, 0.08 } -- high priority, interruptible
    modTable.COLOR_NORMAL = { 1.00, 0.82, 0.08 } -- low priority, interruptible
    modTable.COLOR_LOCKED = { 0.72, 0.16, 0.95 } -- not interruptible

    -- A cooldown this close to ending already counts as ready.
    local READY_TOLERANCE = 0.10

    -- Cooldowns this short are the GCD, not the interrupt's own cooldown.
    local GCD_MAX = 1.5

    -- Used when the real cooldown can be neither read nor looked up.
    local DEFAULT_COOLDOWN = 15


    ----------------------------------------------------------------
    -- DANGEROUS INTERRUPTS
    -- High priority: red when interruptible, purple when not,
    -- and the cast bar is enlarged.
    ----------------------------------------------------------------

    modTable.DangerSpells = {

        ------------------------------------------------------------
        -- Altar of Fangs
        ------------------------------------------------------------
        [1294557] = true, -- Piercing Hiss
        [1310358] = true, -- Toxic Atrophy
        [1307567] = true, -- Mass Envenom

        ------------------------------------------------------------
        -- Den of Nalorakk
        ------------------------------------------------------------
        [1297696] = true, -- Healing Breeze
        [1309919] = true, -- Frigid Roar
        [1297778] = true, -- Arc Lightning

        ------------------------------------------------------------
        -- Murder Row
        ------------------------------------------------------------
        [1264106] = true, -- Felstorm
        [1214922] = true, -- Fel Rage
        [1214980] = true, -- Health Funnel
        [474375]  = true, -- Chaos Bolt

        ------------------------------------------------------------
        -- The Blinding Vale
        ------------------------------------------------------------
        [1301834] = true, -- Light Bolt Volley
        [1238294] = true, -- Disorienting Screech
        [1239821] = true, -- Warden's Wrath
        [1247669] = true, -- Lightspore Shot

        ------------------------------------------------------------
        -- Voidscar Arena
        ------------------------------------------------------------
        [1298899] = true, -- Demoralizing Shout
        [1299938] = true, -- Shadowbolt Volley
        [1249621] = true, -- Violent Sand
        [1233398] = true, -- Mad Shriek
        [1310324] = true, -- Mending Void

        ------------------------------------------------------------
        -- Ruby Life Pools
        ------------------------------------------------------------
        [372743]  = true, -- Ice Shield
        [372808]  = true, -- Frigid Shard
        [373017]  = true, -- Blaze Volley

        ------------------------------------------------------------
        -- Temple of Sethraliss
        ------------------------------------------------------------
        [1303535] = true, -- Essence Disruption

        ------------------------------------------------------------
        -- King's Rest
        ------------------------------------------------------------
        [269972]  = true, -- Hex Volley
        [270920]  = true, -- Bind Soul
        [270901]  = true, -- Unholy Mending
        [267763]  = true, -- Wretched Discharge
        [267273]  = true, -- Poison Nova
        [269369]  = true, -- Deathly Roar
    }


    ----------------------------------------------------------------
    -- NORMAL INTERRUPTS
    -- Worth kicking but lower priority: yellow.
    ----------------------------------------------------------------

    modTable.NormalSpells = {

        -- Den of Nalorakk
        [1239352] = true, -- Scavenge

        -- Murder Row
        [1216570] = true, -- Fel Missiles
        [1201554] = true, -- Seduction

        -- The Blinding Vale
        [1235616] = true, -- Light Bolt

        -- Ruby Life Pools
        [1305955] = true, -- Fiery Blast

        -- Temple of Sethraliss
        [1308100] = true, -- Poisoned Cheap Shot
        [1314082] = true, -- Addle Mind
        [267027]  = true, -- Poison Spit
        [268013]  = true, -- Flame Shock

        -- King's Rest
        [270492]  = true, -- Hex
    }


    ----------------------------------------------------------------
    -- DANGEROUS MECHANICS
    -- Usually not answered by a plain kick, but still worth a big
    -- warning. Treated like danger spells, so the color still
    -- follows CanInterrupt: red if interruptible, purple if not.
    ----------------------------------------------------------------

    modTable.MechanicSpells = {

        ------------------------------------------------------------
        -- Altar of Fangs
        ------------------------------------------------------------
        [1307894] = true, -- Ravenous Stomp
        [1299053] = true, -- Death Rattle

        ------------------------------------------------------------
        -- Den of Nalorakk
        ------------------------------------------------------------
        [1234681] = true, -- Ravenous Bellow
        [1235656] = true, -- Frozen Tempest
        [1297792] = true, -- Overwhelming Onslaught

        ------------------------------------------------------------
        -- Murder Row
        ------------------------------------------------------------
        [474478]  = true, -- Killing Spree
        [1218347] = true, -- Murder in a Row
        [1217384] = true, -- Malefic Wave

        ------------------------------------------------------------
        -- The Blinding Vale
        ------------------------------------------------------------
        [1261011] = true, -- Fan of Thorns
        [1236746] = true, -- Verdant Stomp
        [1240210] = true, -- Pulverizing Strikes
        [1246607] = true, -- Concentrated Lightbeam

        ------------------------------------------------------------
        -- Voidscar Arena
        ------------------------------------------------------------
        [1300259] = true, -- Dark Bloom
        [1262497] = true, -- Monstrous Roar
        [1227197] = true, -- Cosmic Crash

        ------------------------------------------------------------
        -- Ruby Life Pools
        ------------------------------------------------------------
        [372851]  = true, -- Chillstorm
        [372107]  = true, -- Molten Boulder
        [381516]  = true, -- Interrupting Cloudburst

        ------------------------------------------------------------
        -- Temple of Sethraliss
        ------------------------------------------------------------
        [1288864] = true, -- Tempest Winds
        [1290531] = true, -- Induction

        ------------------------------------------------------------
        -- King's Rest
        ------------------------------------------------------------
        [1311987] = true, -- Serpentine Gust
        [267618]  = true, -- Drain Fluids
        [268586]  = true, -- Blade Combo
        [1303327] = true, -- Quaking Leap
    }


    ----------------------------------------------------------------
    -- INTERRUPT SPELLS
    -- Checked in order; the first known spell wins.
    ----------------------------------------------------------------

    modTable.InterruptSpells = {

        WARRIOR = {
            6552,       -- Pummel
        },

        PALADIN = {
            96231,      -- Rebuke
        },

        HUNTER = {
            147362,     -- Counter Shot
            187707,     -- Muzzle
        },

        ROGUE = {
            1766,       -- Kick
        },

        PRIEST = {
            15487,      -- Silence
        },

        DEATHKNIGHT = {
            47528,      -- Mind Freeze
        },

        SHAMAN = {
            57994,      -- Wind Shear
        },

        MAGE = {
            2139,       -- Counterspell
        },

        WARLOCK = {
            119910,     -- Command Demon: Spell Lock (Felhunter out)
            132409,     -- Spell Lock (Grimoire of Sacrifice)
            19647,      -- Spell Lock (Felhunter pet spell)
        },

        MONK = {
            116705,     -- Spear Hand Strike
        },

        DRUID = {
            106839,     -- Skull Bash
            78675,      -- Solar Beam
        },

        DEMONHUNTER = {
            183752,     -- Disrupt
        },

        EVOKER = {
            351338,     -- Quell
        },
    }

    modTable.InterruptSpellSet = {}

    for _, spells in pairs(modTable.InterruptSpells) do
        for _, spellID in ipairs(spells) do
            modTable.InterruptSpellSet[spellID] = true
        end
    end


    ----------------------------------------------------------------
    -- HELPER: secret values
    -- In combat, CanInterrupt and spell cooldowns can be secret.
    -- A secret value must never be tested, compared or used in
    -- arithmetic; it can only be handed to APIs that accept it.
    ----------------------------------------------------------------

    local issecretvalue = issecretvalue

    modTable.IsSecret = function(value)
        return issecretvalue ~= nil and issecretvalue(value) == true
    end


    ----------------------------------------------------------------
    -- HELPER: is spell known
    ----------------------------------------------------------------

    local function IsKnownSpell(spellID)

        if IsPlayerSpell and IsPlayerSpell(spellID) then
            return true
        end

        -- The second argument checks the pet spellbook (Spell Lock)
        if IsSpellKnownOrOverridesKnown and
           (IsSpellKnownOrOverridesKnown(spellID) or
            IsSpellKnownOrOverridesKnown(spellID, true)) then
            return true
        end

        if IsSpellKnown and
           (IsSpellKnown(spellID) or IsSpellKnown(spellID, true)) then
            return true
        end

        if C_SpellBook and C_SpellBook.IsSpellKnown and
           Enum and Enum.SpellBookSpellBank then

            local bank = Enum.SpellBookSpellBank

            if C_SpellBook.IsSpellKnown(spellID, bank.Player) or
               C_SpellBook.IsSpellKnown(spellID, bank.Pet) then
                return true
            end
        end

        return false
    end


    ----------------------------------------------------------------
    -- HELPER: get player's interrupt
    -- Cached: nil = not resolved yet, false = class has none.
    -- The event frame below clears the cache when spells change.
    ----------------------------------------------------------------

    modTable.InterruptSpellID = nil

    local function FindInterruptSpell()

        local _, class = UnitClass("player")

        local spells = modTable.InterruptSpells[class]

        if not spells then
            return nil
        end

        for _, spellID in ipairs(spells) do
            if IsKnownSpell(spellID) then
                return spellID
            end
        end

        return nil
    end

    modTable.GetInterruptSpell = function()

        if modTable.INTERRUPT_OVERRIDE then
            return modTable.INTERRUPT_OVERRIDE
        end

        if modTable.InterruptSpellID == nil then
            modTable.InterruptSpellID = FindInterruptSpell() or false
        end

        return modTable.InterruptSpellID or nil
    end


    ----------------------------------------------------------------
    -- HELPER: interrupt cooldown length
    -- Prefers a duration read from the real cooldown (talents
    -- included), then the untalented base cooldown.
    ----------------------------------------------------------------

    modTable.LearnedCooldown = {}

    modTable.GetInterruptCooldown = function(spellID)

        local learned = modTable.LearnedCooldown[spellID]

        if learned then
            return learned
        end

        if GetSpellBaseCooldown then

            local cooldownMS = GetSpellBaseCooldown(spellID)

            if cooldownMS and
               not modTable.IsSecret(cooldownMS) and
               cooldownMS > 0 then

                return cooldownMS / 1000
            end
        end

        return DEFAULT_COOLDOWN
    end


    ----------------------------------------------------------------
    -- HELPER: interrupt ready
    ----------------------------------------------------------------

    -- Set from UNIT_SPELLCAST_SUCCEEDED; used when the cooldown is secret.
    modTable.KickReadyAt = 0

    local function ComputeInterruptReady(now)

        local spellID = modTable.GetInterruptSpell()

        if not spellID then
            return false
        end

        local cooldown =
            C_Spell and C_Spell.GetSpellCooldown and
            C_Spell.GetSpellCooldown(spellID)

        if cooldown and
           not modTable.IsSecret(cooldown.startTime) and
           not modTable.IsSecret(cooldown.duration) and
           not modTable.IsSecret(cooldown.isEnabled) then

            if cooldown.isEnabled == false then
                return false
            end

            local startTime = cooldown.startTime or 0
            local duration  = cooldown.duration or 0

            if startTime == 0 or duration == 0 then
                return true
            end

            if duration > GCD_MAX then
                modTable.LearnedCooldown[spellID] = duration
            end

            return (startTime + duration) - now <= READY_TOLERANCE
        end

        -- The cooldown is secret: fall back to our own record of
        -- when the interrupt was last used.
        return now >= modTable.KickReadyAt - READY_TOLERANCE
    end

    -- Every casting nameplate asks each frame; GetTime() is constant
    -- within a frame, so compute once per frame and share the result.
    modTable.InterruptReady = function()

        local now = GetTime()

        if modTable.ReadyCheckedAt ~= now then
            modTable.ReadyCached    = ComputeInterruptReady(now)
            modTable.ReadyCheckedAt = now
        end

        return modTable.ReadyCached
    end


    ----------------------------------------------------------------
    -- EVENTS
    -- Initialization reruns whenever the mod is edited, so reuse
    -- the named frame instead of stacking a new one each time.
    ----------------------------------------------------------------

    local eventFrame =
        _G.PlaterKickAlertEventFrame or
        CreateFrame("Frame", "PlaterKickAlertEventFrame")

    eventFrame:UnregisterAllEvents()

    eventFrame:RegisterEvent("SPELLS_CHANGED")
    eventFrame:RegisterUnitEvent("UNIT_PET", "player")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")

    eventFrame:SetScript("OnEvent", function(_, event, unit, _, spellID)

        if event == "UNIT_SPELLCAST_SUCCEEDED" then

            if modTable.InterruptSpellSet[spellID] or
               spellID == modTable.INTERRUPT_OVERRIDE then

                local interruptID =
                    modTable.GetInterruptSpell() or spellID

                modTable.KickReadyAt =
                    GetTime() + modTable.GetInterruptCooldown(interruptID)
            end

        else
            -- Spec, talent or pet changed: resolve the interrupt again
            modTable.InterruptSpellID = nil
        end

        modTable.ReadyCheckedAt = nil
    end)


    ----------------------------------------------------------------
    -- HELPER: cast bar color
    ----------------------------------------------------------------

    modTable.ApplyCastColor = function(castBar, unitFrame, envTable, canInterrupt)

        local open =
            envTable.CurrentPriority == "danger" and
            modTable.COLOR_DANGER or
            modTable.COLOR_NORMAL

        local locked = modTable.COLOR_LOCKED

        if not modTable.IsSecret(canInterrupt) then

            local color = canInterrupt == true and open or locked

            Plater.SetCastBarColor(unitFrame, color[1], color[2], color[3])

            envTable.LastCanInterrupt = canInterrupt == true
            return
        end

        envTable.LastCanInterrupt = nil

        local pick =
            C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean

        if not pick then
            -- The flag cannot be read at all, but the spell's
            -- priority is still known, so show that.
            Plater.SetCastBarColor(unitFrame, open[1], open[2], open[3])
            return
        end

        -- The evaluated channels are secret too. Plater.SetCastBarColor
        -- may test its arguments, so write to the status bar directly.
        castBar:SetStatusBarColor(
            pick(canInterrupt, open[1], locked[1]),
            pick(canInterrupt, open[2], locked[2]),
            pick(canInterrupt, open[3], locked[3])
        )
    end


    ----------------------------------------------------------------
    -- HELPER: kick-ready border
    -- Shown only when the cast is interruptible and our interrupt
    -- is off cooldown.
    ----------------------------------------------------------------

    modTable.UpdateKickBorder = function(envTable, canInterrupt)

        local border = envTable.KickBorder

        if not border then
            return
        end

        if not modTable.InterruptReady() then
            border:Hide()
            return
        end

        if not modTable.IsSecret(canInterrupt) then
            border:SetAlpha(1)
            border:SetShown(canInterrupt == true)
            return
        end

        if border.SetAlphaFromBoolean then
            border:SetAlphaFromBoolean(canInterrupt, 1, 0)

        elseif C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
            border:SetAlpha(
                C_CurveUtil.EvaluateColorValueFromBoolean(canInterrupt, 1, 0)
            )

        else
            -- No way to read the flag: every listed spell is meant to be
            -- kicked, so err on the side of showing the border.
            border:SetAlpha(1)
        end

        border:Show()
    end


    ----------------------------------------------------------------
    -- HELPER: undo everything this mod applied to a nameplate
    ----------------------------------------------------------------

    modTable.RestoreCastBar = function(unitFrame, envTable)

        Plater.SetCastBarColor(unitFrame)
        Plater.SetCastBarSize(unitFrame)

        if envTable.KickBorder then
            envTable.KickBorder:Hide()
        end

        envTable.Active           = nil
        envTable.CurrentPriority  = nil
        envTable.LastCanInterrupt = nil
    end
end
