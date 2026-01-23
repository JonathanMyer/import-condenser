local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.MidnightSimpleUnitFrames = {}

function ImportCondenser.MidnightSimpleUnitFrames:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.MidnightSimpleUnitFrames:Import(importString, profileName)
    if importString and profileName and
        type(_G.MSUF_Profiles_ImportFromString) == "function" and
        type(_G.MSUF_CreateProfile) == "function" and
        type(_G.MSUF_SwitchProfile) == "function"
    then
        _G.MSUF_CreateProfile(profileName)
        _G.MSUF_SwitchProfile(profileName)
        _G.MSUF_Profiles_ImportFromString(importString)
    end
end


function ImportCondenser.MidnightSimpleUnitFrames:Export(table)
    if ImportCondenser.db.global.MidnightSimpleUnitFrames.selectedExportOptions["Export"] ~= true then return end
    if type(_G.MSUF_Profiles_ExportSelectionToString) == "function" then
        local profile = _G.MSUF_Profiles_ExportSelectionToString("all")
        table["MidnightSimpleUnitFrames"] = profile
    end
end
