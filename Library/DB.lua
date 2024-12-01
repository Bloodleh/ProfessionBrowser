local addonName, ENV = ...
ENV.DB = ENV.DB or {}
local this = ENV.DB

this.cache = {}

this.eventFrame = CreateFrame("Frame")

this.init = function()
    local categories = {
        "Blacksmithing",
        "Engineering",
        "Materials",
        "Tailoring",
    }

    for _, category in ipairs(categories) do
        local dataStore = ENV.Data[category] or {}

        if not this.cache[category] then
            this.cache[category] = {}
        end

        for itemId, item in pairs(dataStore) do
            this.cache[category][itemId] = {
                spellId = item.spellId,
                count = item.count,
                type = item.type,
                lvl = item.lvl,
                mats = item.mats,
            }
        end
    end

    return this
end

this.getItem = function(category, itemId, callback)
    -- Invalid item
    if not this.cache[category] or not this.cache[category][itemId] then
        return callback(nil)
    end

    local item = this.cache[category][itemId]

    -- If name already exists, the item info has already been retrieved using GetItemInfo
    if item.name then
        return callback(item)
    end

    local ok = this._getItemInfo(itemId, item)

    if ok then
        return callback(item)
    end

    -- Wait for item data to load
    this.eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    this.eventFrame:SetScript("OnEvent", function(self, event, receivedItemId)
        if receivedItemId ~= itemId then
            return
        end

        local ok = this._getItemInfo(itemId, item)

        self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        self:SetScript("OnEvent", nil)

        return callback(ok and item or nil)
    end)
end

this._getItemInfo = function(itemId, item)
    local name, link, quality, _, _, type, subType, _, _, icon, _, _, _, _, _, _, isMat = GetItemInfo(itemId)

    if name then
        item.name = name
        item.link = link
        item.quality = quality
        item.infoType = type
        item.infoSubType = subType
        item.iconId = icon
        item.isMat = isMat

        return true
    end

    return false
end