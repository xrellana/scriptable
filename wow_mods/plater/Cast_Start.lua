function (self, unit, unitFrame, envTable)

    local spellID = self.SpellID

    if not spellID then
        return
    end


    ------------------------------------------------------------
    -- 清理上一次由本 Mod 留下的状态
    ------------------------------------------------------------

    if envTable.Active then

        Plater.SetCastBarColor(unitFrame)
        Plater.SetCastBarSize(unitFrame)
        Plater.SetCastBarBorderColor(self)

        envTable.SetKickBorder(false)

        envTable.Active = nil
        envTable.CurrentPriority = nil
    end


    ------------------------------------------------------------
    -- 判断技能类型
    ------------------------------------------------------------

    local dangerous =
        envTable.DangerSpells[spellID] or
        envTable.MechanicSpells[spellID]

    local normal =
        envTable.NormalSpells[spellID]


    -- 不在数据库里：
    -- 完全不碰你原来的 Plater 样式
    if not dangerous and not normal then
        return
    end


    ------------------------------------------------------------
    -- 获取当前真实 interrupt 状态
    ------------------------------------------------------------

    local canInterrupt =
        self.CanInterrupt == true


    ------------------------------------------------------------
    -- 保存原始尺寸
    ------------------------------------------------------------

    Plater.SetCastBarSize(unitFrame)

    local baseWidth  = self:GetWidth()
    local baseHeight = self:GetHeight()


    ------------------------------------------------------------
    -- 危险技能
    ------------------------------------------------------------

    if dangerous then

        envTable.CurrentPriority = "danger"

        local newWidth =
            baseWidth * envTable.WIDTH_SCALE

        local newHeight =
            baseHeight * envTable.HEIGHT_SCALE

        Plater.SetCastBarSize(
            unitFrame,
            newWidth,
            newHeight
        )


        -- 可断：红色
        if canInterrupt then

            Plater.SetCastBarColor(
                unitFrame,
                1.00,
                0.08,
                0.08
            )

        -- 不可断：紫色
        else

            Plater.SetCastBarColor(
                unitFrame,
                0.72,
                0.16,
                0.95
            )
        end


    ------------------------------------------------------------
    -- 普通 interrupt
    ------------------------------------------------------------

    elseif normal then

        envTable.CurrentPriority = "normal"

        if canInterrupt then

            Plater.SetCastBarColor(
                unitFrame,
                1.00,
                0.82,
                0.08
            )

        else

            -- 如果临时变成不可打断，
            -- 就不要继续骗你说这是黄色可断技能
            Plater.SetCastBarColor(
                unitFrame,
                0.72,
                0.16,
                0.95
            )
        end
    end


    ------------------------------------------------------------
    -- Kick Ready Border
    ------------------------------------------------------------

    local showKickBorder =
        canInterrupt and
        envTable.InterruptReady()

    envTable.SetKickBorder(showKickBorder)

    envTable.Active = true
end