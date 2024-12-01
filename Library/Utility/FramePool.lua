local addonName, ENV = ...
ENV.FramePool = ENV.FramePool or {}
local this = ENV.FramePool

this.pool = {}

function this:acquire(parent)
    local frame = table.remove(this.pool)

    if not frame then
        -- Nothing in the pool; create a new one
        frame = CreateFrame("Frame", nil, parent)
    else
        -- Get from the pool
        frame:SetParent(parent)
    end

    frame:Show()

    frame:SetFrameStrata(parent:GetFrameStrata())
    frame:SetFrameLevel(parent:GetFrameLevel() + 1)

    return frame
end

function this:release(frame)
    assert(not not frame, "Trying to release a nil frame!")

    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)

    frame:SetScript("OnClick", nil)
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
    frame:SetScript("OnEvent", nil)

    frame:UnregisterAllEvents()

    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)

    table.insert(this.pool, frame)
end