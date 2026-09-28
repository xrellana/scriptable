function (self, unit, unitFrame, envTable, modTable)

    if not envTable.Active then
        return
    end

    ------------------------------------------------------------
    -- Track interruptibility and our own interrupt cooldown live
    ------------------------------------------------------------

    modTable.UpdateKickBorder(envTable, self.notInterruptible)
end
