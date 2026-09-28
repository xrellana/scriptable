function (self, unit, unitFrame, envTable, modTable)

    local spellID = self.SpellID

    if not spellID then
        return
    end


    ------------------------------------------------------------
    -- Undo whatever this mod applied to the previous cast
    ------------------------------------------------------------

    if envTable.Active then
        modTable.RestoreCastBar(unitFrame, envTable)
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

    local canInterrupt = self.CanInterrupt


    ------------------------------------------------------------
    -- Danger spells get a bigger bar. The bar is at profile
    -- size here: nothing enlarged it, or RestoreCastBar reset it.
    ------------------------------------------------------------

    if envTable.CurrentPriority == "danger" then

        Plater.SetCastBarSize(
            unitFrame,
            self:GetWidth()  * modTable.WIDTH_SCALE,
            self:GetHeight() * modTable.HEIGHT_SCALE
        )
    end


    modTable.ApplyCastColor(self, unitFrame, envTable, canInterrupt)
    modTable.UpdateKickBorder(envTable, canInterrupt)

    envTable.Active = true
end
