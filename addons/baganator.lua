local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

function ImportCondenser:ImportBaganator(importString, profileName)
    _G.BAGANATOR_CONFIG = _G.BAGANATOR_CONFIG or {}
    _G.BAGANATOR_CONFIG.Profiles = _G.BAGANATOR_CONFIG.Profiles or {}
    _G.BAGANATOR_CONFIG.Profiles[profileName] = importString
    _G.BAGANATOR_CURRENT_PROFILE = profileName
end

function ImportCondenser:ExportBaganator(table)
    print("Exporting Baganator profile...")
    if _G.BAGANATOR_CONFIG and _G.BAGANATOR_CONFIG.Profiles then
        local baganatorProfile = _G.BAGANATOR_CONFIG.Profiles[_G.BAGANATOR_CURRENT_PROFILE]
        if baganatorProfile then
            table["Baganator"] = baganatorProfile
        end
    end
end
