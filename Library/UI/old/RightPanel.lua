local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

this.testLookUpMaterial = function(materialId)
    local itemList = ENV.Data.Engineering
    for itemId, item in pairs(itemList) do
        if materialId == itemId then
            return item
        end
    end
    return nil
end

local selectedItemId = nil

this.createRightPanelUI = function()
    local frame = ENV.UI.mainFrame

    -- Right Panel
    local rightPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.rightPanel = rightPanel

    rightPanel:Hide()

    rightPanel:SetSize(370, 310)
    rightPanel:SetPoint("RIGHT", frame, "RIGHT", -10, -10)

    local itemIcon = rightPanel:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(40, 40)
    itemIcon:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 10, -10)

    -- Number Overlay for Item Icon
    local craftNumber = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    craftNumber:SetPoint("BOTTOMRIGHT", itemIcon, "BOTTOMRIGHT", 0, 0)
    craftNumber:SetTextColor(1, 1, 1, 1)
    craftNumber:SetFont(ENV.Config.ui.font, 14, "OUTLINE")
    craftNumber:SetText("") -- Start with no text
    craftNumber:Hide() -- Hide initially

    -- Enable Mouse Interaction for the Tooltip
    itemIcon:EnableMouse(true)
    itemIcon:SetScript("OnEnter", function()
        if selectedItemId then
            GameTooltip:SetOwner(itemIcon, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(selectedItemId)
            GameTooltip:Show()
        end
    end)
    itemIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local itemName = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    itemName:SetPoint("LEFT", itemIcon, "RIGHT", 10, 0)
    itemName:SetText("Select an item")

    -- Skill Level Info
    local skillLevelInfo = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    skillLevelInfo:SetPoint("TOPLEFT", itemIcon, "BOTTOMLEFT", 0, -10)

    local reagentsTitle = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    reagentsTitle:SetPoint("TOPLEFT", itemIcon, "BOTTOMLEFT", 0, -40)
    reagentsTitle:SetText("Reagents:")

    local materials = {}

    function rightPanel:UpdateSelectedItem(item, itemId)
        itemIcon:SetTexture(item.iconId or 134400)
        itemName:SetText(item.name or "???")

        selectedItemId = itemId

        -- Set the craft number overlay
        if item.count then
            craftNumber:SetText(item.count)
            craftNumber:Show()
        else
            craftNumber:SetText("")
            craftNumber:Hide() -- Hide if nil or 1
        end

        local learnLevel = -1
        local orangeLevel = ""
        local yellowLevel = ""
        local greenLevel = ""
        local grayLevel = ""

        if item.levels.learn then
            learnLevel = item.levels.learn
        end
        if item.levels.orange then
            orangeLevel = tostring(item.levels.orange) .. " "
        end
        if item.levels.yellow then
            yellowLevel = tostring(item.levels.yellow) .. " "
        end
        if item.levels.green then
            greenLevel = tostring(item.levels.green) .. " "
        end
        if item.levels.gray then
            grayLevel = tostring(item.levels.gray) .. " "
        end

        skillLevelInfo:SetFormattedText(
            "|cFFFFFFFF%s (%d)|r - |cFFFF8000%s|r|cFFFFFF00%s|r|cFF00FF00%s|r|cFF808080%s|r",
            item.type, learnLevel, orangeLevel, yellowLevel, greenLevel, grayLevel
        )

        for _, materialRow in pairs(materials) do
            materialRow:Hide()
        end
        materials = {}

        local materialList = item.mats or {}
        local i = 0
        for materialId, materialCount in pairs(materialList) do
            local material = this.testLookUpMaterial(materialId)
            i = i + 1
            local row = materials[i] or CreateFrame("Frame", nil, rightPanel)
            row:SetSize(rightPanel:GetWidth() - 20, 30)
            row:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 10, -110 - (i - 1) * 30)

            if not row.icon then
                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(25, 25)
                row.icon:SetPoint("LEFT", row, "LEFT", 0, 0)
            end

            if material then
                row.icon:SetTexture(material.iconId or 134400)

                row.icon:EnableMouse(true)
                row.icon:SetScript("OnEnter", function()
                    if materialId then
                        GameTooltip:SetOwner(row.icon, "ANCHOR_RIGHT")
                        GameTooltip:SetItemByID(materialId)
                        GameTooltip:Show()
                    end
                end)
                row.icon:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            else
                row.icon:SetTexture(134400)
                row.icon:EnableMouse(false)
                row.icon:SetScript("OnEnter", nil)
                row.icon:SetScript("OnLeave", nil)
            end

            if not row.name then
                row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.name:SetPoint("LEFT", row.icon, "RIGHT", 10, 0)
            end

            if material then
                row.name:SetText(material.name or "[id:" .. materialId .. "]")
            else
                row.name:SetText("[id:" .. materialId .. "]")
            end

            if not row.count then
                row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.count:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            end
            --row.count:SetText(string.format("%d/%d", 0, materialCount))
            row.count:SetText(string.format("%d", materialCount))

            -- Enable mouse interaction for the row
            row:EnableMouse(true)
            row:SetScript("OnMouseUp", function()
                print("Clicked on material:", material.name)
            end)

            row:SetScript("OnEnter", function()
                row.icon:SetVertexColor(1, 1, 0) -- Highlight icon
                row.name:SetTextColor(1, 1, 0) -- Highlight name
            end)

            row:SetScript("OnLeave", function()
                row.icon:SetVertexColor(1, 1, 1) -- Reset icon color
                row.name:SetTextColor(1, 1, 1) -- Reset name color
            end)

            -- row.icon:SetScript("OnEnter", function()
            --     GameTooltip:SetOwner(row.icon, "ANCHOR_RIGHT")

            --     if material then
            --         GameTooltip:SetText(material.name or "[id:" .. materialId .. "]", 1, 1, 1)
            --     else
            --         GameTooltip:SetText("[id:" .. materialId .. "]", 1, 1, 1)
            --     end

            --     GameTooltip:Show()
            -- end)
            -- row.icon:SetScript("OnLeave", function()
            --     GameTooltip:Hide()
            -- end)

            row:Show()
            materials[i] = row
        end
    end
end

-- rightPanel:UpdateSelectedItem({
--     name = "Example Item",
--     icon = 134400,
--     materials = {
--         {name = "Material 1", icon = 134400, count = 0, required = 1},
--         {name = "Material 2", icon = 134401, count = 2, required = 3},
--     }
-- })