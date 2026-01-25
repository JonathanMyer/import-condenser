local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.TwintopInsanityBar = {}
-- ImportCondenser.db.global.TwintopInsanityBar = {}

local EXPORT_STRING_PREFIX = "!TRB"

local classes = {
    [0] = "All Classes"
}
for i, className in ipairs(ImportCondenser.ClassNames) do
    table.insert(classes, className)
end

function ImportCondenser.TwintopInsanityBar:GetExportOptions()
    local args = {
        [1] = {name = "Classes", values = classes},
        [2] = "Core",
        [3] = "Bar Display",
        [4] = "Thresholds",
        [5] = "Font and Text",
        [6] = "Audio and Tracking",
        [7] = "Bar Text",
    }
    return args, {[1] = UnitClass("player")}, false
end


function ImportCondenser.TwintopInsanityBar:DetectIssues(importString)
    -- cant have issues if its a twintop generated string
    if EXPORT_STRING_PREFIX == importString:sub(1, #EXPORT_STRING_PREFIX) and
        _G.Twintop_API and
        _G.Twintop_API.ImportConfiguration and
        type(_G.Twintop_API.ImportConfiguration) == "function"
    then
        return nil
    end

   if _G.Twintop_Data and _G.Twintop_Data.settings then

        local asTable = ImportCondenser:DeSeriPressCode(importString)
        local returnList = {}
        for k, v in pairs(asTable) do
            table.insert(returnList, k:sub(1,1):upper() .. k:sub(2))
        end
        return {options = returnList, defaults = {[1] = UnitClass("player")}, storeAsLower = true}
    end 
end

function ImportCondenser.TwintopInsanityBar:Import(importString)
    if EXPORT_STRING_PREFIX == importString:sub(1, #EXPORT_STRING_PREFIX) and
        _G.Twintop_API and
        _G.Twintop_API.ImportConfiguration and
        type(_G.Twintop_API.ImportConfiguration) == "function"
    then
        _G.Twintop_API.ImportConfiguration(importString)
        return
    end

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
    if 
        _G.Twintop_API and
        _G.Twintop_API.ExportConfiguration and
        type(_G.Twintop_API.ExportConfiguration) == "function" and
        ImportCondenser.db.global.TwintopInsanityBar.selectedExportOptions
     then
        local exportOptions = ImportCondenser.db.global.TwintopInsanityBar.selectedExportOptions
        local barDisplay = exportOptions["Bar Display"] or false
        local thresholds = exportOptions["Thresholds"] or false
        local fontAndText = exportOptions["Font and Text"] or false    
        local audioAndTracking = exportOptions["Audio and Tracking"] or false
        local barText = exportOptions["Bar Text"] or false
        local class = exportOptions["Classes"] ~= 0 and exportOptions["Classes"] or nil
        local core = exportOptions["Core"] or false
        local newExport = _G.Twintop_API.ExportConfiguration(class, nil, barDisplay, thresholds, fontAndText, audioAndTracking, barText, core)
        table["TwintopInsanityBar"] = newExport
    end
end
