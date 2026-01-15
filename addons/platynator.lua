local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

function ImportCondenser:ImportPlatynatory(importString, profileName)
    _G.PLATYNATOR_CONFIG = _G.PLATYNATOR_CONFIG or {}
    _G.PLATYNATOR_CONFIG.Profiles = _G.PLATYNATOR_CONFIG.Profiles or {}
    _G.PLATYNATOR_CONFIG.Profiles[profileName] = importString
    _G.PLATYNATOR_CURRENT_PROFILE = profileName
end

function ImportCondenser:ExportPlatynatory(table)
    print("Exporting Platynatory profile...")
    if _G.PLATYNATOR_CONFIG and _G.PLATYNATOR_CONFIG.Profiles then
        local platynatorProfile = _G.PLATYNATOR_CONFIG.Profiles[_G.PLATYNATOR_CURRENT_PROFILE]
        if platynatorProfile then
            table["platynator"] = platynatorProfile
        end
    end
end
