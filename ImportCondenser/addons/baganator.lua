local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Baganator = {}

function ImportCondenser.Baganator:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.Baganator:Import(importString, profileName)
    _G.BAGANATOR_CONFIG = _G.BAGANATOR_CONFIG or {}
    _G.BAGANATOR_CONFIG.Profiles = _G.BAGANATOR_CONFIG.Profiles or {}
    _G.BAGANATOR_CONFIG.Profiles[profileName] = importString
    _G.BAGANATOR_CURRENT_PROFILE = profileName
end

function ImportCondenser.Baganator:Export(table)
    if ImportCondenser.db.global.Baganator.selectedExportOptions["Export"] ~= true then
        return
    end
    if _G.BAGANATOR_CONFIG and _G.BAGANATOR_CONFIG.Profiles then
        local baganatorProfile = _G.BAGANATOR_CONFIG.Profiles[_G.BAGANATOR_CURRENT_PROFILE]
        if baganatorProfile then
            table["Baganator"] = baganatorProfile
        end
    end
end
