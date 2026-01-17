local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.TwintopInsanityBar = {}

function ImportCondenser.TwintopInsanityBar:Import(importString)
    local settings = _G.Twintop_Data.settings
    if settings then
        print("Importing Twintop Insanity Bar settings...")
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        ImportCondenser:CopyTable(asTable, _G.Twintop_Data.settings)
    end
end

function ImportCondenser.TwintopInsanityBar:Export(table)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        table["TwintopInsanityBar"] = ImportCondenser:SeriPressCode(_G.Twintop_Data.settings)
    end
end
