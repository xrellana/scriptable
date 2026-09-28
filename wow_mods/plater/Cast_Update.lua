function (self, unit, unitFrame, envTable)

    if not envTable.Active then
        return
    end

    local canInterrupt =
        self.CanInterrupt == true


    ------------------------------------------------------------
    -- 根据当前实际 interrupt 状态修正颜色
    ------------------------------------------------------------

    if envTable.CurrentPriority == "danger" then

        if canInterrupt then

            Plater.SetCastBarColor(
                unitFrame,
                1.00,
                0.08,
                0.08
            )

        else

            Plater.SetCastBarColor(
                unitFrame,
                0.72,
                0.16,
                0.95
            )
        end

    elseif envTable.CurrentPriority == "normal" then

        if canInterrupt then

            Plater.SetCastBarColor(
                unitFrame,
                1.00,
                0.82,
                0.08
            )

        else

            Plater.SetCastBarColor(
                unitFrame,
                0.72,
                0.16,
                0.95
            )
        end
    end


    ------------------------------------------------------------
    -- 实时检查自己的 interrupt CD
    ------------------------------------------------------------

    local showKickBorder =
        canInterrupt and
        envTable.InterruptReady()

    envTable.SetKickBorder(showKickBorder)
end