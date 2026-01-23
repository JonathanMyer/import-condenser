local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Platynator = {}

function ImportCondenser.Platynator:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.Platynator:Import(importString, profileName)
    _G.PLATYNATOR_CONFIG = _G.PLATYNATOR_CONFIG or {}
    _G.PLATYNATOR_CONFIG.Profiles = _G.PLATYNATOR_CONFIG.Profiles or {}
    _G.PLATYNATOR_CONFIG.Profiles[profileName] = importString
    _G.PLATYNATOR_CURRENT_PROFILE = profileName
end

function ImportCondenser.Platynator:Export(table)
    if ImportCondenser.db.global.Platynator.selectedExportOptions["Export"] ~= true then return end
    if _G.PLATYNATOR_CONFIG and _G.PLATYNATOR_CONFIG.Profiles then
        local platynatorProfile = _G.PLATYNATOR_CONFIG.Profiles[_G.PLATYNATOR_CURRENT_PROFILE]
        if platynatorProfile then
            table["Platynator"] = platynatorProfile
        end
    end
end
