local addonName, ENV = ...
ENV.Functions = ENV.Functions or {}
local this = ENV.Functions

this.getAddonNameString = function()
    return ENV.Config.addon.name .. " v" .. ENV.Config.addon.version
end

this.toggleFrame = function()
    if ENV.save.isVisible then
        ENV.UI.mainFrame:Hide()
        ENV.save.isVisible = false
    else
        ENV.UI.mainFrame:Show()
        ENV.save.isVisible = true
    end
end