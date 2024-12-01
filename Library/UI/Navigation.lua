local addonName, ENV = ...
ENV.UI = ENV.UI or {}
local this = ENV.UI

this.navigateTo = function(viewData)
    -- Avoid duplicates
    if ENV.save.viewData ~= nil then
        local serializedViewData = ENV.Utility.serializeTable(viewData)
        local serializedSaveViewData = ENV.Utility.serializeTable(ENV.save.viewData)

        if serializedViewData == serializedSaveViewData then
            return
        end
    end

    if ENV.save.viewData then
        ENV.save.backStack:push(ENV.save.viewData)
    end

    ENV.save.viewData = viewData
    ENV.save.nextStack = ENV.Stack:new()
    this._updateView()
end

this.navigateBack = function()
    if not ENV.save.backStack:isEmpty() then
        ENV.save.nextStack:push(ENV.save.viewData)
        ENV.save.viewData = ENV.save.backStack:pop()
        this._updateView()
    else
        assert(false, "No views in backStack")
    end
end

this.navigateNext = function()
    if not ENV.save.nextStack:isEmpty() then
        ENV.save.backStack:push(ENV.save.viewData)
        ENV.save.viewData = ENV.save.nextStack:pop()
        this._updateView()
    else
        assert(false, "No views in nextStack")
    end
end

this._updateView = function()
    local data = ENV.save.viewData

    this._setButtonStates()

    if data.view == "home" then
        this._showHomeView()
    elseif data.view == "profession" then
        this._showProfessionView(data.category, data.itemId)
    else
        assert(false, "Invalid view")
    end
end

this._setButtonStates = function()
    local ui = ENV.UI

    if ENV.save.backStack:isEmpty() then
        ui.frame.buttonBar.backButton:Disable()
    else
        ui.frame.buttonBar.backButton:Enable()
    end

    if ENV.save.nextStack:isEmpty() then
        ui.frame.buttonBar.nextButton:Disable()
    else
        ui.frame.buttonBar.nextButton:Enable()
    end
end

this._showHomeView = function()
    ENV.UI.frame.homePanel:Show()
    ENV.UI.frame.leftPanel:Hide()
    ENV.UI.frame.rightPanel:Hide()
    ENV.UI.frame.buttonBar.searchBox:Disable()
end

this._showProfessionView = function(category, itemId)
    ENV.UI.frame.homePanel:Hide()
    ENV.UI.frame.leftPanel:Show()
    ENV.UI.frame.rightPanel:Show()
    ENV.UI.frame.buttonBar.searchBox:Enable()

    if itemId then
        -- TODO
    else
        -- TODO
    end
end