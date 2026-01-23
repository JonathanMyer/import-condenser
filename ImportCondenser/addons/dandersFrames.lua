local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.DandersFrames = {}

local exportFrameTypes = {party = true, raid = true}

function ImportCondenser.DandersFrames:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.DandersFrames:Import(importString, profileName)
    if _G.DandersFrames and
        type(_G.DandersFrames.ApplyImportedProfile) == "function" and
        type(_G.DandersFrames.ValidateImportString) == "function"
    then
        local profile = _G.DandersFrames:ValidateImportString(importString)
        _G.DandersFrames:ApplyImportedProfile(profile, nil, nil, profileName, true)
    end
end

function ImportCondenser.DandersFrames:Export(table)
    if ImportCondenser.db.global.DandersFrames.selectedExportOptions["Export"] ~= true then return end
    if _G.DandersFrames and type(_G.DandersFrames.ExportProfile) == "function" then
        table["DandersFrames"] = _G.DandersFrames:ExportProfile(nil, exportFrameTypes, nil)
    end
end
