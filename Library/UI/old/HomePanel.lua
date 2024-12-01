local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

this.createHomePanelUI = function()
    local frame = ENV.UI.frame

    -- Home frame
    local homePanel = CreateFrame("Frame", nil, frame)
    frame.homePanel = homePanel

    homePanel:Hide()

    --homePanel:SetSize(600, 380)
    homePanel:SetSize(ENV.Config.ui.width, ENV.Config.ui.height - 20)
    homePanel:SetPoint("LEFT", frame, "LEFT", 0, -10)
    --homePanel:SetPoint("CENTER", UIParent, "CENTER")

    -- Create headers
    local professionHeader = homePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    homePanel.professionHeader = professionHeader

    professionHeader:SetPoint("TOPLEFT", homePanel, "TOPLEFT", 20, -50)
    professionHeader:SetText("Primary Professions")

    local secondaryHeader = homePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    homePanel.secondaryHeader = secondaryHeader

    secondaryHeader:SetPoint("TOPLEFT", homePanel, "TOPLEFT", 20, -220)
    secondaryHeader:SetText("Secondary Professions")

    local otherHeader = homePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    homePanel.otherHeader = otherHeader

    otherHeader:SetPoint("TOPLEFT", homePanel, "TOPLEFT", 20, -290)
    otherHeader:SetText("Other")

    -- Function to create profession/skill boxes
    local function CreateSkillBox(parent, skillData, xOffset, yOffset, type)
        local box = CreateFrame("Frame", nil, parent)
        box:SetSize(150, 40)
        box:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)

         -- Border
        --local border = box:CreateTexture(nil, "BACKGROUND")
        --border:SetAllPoints()
        --border:SetColorTexture(0.5, 0.5, 0.5, 1) -- Gray border

        -- Background
        local bg = box:CreateTexture(nil, "ARTWORK")
        bg:SetPoint("TOPLEFT", box, "TOPLEFT", 1, -1)
        bg:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -1, 1)
        bg:SetColorTexture(0, 0, 0, 0) -- Transparent by default

        -- Icon
        local icon = box:CreateTexture(nil, "OVERLAY")
        icon:SetSize(30, 30)
        icon:SetPoint("LEFT", box, "LEFT", 5, 0)
        icon:SetTexture(skillData.icon or "Interface\\Icons\\INV_Misc_QuestionMark") -- Default icon if none provided

        -- Text
        local text = box:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        text:SetText(skillData.name)

        local playerProfession = ENV.PlayerProfession.getProfession(skillData.name)
        if (type == "primary_profession" or type == "secondary_profession") and playerProfession ~= nil then
            text:SetTextColor(0, 1, 0, 1)
            text:SetPoint("LEFT", icon, "RIGHT", 10, 10)

            local levelText = box:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            levelText:SetPoint("LEFT", icon, "RIGHT", 10, -10)
            levelText:SetTextColor(0, 1, 0, 1)
            levelText:SetText(playerProfession.level .. "/" .. playerProfession.maxLevel)
        end

        -- Hover effect
        box:EnableMouse(true)
        box:SetScript("OnEnter", function()
            bg:SetColorTexture(0.3, 0.3, 0.3, 0.5) -- Hover color
        end)
        box:SetScript("OnLeave", function()
            bg:SetColorTexture(0, 0, 0, 0) -- Reset color
        end)

        -- Click behavior
        box:SetScript("OnMouseUp", function()
            print("Clicked on " .. skillData.name)
            ENV.UI.navigateTo({
                view = "profession",
                category = nil,
            })
        end)

        return box
    end

    -- Populate professions and secondary skills
    local function PopulateHomePanel()
        -- Layout settings
        local xStart = 20
        local xStep = 160 -- Space between items horizontally
        local yStep = -50 -- Space between rows
        local yOffset = -70
        local itemsPerRow = 3

        -- Populate professions (3 per row)
        for i, item in ipairs(ENV.Config.homeItems.primaryProfessions) do
            local xOffset = xStart + ((i - 1) % itemsPerRow) * xStep
            if (i - 1) % itemsPerRow == 0 and i > 1 then
                yOffset = yOffset + yStep -- Move to the next row
            end
            CreateSkillBox(homePanel, item, xOffset, yOffset, "primary_profession")
        end

        xStart = 20
        xStep = 160
        yStep = -50
        yOffset = -240

        -- Populate secondary skills (3 per row)
        for i, item in ipairs(ENV.Config.homeItems.secondaryProfessions) do
            local xOffset = xStart + ((i - 1) % itemsPerRow) * xStep
            if (i - 1) % itemsPerRow == 0 and i > 1 then
                yOffset = yOffset + yStep -- Move to the next row
            end
            CreateSkillBox(homePanel, item, xOffset, yOffset, "secondary_profession")
        end

        xStart = 20
        xStep = 160
        yStep = -50
        yOffset = -310

        -- Populate other (3 per row)
        for i, item in ipairs(ENV.Config.homeItems.other) do
            local xOffset = xStart + ((i - 1) % itemsPerRow) * xStep
            if (i - 1) % itemsPerRow == 0 and i > 1 then
                yOffset = yOffset + yStep -- Move to the next row
            end
            CreateSkillBox(homePanel, item, xOffset, yOffset, "other")
        end
    end

    -- Initialize the home frame
    PopulateHomePanel()
end