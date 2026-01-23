local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.CooldownManagerCentered = {}

function ImportCondenser.CooldownManagerCentered:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.CooldownManagerCentered:Import(importString, profileName)
    local CMC = _G.CooldownManagerCentered
    if importString and profileName and CMC and type(CMC.ImportProfileFromString) == "function" then
        CMC:ImportProfileFromString(importString, profileName)
    end
end


function ImportCondenser.CooldownManagerCentered:Export(table)
    if ImportCondenser.db.global.CooldownManagerCentered.selectedExportOptions["Export"] ~= true then return end
    local CMC = _G.CooldownManagerCentered
    if CMC and type(CMC.ExportCurrentProfileToString) == "function" then
        local profile = CMC:ExportCurrentProfileToString()
        table["CooldownManagerCentered"] = profile
    end
end
