function (self, unit, unitFrame, envTable, modTable)

    ------------------------------------------------------------
    -- Undo whatever this mod applied to the previous cast
    ------------------------------------------------------------

    if envTable.Active then
        modTable.RestoreCastBar(unitFrame, envTable)
    end


    ------------------------------------------------------------
    -- A secret spell ID cannot be looked up; Plater skips its own
    -- per-spell cast colors in that case too, so do the same.
    ------------------------------------------------------------

    local spellID = self.SpellID

    if not spellID then
        return
    end

    if modTable.IsSecret(spellID) then

        if modTable.DEBUG then
            print("KickAlert: secret spell ID, cast skipped")
        end

        return
    end


    ------------------------------------------------------------
    -- Classify the spell
    ------------------------------------------------------------

    if modTable.DangerSpells[spellID] or
       modTable.MechanicSpells[spellID] then

        envTable.CurrentPriority = "danger"

    elseif modTable.NormalSpells[spellID] then

        envTable.CurrentPriority = "normal"

    else
        -- Unlisted spells keep the stock Plater look
        return
    end


    ------------------------------------------------------------
    -- May be a secret value in combat: only ever pass it to
    -- the modTable helpers, never test or compare it here.
    ------------------------------------------------------------

    local notInterruptible = self.notInterruptible


    ------------------------------------------------------------
    -- Danger spells enlarge the whole nameplate, not just the
    -- cast bar, so the plate keeps its proportions.
    ------------------------------------------------------------

    local scaleBefore = unitFrame:GetScale()

    if envTable.CurrentPriority == "danger" then

        local current = tonumber(unitFrame.nameplateScaleAdjust) or 1

        Plater.SetNameplateScale(unitFrame, current * modTable.DANGER_PLATE_SCALE)

        envTable.ScaleBefore = current
    end

    if modTable.DEBUG then
        print(("KickAlert: %d %s, plate scale %.2f -> %.2f"):format(
            spellID, envTable.CurrentPriority,
            scaleBefore, unitFrame:GetScale()))
    end


    modTable.ApplyCastColor(self, unitFrame, envTable, notInterruptible)

    modTable.StartKickGlow(envTable)
    modTable.UpdateKickBorder(envTable, notInterruptible)

    envTable.Active = true
end
