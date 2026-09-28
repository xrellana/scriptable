function (self, unit, unitFrame, envTable, modTable)

    -- A plate can be recycled mid-cast (unit died or went out of
    -- range) without Cast Stop firing; do not leak the glow to
    -- whatever unit gets this plate next.

    if envTable.Active then
        modTable.StopKickAlert(envTable)
    end
end
