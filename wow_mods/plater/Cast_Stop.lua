function (self, unit, unitFrame, envTable)

    if not envTable.Active then
        envTable.SetKickBorder(false)
        return
    end


    ------------------------------------------------------------
    -- 恢复 Plater 原始设置
    ------------------------------------------------------------

    Plater.SetCastBarColor(unitFrame)
    Plater.SetCastBarSize(unitFrame)
    Plater.SetCastBarBorderColor(self)

    envTable.SetKickBorder(false)

    envTable.Active = nil
    envTable.CurrentPriority = nil
end