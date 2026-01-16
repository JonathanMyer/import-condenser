local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

function ImportCondenser:ImportTwintopInsanityBar(importString)
    local settings = _G.Twintop_Data.settings
    if settings then
        print("Importing Twintop Insanity Bar settings...")
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        ImportCondenser:AddToInspector(asTable, "TwintopInsanityBar Import")
        ImportCondenser:CopyTable(asTable, _G.Twintop_Data.settings)
        ImportCondenser:AddToInspector(settings, "TwintopInsanityBar Post Import")
    end
end

function ImportCondenser:ExportTwintopInsanityBar(table)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        table["TwintopInsanityBar"] = self:SeriPressCode(_G.Twintop_Data.settings)
    end
end
