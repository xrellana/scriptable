function (self, unit, unitFrame, envTable, modTable)

    -- Runs once per nameplate. Shared data and helpers live in
    -- modTable (see Initialization); only per-plate state goes here.

    ----------------------------------------------------------------
    -- CREATE KICK BORDER CONTAINER
    -- An empty frame over the cast bar. The pixel glow is attached
    -- to it in Cast Start; showing, hiding or fading this frame
    -- controls the glow.
    ----------------------------------------------------------------

    local frame = unitFrame or self
    local castBar = frame.castBar

    if castBar and not envTable.KickBorder then

        local border =
            CreateFrame("Frame", nil, castBar)

        border:SetAllPoints(castBar)
        border:SetFrameLevel(
            castBar:GetFrameLevel() + 20
        )

        border:Hide()

        envTable.KickBorder = border
    end
end
