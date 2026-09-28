function (self, unit, unitFrame, envTable, modTable)

    ------------------------------------------------------------
    -- Clear the glow left over from the previous cast
    ------------------------------------------------------------

    if envTable.Active then
        modTable.StopKickAlert(envTable)
    end


    ------------------------------------------------------------
    -- A secret spell ID cannot be looked up; Plater skips its own
    -- per-spell cast colors in that case too, so do the same.
    ------------------------------------------------------------

    local spellID = self.SpellID

    if not spellID or modTable.IsSecret(spellID) then
        return
    end

    if not modTable.DangerSpells[spellID] then
        return
    end


    ------------------------------------------------------------
    -- May be a secret value in combat: only ever pass it to
    -- the modTable helpers, never test or compare it here.
    ------------------------------------------------------------

    local notInterruptible = self.notInterruptible

    modTable.StartKickGlow(envTable)
    modTable.UpdateKickBorder(envTable, notInterruptible)

    envTable.Active = true
end
