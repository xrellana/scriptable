function (modTable)

    ----------------------------------------------------------------
    -- SETTINGS
    ----------------------------------------------------------------

    -- Set this when auto-detection picks the wrong interrupt,
    -- e.g. 57994 for Wind Shear. nil = auto-detect.
    modTable.INTERRUPT_OVERRIDE = nil

    -- Kick-ready indicator: lines running around the cast bar
    -- (Plater.StartPixelGlow, backed by LibCustomGlow).
    modTable.KICK_GLOW = {
        color     = { 0.10, 1.00, 0.20, 1 },
        lines     = 8,
        frequency = 0.4, -- laps per second
        thickness = 2,
        offset    = 2,   -- pixels outside the cast bar edge
    }

    -- A cooldown this close to ending already counts as ready.
    local READY_TOLERANCE = 0.10

    -- Cooldowns this short are the GCD, not the interrupt's own cooldown.
    local GCD_MAX = 1.5

    -- Used when the real cooldown can be neither read nor looked up.
    local DEFAULT_COOLDOWN = 15


    ----------------------------------------------------------------
    -- DANGEROUS INTERRUPTS
    -- These casts get the glow while they are interruptible and
    -- your interrupt is ready. Everything else is left to Plater
    -- and other mods.
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
    -- In combat, notInterruptible, enemy spell IDs and spell
    -- cooldowns can be secret.
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
    -- HELPER: kick-ready glow
    -- The glow lives inside envTable.KickBorder, so hiding the
    -- border or setting its alpha from a secret boolean also
    -- governs the glow without ever branching on the secret.
    ----------------------------------------------------------------

    local GLOW_KEY = "PlaterKickAlert"

    local glowOptions = {
        glowType  = "pixel",
        N         = modTable.KICK_GLOW.lines,
        frequency = modTable.KICK_GLOW.frequency,
        th        = modTable.KICK_GLOW.thickness,
        xOffset   = modTable.KICK_GLOW.offset,
        yOffset   = modTable.KICK_GLOW.offset,
        border    = false,
        key       = GLOW_KEY,
    }

    -- Called from Cast Start, when the cast bar has a real size:
    -- LibCustomGlow sizes the line length once at start, capped by
    -- the frame height.
    modTable.StartKickGlow = function(envTable)

        if envTable.KickBorder and Plater.StartPixelGlow then
            Plater.StartPixelGlow(
                envTable.KickBorder,
                modTable.KICK_GLOW.color,
                glowOptions,
                GLOW_KEY
            )
        end
    end

    modTable.StopKickGlow = function(envTable)

        if envTable.KickBorder and Plater.StopPixelGlow then
            Plater.StopPixelGlow(envTable.KickBorder, GLOW_KEY)
        end
    end


    ----------------------------------------------------------------
    -- HELPER: kick-ready border
    -- Shown only when the cast is interruptible and our interrupt
    -- is off cooldown.
    ----------------------------------------------------------------

    modTable.UpdateKickBorder = function(envTable, notInterruptible)

        local border = envTable.KickBorder

        if not border then
            return
        end

        if not modTable.InterruptReady() then
            border:Hide()
            return
        end

        if not modTable.IsSecret(notInterruptible) then
            border:SetAlpha(1)
            border:SetShown(notInterruptible ~= true)
            return
        end

        if border.SetAlphaFromBoolean then
            border:SetAlphaFromBoolean(notInterruptible, 0, 1)

        elseif C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
            border:SetAlpha(
                C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, 0, 1)
            )

        else
            -- No way to read the flag: every listed spell is meant to be
            -- kicked, so err on the side of showing the border.
            border:SetAlpha(1)
        end

        border:Show()
    end


    ----------------------------------------------------------------
    -- HELPER: remove the glow from a nameplate
    ----------------------------------------------------------------

    modTable.StopKickAlert = function(envTable)

        if envTable.KickBorder then
            envTable.KickBorder:Hide()
        end

        modTable.StopKickGlow(envTable)

        envTable.Active = nil
    end
end
