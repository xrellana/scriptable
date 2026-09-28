function (self, unit, unitFrame, envTable)

    ----------------------------------------------------------------
    -- SETTINGS
    ----------------------------------------------------------------

    envTable.WIDTH_SCALE  = 1.20
    envTable.HEIGHT_SCALE = 1.50

    -- 如果自动识别你的打断技能失败，可以手工指定。
    -- 例如萨满 Wind Shear = 57994
    -- nil = 自动识别
    envTable.INTERRUPT_OVERRIDE = nil


    ----------------------------------------------------------------
    -- DANGEROUS INTERRUPTS
    -- 高优先级：红色 / 紫色 + 放大
    ----------------------------------------------------------------

    envTable.DangerSpells = {

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
    -- 能断，但优先级相对低：黄色
    ----------------------------------------------------------------

    envTable.NormalSpells = {

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
    -- 一般不是普通 Kick 解决，但仍值得大号提示
    --
    -- 最终颜色仍然根据 CanInterrupt 动态判断：
    -- 可打断 = 红
    -- 不可打断 = 紫
    ----------------------------------------------------------------

    envTable.MechanicSpells = {

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
    ----------------------------------------------------------------

    envTable.InterruptSpells = {

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
            19647,      -- Spell Lock
        },

        MONK = {
            116705,     -- Spear Hand Strike
        },

        DRUID = {
            106839,     -- Skull Bash
        },

        DEMONHUNTER = {
            183752,     -- Disrupt
        },

        EVOKER = {
            351338,     -- Quell
        },
    }


    ----------------------------------------------------------------
    -- HELPER: is spell known
    ----------------------------------------------------------------

    envTable.IsKnownSpell = function(spellID)

        if IsPlayerSpell and IsPlayerSpell(spellID) then
            return true
        end

        if IsSpellKnown and IsSpellKnown(spellID) then
            return true
        end

        return false
    end


    ----------------------------------------------------------------
    -- HELPER: get player's interrupt
    ----------------------------------------------------------------

    envTable.GetInterruptSpell = function()

        if envTable.INTERRUPT_OVERRIDE then
            return envTable.INTERRUPT_OVERRIDE
        end

        local _, class = UnitClass("player")

        local spells = envTable.InterruptSpells[class]

        if not spells then
            return nil
        end

        for _, spellID in ipairs(spells) do
            if envTable.IsKnownSpell(spellID) then
                return spellID
            end
        end

        return nil
    end


    ----------------------------------------------------------------
    -- HELPER: interrupt cooldown
    ----------------------------------------------------------------

    envTable.InterruptReady = function()

        local spellID = envTable.GetInterruptSpell()

        if not spellID then
            return false
        end

        if C_Spell and C_Spell.GetSpellCooldown then

            local cooldown = C_Spell.GetSpellCooldown(spellID)

            if not cooldown then
                return false
            end

            if cooldown.isEnabled == false then
                return false
            end

            local startTime = cooldown.startTime or 0
            local duration  = cooldown.duration or 0

            if startTime == 0 or duration == 0 then
                return true
            end

            local remaining =
                (startTime + duration) - GetTime()

            return remaining <= 0.10
        end

        -- fallback
        if GetSpellCooldown then

            local startTime, duration, enabled =
                GetSpellCooldown(spellID)

            if enabled == 0 then
                return false
            end

            if not startTime or
               startTime == 0 or
               duration == 0 then

                return true
            end

            return ((startTime + duration) - GetTime()) <= 0.10
        end

        return false
    end


    ----------------------------------------------------------------
    -- CREATE THICK KICK BORDER
    ----------------------------------------------------------------

    local frame = unitFrame or self
    local castBar = frame.castBar

    if castBar and not envTable.KickBorder then

        local border =
            CreateFrame("Frame", nil, castBar)

        border:SetAllPoints(castBar)
        border:SetFrameLevel(
            castBar:GetFrameLevel() + 20
        )

        local thickness = 3

        local top =
            border:CreateTexture(nil, "OVERLAY")

        top:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        top:SetPoint(
            "TOPLEFT",
            castBar,
            "TOPLEFT",
            -2,
            2
        )

        top:SetPoint(
            "TOPRIGHT",
            castBar,
            "TOPRIGHT",
            2,
            2
        )

        top:SetHeight(thickness)


        local bottom =
            border:CreateTexture(nil, "OVERLAY")

        bottom:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        bottom:SetPoint(
            "BOTTOMLEFT",
            castBar,
            "BOTTOMLEFT",
            -2,
            -2
        )

        bottom:SetPoint(
            "BOTTOMRIGHT",
            castBar,
            "BOTTOMRIGHT",
            2,
            -2
        )

        bottom:SetHeight(thickness)


        local left =
            border:CreateTexture(nil, "OVERLAY")

        left:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        left:SetPoint(
            "TOPLEFT",
            castBar,
            "TOPLEFT",
            -2,
            2
        )

        left:SetPoint(
            "BOTTOMLEFT",
            castBar,
            "BOTTOMLEFT",
            -2,
            -2
        )

        left:SetWidth(thickness)


        local right =
            border:CreateTexture(nil, "OVERLAY")

        right:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        right:SetPoint(
            "TOPRIGHT",
            castBar,
            "TOPRIGHT",
            2,
            2
        )

        right:SetPoint(
            "BOTTOMRIGHT",
            castBar,
            "BOTTOMRIGHT",
            2,
            -2
        )

        right:SetWidth(thickness)

        border:Hide()

        envTable.KickBorder = border
    end


    ----------------------------------------------------------------
    -- HELPER: border visibility
    ----------------------------------------------------------------

    envTable.SetKickBorder = function(show)

        local border = envTable.KickBorder

        if not border then
            return
        end

        if show then
            border:Show()
        else
            border:Hide()
        end
    end
end