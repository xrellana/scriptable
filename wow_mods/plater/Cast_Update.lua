function (self, unit, unitFrame, envTable, modTable)

    if not envTable.Active then
        return
    end

    local notInterruptible = self.notInterruptible


    ------------------------------------------------------------
    -- Recolor only when the interrupt state flips. A secret flag
    -- cannot be compared, so in that case reapply every tick.
    ------------------------------------------------------------

    if modTable.IsSecret(notInterruptible) or
       (notInterruptible == true) ~= envTable.LastNotInterruptible then

        modTable.ApplyCastColor(self, unitFrame, envTable, notInterruptible)
    end


    ------------------------------------------------------------
    -- Track our own interrupt cooldown live
    ------------------------------------------------------------

    modTable.UpdateKickBorder(envTable, notInterruptible)
end
