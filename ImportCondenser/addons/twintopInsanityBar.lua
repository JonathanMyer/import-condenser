local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.TwintopInsanityBar = {}
-- ImportCondenser.db.global.TwintopInsanityBar = {}

local AllOptions = {
    "Core"
}
for i, className in ipairs(ImportCondenser.ClassNames) do
    table.insert(AllOptions, className)
end

function ImportCondenser.TwintopInsanityBar:GetExportOptions()
    return AllOptions, {[1] = UnitClass("player")}, true
end


function ImportCondenser.TwintopInsanityBar:DetectIssues(importString)
   if _G.Twintop_Data and _G.Twintop_Data.settings then
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        local returnList = {}
        for k, v in pairs(asTable) do
            table.insert(returnList, k:sub(1,1):upper() .. k:sub(2))
        end
        return {options = returnList}
    end 
end

function ImportCondenser.TwintopInsanityBar:Import(importString)
    if _G.Twintop_Data and _G.Twintop_Data.settings then
        local asTable = ImportCondenser:DeSeriPressCode(importString)
        for k, v in pairs(asTable) do
            if ImportCondenser.db.global.TwintopInsanityBar.selectedImportOptions[k] == true then
                ImportCondenser:CopyTable(v, _G.Twintop_Data.settings[k])
            end
        end
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
