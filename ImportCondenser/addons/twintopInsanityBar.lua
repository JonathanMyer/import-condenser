local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.TwintopInsanityBar = {}
-- ImportCondenser.db.global.TwintopInsanityBar = {}

function ImportCondenser.TwintopInsanityBar:GetOptions()
    local higherOptions = {
        "core"
    }
    for i, className in ipairs(ImportCondenser.ClassNames) do
        table.insert(higherOptions, className)
    end
    ImportCondenser:AddToInspector(higherOptions, "TwintopInsanityBar")
    return higherOptions
end

function ImportCondenser.TwintopInsanityBar:DetectIssues(importString)
   if _G.Twintop_Data and _G.Twintop_Data.settings then
        local asTable = ImportCondenser:DeSeriPressCode(importString)
    end 
end

function ImportCondenser.TwintopInsanityBar:Import(importString)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        print("Importing Twintop Insanity Bar settings...")
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        ImportCondenser:CopyTable(asTable, _G.Twintop_Data.settings)
    end
end

function ImportCondenser.TwintopInsanityBar:Export(table)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        local exportTable = {}
        for k, v in pairs(_G.Twintop_Data.settings) do
            if ImportCondenser.db.global.TwintopInsanityBar.selectedExportOptions[k] == true then
                exportTable[k] = v
            end
        end
        table["TwintopInsanityBar"] = ImportCondenser:SeriPressCode(exportTable)
    end
end
