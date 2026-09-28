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

    if not spellID or modTable.IsSecret(spellID) then
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

    if envTable.CurrentPriority == "danger" then

        Plater.SetNameplateScale(unitFrame, modTable.DANGER_PLATE_SCALE)

        envTable.Scaled = true
    end


    modTable.ApplyCastColor(self, unitFrame, envTable, notInterruptible)

    modTable.StartKickGlow(envTable)
    modTable.UpdateKickBorder(envTable, notInterruptible)

    envTable.Active = true
end
