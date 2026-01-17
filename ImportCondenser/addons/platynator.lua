local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Platynator = {}

function ImportCondenser.Platynator:IsLoaded()
    return C_AddOns and C_AddOns.IsAddOnLoaded("Platynator") or (IsAddOnLoaded and IsAddOnLoaded("Platynator"))
end

function ImportCondenser.Platynator:Import(importString, profileName)
    _G.PLATYNATOR_CONFIG = _G.PLATYNATOR_CONFIG or {}
    _G.PLATYNATOR_CONFIG.Profiles = _G.PLATYNATOR_CONFIG.Profiles or {}
    _G.PLATYNATOR_CONFIG.Profiles[profileName] = importString
    _G.PLATYNATOR_CURRENT_PROFILE = profileName
end

function ImportCondenser.Platynator:Export(table)
    if _G.PLATYNATOR_CONFIG and _G.PLATYNATOR_CONFIG.Profiles then
        local platynatorProfile = _G.PLATYNATOR_CONFIG.Profiles[_G.PLATYNATOR_CURRENT_PROFILE]
        if platynatorProfile then
            table["Platynator"] = platynatorProfile
        end
    end
end
