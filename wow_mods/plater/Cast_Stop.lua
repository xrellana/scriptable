function (self, unit, unitFrame, envTable, modTable)

    if envTable.Active then
        modTable.RestoreCastBar(unitFrame, envTable)

    elseif envTable.KickBorder then
        envTable.KickBorder:Hide()
    end
end
