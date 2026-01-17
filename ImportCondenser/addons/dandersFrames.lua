local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

local exportFrameTypes = {party = true, raid = true}

function ImportCondenser:ImportDandersFrames(importString, profileName)
    if _G.DandersFrames and
        type(_G.DandersFrames.ApplyImportedProfile) == "function" and
        type(_G.DandersFrames.ValidateImportString) == "function"
    then
        print("Importing DandersFrames settings...")
        local profile = _G.DandersFrames:ValidateImportString(importString)
        _G.DandersFrames:ApplyImportedProfile(profile, nil, nil, profileName, true)
    end
end

function ImportCondenser:ExportDandersFrames(table)
    if _G.DandersFrames and type(_G.DandersFrames.ExportProfile) == "function" then
        table["DandersFrames"] = _G.DandersFrames:ExportProfile(nil, exportFrameTypes, nil)
    end
end
