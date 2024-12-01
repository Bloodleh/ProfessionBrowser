local addonName, ENV = ...

ENV.Config = {
    addon = {
        name = "Profession Browser",
        version = "0.1",
    },
    ui = {
        width = 600,
        height = 400,
        leftPanelRatio = 0.4,
        font = "Fonts\\FRIZQT__.TTF",
    },
    homeItems = {
        primaryProfessions = {
            { name = "Alchemy", icon = "Interface\\Icons\\Trade_Alchemy" },
            { name = "Blacksmithing", icon = "Interface\\Icons\\Trade_BlackSmithing" },
            { name = "Enchanting", icon = "Interface\\Icons\\Trade_Engraving" },
            { name = "Engineering", icon = "Interface\\Icons\\Trade_Engineering" },
            { name = "Herbalism", icon = "Interface\\Icons\\Trade_Herbalism" },
            { name = "Leatherworking", icon = "Interface\\Icons\\Trade_Leatherworking" },
            { name = "Mining", icon = "Interface\\Icons\\Trade_Mining" },
            { name = "Skinning", icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01" },
            { name = "Tailoring", icon = "Interface\\Icons\\Trade_Tailoring" },
        },
        secondaryProfessions = {
            { name = "Cooking", icon = "Interface\\Icons\\INV_Misc_Food_15" },
            { name = "Fishing", icon = "Interface\\Icons\\Trade_Fishing" },
            { name = "First Aid", icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice" },
        },
        other = {
            { name = "Materials", icon =  "Interface\\Icons\\inv_fabric_wool_01" },
        },
    },
}