local ADDON_NAME, ns                      = ...
local ImportCondenser                     = ns.Addon

ImportCondenser.HarreksAdvancedRaidFrames = {}

function ImportCondenser.HarreksAdvancedRaidFrames:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.HarreksAdvancedRaidFrames:Import(importStr)
    if _G.HARFDB then
        _G.HARFDB = ImportCondenser:DeSeriPressCode(importStr) or _G.HARFDB
        return
    end
end

function ImportCondenser.HarreksAdvancedRaidFrames:Export(exports)
    if ImportCondenser.db.global.HarreksAdvancedRaidFrames.selectedExportOptions["Export"] ~= true then return end
    if _G.HARFDB then
        exports["HarreksAdvancedRaidFrames"] = ImportCondenser:SeriPressCode(_G.HARFDB)
    end
end
