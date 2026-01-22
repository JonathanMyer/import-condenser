local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.CooldownManagerCentered = {}

function ImportCondenser.CooldownManagerCentered:Import(importString, profileName)
    local CMC = _G.CooldownManagerCentered
    if importString and profileName and CMC and type(CMC.ImportProfileFromString) == "function" then
        print("importing CoodlownManagerCentered profile...")
        CMC:ImportProfileFromString(importString, profileName)
    end
end


function ImportCondenser.CooldownManagerCentered:Export(table)
    local CMC = _G.CooldownManagerCentered
    if CMC and type(CMC.ExportCurrentProfileToString) == "function" then
        local profile = CMC:ExportCurrentProfileToString()
        table["CooldownManagerCentered"] = profile
    end
end
