local addonName, ENV = ...
ENV.Utility = ENV.Utility or {}
local this = ENV.Utility

this.inTable = function(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

this.serializeTable = function(tbl)
    local function serialize(tbl)
        local result = {}
        local sortedKeys = {}

        -- Collect and sort keys
        for k in pairs(tbl) do
            table.insert(sortedKeys, k)
        end
        table.sort(sortedKeys)

        -- Serialize key-value pairs
        for _, k in ipairs(sortedKeys) do
            local v = tbl[k]
            local key = tostring(k)
            local value = type(v) == "table" and serialize(v) or tostring(v)
            table.insert(result, key .. "=" .. value)
        end

        return "{" .. table.concat(result, ",") .. "}"
    end

    return serialize(tbl)
end

this.dumpTable = function(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. this.dumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end