local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

this.initMainFrame = function()
    -- MAIN FRAME
    local frame = CreateFrame("Frame", addonName, UIParent, "BasicFrameTemplateWithInset")
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

this.initHomeFrame = function()

end

this.initLeftPanel = function()

end

this.initRightPanel = function()
    
end