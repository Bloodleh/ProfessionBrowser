local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

local frame

this.initMainFrame = function()
    -- MAIN FRAME
    frame = CreateFrame("Frame", addonName, UIParent, "BasicFrameTemplateWithInset")
    this.mainFrame = frame

    frame:SetSize(ENV.Config.ui.width, ENV.Config.ui.height)
    frame:SetMovable(true)

    -- Set frame position from save if exists, otherwise center
    if ENV.save.position then
        local pos = ENV.save.position
        frame:SetPoint(pos.point, pos.relativeTo, pos.relativePoint, pos.xOffset, pos.yOffset)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    -- Close button
    frame.CloseButton:SetScript("OnClick", function()
        frame:Hide()
        ENV.save.isVisible = false
    end)

    -- TITLE BAR
    local titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar = titleBar

    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(30)

    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")

    titleBar:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()

        -- Save frame's position
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
        ENV.save.position = {
            point = point,
            relativeTo = relativeTo and relativeTo:GetName() or nil,
            relativePoint = relativePoint,
            xOffset = xOffset,
            yOffset = yOffset,
        }
    end)
 
    -- TITLE BAR TEXT
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    titleBar.title = title

    title:SetFontObject("GameFontHighlight")
    title:SetPoint("CENTER", titleBar, "CENTER", 0, 5)
    title:SetText(ENV.Functions.getAddonNameString())

    -- Prevent the rest of the frame from being draggable
    frame:EnableMouse(true)
    frame:RegisterForDrag()

    -- BUTTON BAR
    local buttonBar = CreateFrame("Frame", nil, frame)
    frame.buttonBar = buttonBar

    buttonBar:SetSize(ENV.Config.ui.width - 20, 30)
    buttonBar:SetPoint("TOP", frame, "TOP", 0, -25)

    -- HOME BUTTON
    local homeButton = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    buttonBar.homeButton = homeButton

    homeButton:SetSize(50, 25)
    homeButton:SetPoint("LEFT", buttonBar, "LEFT", 0, 0)
    homeButton:SetText("Home")

    homeButton:SetScript("OnClick", function()
        ENV.UI.navigateTo({
            view = "home",
        })
    end)

    -- BACK BUTTON
    local backButton = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    buttonBar.backButton = backButton

    backButton:SetSize(50, 25)
    backButton:SetPoint("LEFT", homeButton, "RIGHT", 10, 0)
    backButton:SetText("<")
    backButton:Disable()

    -- Tooltip for back button
    backButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Back", 1, 1, 1)
        GameTooltip:Show()
    end)

    backButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    backButton:SetScript("OnClick", function()
        ENV.UI.navigateBack()
    end)

    -- NEXT BUTTON
    local nextButton = CreateFrame("Button", nil, buttonBar, "UIPanelButtonTemplate")
    buttonBar.nextButton = nextButton

    nextButton:SetSize(50, 25)
    nextButton:SetPoint("LEFT", backButton, "RIGHT", 0, 0)
    nextButton:SetText(">")
    nextButton:Disable()

    -- Tooltip for next button
    nextButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Next", 1, 1, 1)
        GameTooltip:Show()
    end)

    nextButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    nextButton:SetScript("OnClick", function()
        ENV.UI.navigateNext()
    end)

    -- SEARCH BOX
    local searchBox = CreateFrame("EditBox", nil, buttonBar, "InputBoxTemplate")
    buttonBar.searchBox = searchBox

    searchBox:SetSize(150, 25)
    searchBox:SetPoint("LEFT", nextButton, "RIGHT", 20, 0)
    searchBox:SetAutoFocus(false)

    -- Search box placeholder text
    local placeholderText = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    placeholderText:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
    placeholderText:SetText("Search")
    placeholderText:SetTextColor(0.5, 0.5, 0.5, 1)

    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- Show/Hide placeholder text based on input
    searchBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "" then
            placeholderText:Hide()
        end
    end)

    searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            placeholderText:Show()
        end
    end)

    searchBox:SetScript("OnTextChanged", function(self, userInput)
        if self:GetText() == "" then
            placeholderText:Show()
        else
            placeholderText:Hide()
        end

        -- Your live filtering or search logic here
        -- TODO
        print("Search Box Changed: ", self:GetText())
    end)

    -- SORT DROPDOWN
    local sortDropdown = CreateFrame("Frame", "SortDropdown", buttonBar, "UIDropDownMenuTemplate")
    buttonBar.sortDropdown = sortDropdown

    sortDropdown:SetPoint("RIGHT", buttonBar, "RIGHT", 20, -2)
    UIDropDownMenu_SetWidth(sortDropdown, 100)
    UIDropDownMenu_SetText(sortDropdown, "Sort")

    UIDropDownMenu_Initialize(sortDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        -- Sort by Name
        info.text = "Name"
        info.checked = true
        info.func = function()
            print("Sorting by Name")
        end
        UIDropDownMenu_AddButton(info)

        -- Sort by Skill Up
        info.text = "Skill Up"
        info.checked = false
        info.func = function()
            print("Sorting by Skill Up")
        end
        UIDropDownMenu_AddButton(info)
    end)

    -- FILTER DROPDOWN
    local filterDropdown = CreateFrame("Frame", "FilterDropdown", buttonBar, "UIDropDownMenuTemplate")
    buttonBar.filterDropdown = filterDropdown

    filterDropdown:SetPoint("RIGHT", sortDropdown, "LEFT", 30, 0)
    UIDropDownMenu_SetWidth(filterDropdown, 100)
    UIDropDownMenu_SetText(filterDropdown, "Filter")

    UIDropDownMenu_Initialize(filterDropdown, function(self, level, menuList)
        if level == 1 then
            -- Main menu options
            local info = UIDropDownMenu_CreateInfo()

            -- Source Menu
            info.text = "Source"
            info.hasArrow = true -- Indicates a submenu
            info.menuList = "SourceSubMenu" -- Submenu identifier
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

            -- Skill Up Menu
            info.text = "Skill Up"
            info.hasArrow = true
            info.menuList = "SkillUpSubMenu"
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)

        elseif level == 2 then
            -- Submenus
            local info = UIDropDownMenu_CreateInfo()

            if menuList == "SourceSubMenu" then
                -- Trainer
                info.text = "Trainer"
                info.checked = true
                info.func = function() print("Filter: Trainer") end
                UIDropDownMenu_AddButton(info, level)

                -- Vendor
                info.text = "Vendor"
                info.checked = true
                info.func = function() print("Filter: Vendor") end
                UIDropDownMenu_AddButton(info, level)

                -- Drop
                info.text = "Drop"
                info.checked = true
                info.func = function() print("Filter: Drop") end
                UIDropDownMenu_AddButton(info, level)

            elseif menuList == "SkillUpSubMenu" then
                -- Not Learned (Red)
                info.text = "|cFFFF0000Not Learned|r"
                info.checked = true
                info.func = function() print("Filter: Not Learned") end
                UIDropDownMenu_AddButton(info, level)

                -- Orange
                info.text = "|cFFFF8000Orange|r"
                info.checked = true
                info.func = function() print("Filter: Orange") end
                UIDropDownMenu_AddButton(info, level)

                -- Yellow
                info.text = "|cFFFFFF00Yellow|r"
                info.checked = true
                info.func = function() print("Filter: Yellow") end
                UIDropDownMenu_AddButton(info, level)

                -- Green
                info.text = "|cFF00FF00Green|r"
                info.checked = true
                info.func = function() print("Filter: Green") end
                UIDropDownMenu_AddButton(info, level)

                -- Gray
                info.text = "|cFF808080Gray|r"
                info.checked = true
                info.func = function() print("Filter: Gray") end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
end

this.initMinimapButton = function()
    local minimapButton = CreateFrame("Button", "MyAddonMinimapButton", Minimap)
    this.minimapButton = minimapButton

    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 10)

    minimapButton.icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    minimapButton.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Replace with your icon
    minimapButton.icon:SetSize(20, 20)
    minimapButton.icon:SetPoint("CENTER")

    minimapButton.border = minimapButton:CreateTexture(nil, "OVERLAY")
    minimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton.border:SetSize(54, 54)
    minimapButton.border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT")

    minimapButton:EnableMouse(true)
    minimapButton:SetMovable(true)

    minimapButton:SetScript("OnMouseDown", function()
        ENV.Functions.toggleFrame()
    end)

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(ENV.Functions.getAddonNameString(), 1, 1, 1)
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

this.initHomePanel = function()
    -- HOME FRAME
    local homePanel = CreateFrame("Frame", nil, frame)
    frame.homePanel = homePanel

    homePanel:Hide()

    --homePanel:SetSize(600, 380)
    homePanel:SetSize(ENV.Config.ui.width, ENV.Config.ui.height - 20)
    homePanel:SetPoint("LEFT", frame, "LEFT", 0, -10)

    -- HEADERS
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

this.initLeftPanel = function()
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

this.initRightPanel = function()
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