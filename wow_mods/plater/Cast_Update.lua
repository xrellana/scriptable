function (self, unit, unitFrame, envTable, modTable)

    if not envTable.Active then
        return
    end

    local notInterruptible = self.notInterruptible


    ------------------------------------------------------------
    -- Repaint on every update. Other cast bar mods (e.g. Jundies'
    -- Enhanced Castbar) and Plater itself also color the bar, and
    -- whoever paints last wins.
    ------------------------------------------------------------

    modTable.ApplyCastColor(self, unitFrame, envTable, notInterruptible)


    ------------------------------------------------------------
    -- Track our own interrupt cooldown live
    ------------------------------------------------------------

    modTable.UpdateKickBorder(envTable, notInterruptible)
end
