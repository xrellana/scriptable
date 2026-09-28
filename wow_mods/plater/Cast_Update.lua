function (self, unit, unitFrame, envTable, modTable)

    if not envTable.Active then
        return
    end

    local canInterrupt = self.CanInterrupt


    ------------------------------------------------------------
    -- Recolor only when the interrupt state flips. A secret flag
    -- cannot be compared, so in that case reapply every tick.
    ------------------------------------------------------------

    if modTable.IsSecret(canInterrupt) or
       (canInterrupt == true) ~= envTable.LastCanInterrupt then

        modTable.ApplyCastColor(self, unitFrame, envTable, canInterrupt)
    end


    ------------------------------------------------------------
    -- Track our own interrupt cooldown live
    ------------------------------------------------------------

    modTable.UpdateKickBorder(envTable, canInterrupt)
end
