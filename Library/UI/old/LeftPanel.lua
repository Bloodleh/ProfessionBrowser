local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

-- Skill level color logic
this.GetSkillColor = function(playerSkill, skillLevel)
    if playerSkill == -1 then
        --return 1, 0, 0
        return 1, 1, 1
    end
    if playerSkill >= skillLevel.gray then
        return 0.5, 0.5, 0.5 -- Gray
    elseif playerSkill >= skillLevel.green then
        return 0, 1, 0 -- Green
    elseif playerSkill >= skillLevel.yellow then
        return 1, 1, 0 -- Yellow
    else
        return 1, 0.5, 0 -- Orange
    end
end

this.createLeftPanelUI = function()
    local frame = ENV.UI.mainFrame

    -- Left Panel
    local leftPanel = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.leftPanel = leftPanel

    leftPanel:Hide()

    leftPanel:SetSize(200, 310)
    leftPanel:SetPoint("LEFT", frame, "LEFT", 10, -10)

    local scrollFrame = CreateFrame("ScrollFrame", nil, leftPanel, "UIPanelScrollFrameTemplate")
    leftPanel.scrollFrame = scrollFrame

    scrollFrame:SetSize(180, 290)
    scrollFrame:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 10, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", -10, 0)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame.scrollChild = scrollChild

    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 500)

    -- local itemList = {
    --     {name = "Example Item", icon = 134400, materials = {
    --         {name = "Material 1", icon = 134400, count = 0, required = 1},
    --         {name = "Material 2", icon = 134401, count = 2, required = 3},
    --     }},
    --     {name = "Another Item", icon = 134401, materials = {
    --         {name = "Material A", icon = 134402, count = 1, required = 1},
    --     }},
    -- }

    local itemList = ENV.Data.Engineering
    local i = 0

    local playerProfession = ENV.PlayerProfession.getProfession("Engineering")
    local playerSkill = playerProfession and playerProfession.level or -1

    for itemId, item in pairs(itemList) do
        i = i + 1

        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(scrollFrame:GetWidth(), 20)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -10 - (i - 1) * 25)

        local r, g, b = this.GetSkillColor(playerSkill, item.levels or { req = 0, yellow = 0, green = 0, gray = 0 })

        -- Background color
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(row)
        bg:SetColorTexture(0, 0, 0, 0)

        -- Text
        local fontString = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fontString:SetPoint("LEFT", row, "LEFT", 10, 0)
        fontString:SetText(item.name)
        fontString:SetTextColor(r, g, b)

        row:EnableMouse(true)

        row:SetScript("OnMouseUp", function()
            frame.rightPanel:UpdateSelectedItem(item, itemId)
            bg:SetColorTexture(r, g, b, 0.8)
            fontString:SetTextColor(1, 1, 1)
        end)

        row:SetScript("OnEnter", function()
            bg:SetColorTexture(r, g, b, 0.25)
            fontString:SetTextColor(1, 1, 1)
        end)

        row:SetScript("OnLeave", function()
            bg:SetColorTexture(0, 0, 0, 0)
            fontString:SetTextColor(r, g, b) 
        end)
    end
end