function (self, unit, unitFrame, envTable, modTable)

    -- Runs once per nameplate. Shared data and helpers live in
    -- modTable (see Initialization); only per-plate state goes here.

    ----------------------------------------------------------------
    -- CREATE THICK KICK BORDER
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

        local thickness = 3

        local top =
            border:CreateTexture(nil, "OVERLAY")

        top:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        top:SetPoint(
            "TOPLEFT",
            castBar,
            "TOPLEFT",
            -2,
            2
        )

        top:SetPoint(
            "TOPRIGHT",
            castBar,
            "TOPRIGHT",
            2,
            2
        )

        top:SetHeight(thickness)


        local bottom =
            border:CreateTexture(nil, "OVERLAY")

        bottom:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        bottom:SetPoint(
            "BOTTOMLEFT",
            castBar,
            "BOTTOMLEFT",
            -2,
            -2
        )

        bottom:SetPoint(
            "BOTTOMRIGHT",
            castBar,
            "BOTTOMRIGHT",
            2,
            -2
        )

        bottom:SetHeight(thickness)


        local left =
            border:CreateTexture(nil, "OVERLAY")

        left:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        left:SetPoint(
            "TOPLEFT",
            castBar,
            "TOPLEFT",
            -2,
            2
        )

        left:SetPoint(
            "BOTTOMLEFT",
            castBar,
            "BOTTOMLEFT",
            -2,
            -2
        )

        left:SetWidth(thickness)


        local right =
            border:CreateTexture(nil, "OVERLAY")

        right:SetColorTexture(
            0.10, 1.00, 0.20, 1
        )

        right:SetPoint(
            "TOPRIGHT",
            castBar,
            "TOPRIGHT",
            2,
            2
        )

        right:SetPoint(
            "BOTTOMRIGHT",
            castBar,
            "BOTTOMRIGHT",
            2,
            -2
        )

        right:SetWidth(thickness)

        border:Hide()

        envTable.KickBorder = border
    end
end
