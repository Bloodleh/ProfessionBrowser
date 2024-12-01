local addonName, ENV = ...
local this = ENV

save = save or {
    -- Default save
    isVisible = false,
    backStack = this.Stack:new(),
    nextStack = this.Stack:new(),
    viewData = nil,
    position = nil,
}

db = db or this.DB.init()

this.save = save
this.db = db

this.isLoaded = false

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", this.Event.onEvent)

SLASH_PROFESSIONBROWSER1 = "/professionbrowser"
SLASH_PROFESSIONBROWSER2 = "/pb"
SlashCmdList["PROFESSIONBROWSER"] = function(msg)
    this.Functions.toggleFrame()
end