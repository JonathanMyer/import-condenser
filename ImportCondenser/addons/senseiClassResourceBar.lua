local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.SenseiClassResourceBar = {}
local AceAddon = LibStub("AceAddon-3.0", true)

function ImportCondenser.SenseiClassResourceBar:Import(importString, profileName)
    local SCRB = _G.SenseiClassResourceBar
    if importString and profileName and SCRB and type(SCRB.ImportProfileFromString) == "function" then
        print("importing SenseiClassResourceBar profile...")
        SCRB:ImportProfileFromString(importString, profileName)
    end
end


function ImportCondenser.SenseiClassResourceBar:Export(table)
    print("exporting SenseiClassResourceBar profile...")
    local SCRB = _G.SenseiClassResourceBarDB
    if SCRB then
        ImportCondenser:AddToInspector(SCRB, "SenseiClassResourceBar")
    end
    if SCRB and type(SCRB.ExportCurrentProfileToString) == "function" then
        local profile = SCRB:ExportCurrentProfileToString()
        table["SenseiClassResourceBar"] = profile
    end
end
