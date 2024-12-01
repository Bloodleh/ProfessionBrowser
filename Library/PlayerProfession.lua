local addonName, ENV = ...
ENV.PlayerProfession = ENV.PlayerProfession or {}
local this = ENV.PlayerProfession

this.PRIMARY_PROFESSION_LIST = {
    "Alchemy",
    "Blacksmithing",
    "Enchanting",
    "Engineering",
    "Herbalism",
    "Leatherworking",
    "Mining",
    "Skinning",
    "Tailoring",
}

this.SECONDARY_PROFESSION_LIST = {
    "First Aid",
    "Cooking",
    "Fishing",
}

this.primaryProfessions = {}
this.secondaryProfessions = {}

this.load = function()
    local num = GetNumSkillLines()
    for skillIndex = 1, num do
        local name, _, _, level, _, _, maxLevel = GetSkillLineInfo(skillIndex)

        if ENV.Utility.inTable(this.PRIMARY_PROFESSION_LIST, name) then
            print("Player has primary profession " .. name .. " (" .. level .. "/" .. maxLevel .. ")!")
            table.insert(this.primaryProfessions, {
                skillIndex = skillIndex,
                name = name,
                level = level,
                maxLevel = maxLevel,
            })
        elseif ENV.Utility.inTable(this.SECONDARY_PROFESSION_LIST, name) then
            print("Player has secondary profession " .. name .. " (" .. level .. "/" .. maxLevel .. ")!")
            table.insert(this.secondaryProfessions, {
                skillIndex = skillIndex,
                name = name,
                level = level,
                maxLevel = maxLevel,
            })
        end
    end
end

this.getPrimaryProfession = function(name)
    for _, v in ipairs(this.primaryProfessions) do
        if v.name == name then
            return v
        end
    end
    return nil
end

this.getSecondaryProfession = function(name)
    for _, v in ipairs(this.secondaryProfessions) do
        if v.name == name then
            return v
        end
    end
    return nil
end

this.getProfession = function(name)
    local pp = this.getPrimaryProfession(name)

    if pp then
        return pp
    end

    local sp = this.getSecondaryProfession(name)

    if sp then
        return sp
    end

    return nil
end