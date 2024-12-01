local addonName, ENV = ...
ENV.Event = ENV.Event or {}
local this = ENV.Event

function this.onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        this.onAddonLoaded(self, ...)
    end
end

function this.onAddonLoaded(self, argAddonName)
    if addonName ~= argAddonName then
        return
    end

    self:UnregisterEvent("ADDON_LOADED")

    ENV.isLoaded = true
    
    ENV.PlayerProfession.load()

    ENV.UI.initMainFrame()
    ENV.UI.initMinimapButton()
    ENV.UI.initHomePanel()
    ENV.UI.initLeftPanel()
    ENV.UI.initRightPanel()

    if ENV.save.isVisible then
        ENV.UI.mainFrame:Show()
    else
        ENV.UI.mainFrame:Hide()
    end

    ENV.UI.navigateTo({
        view = "home",
    })

    print(ENV.Functions.getAddonNameString() .. " loaded! xdd")
end