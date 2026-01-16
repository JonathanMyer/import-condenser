local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

function ImportCondenser:ImportTwintopInsanityBar(importString)
    local settings = _G.Twintop_Data.settings
    if settings then
        print("Importing Twintop Insanity Bar settings...")
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        ImportCondenser:CopyTable(asTable, _G.Twintop_Data.settings)
    end
end

function ImportCondenser:ExportTwintopInsanityBar(table)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        table["TwintopInsanityBar"] = self:SeriPressCode(_G.Twintop_Data.settings)
    end
end
