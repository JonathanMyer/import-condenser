local ADDON_NAME, ns       = ...
local ImportCondenser      = ns.Addon

ImportCondenser.EnhanceQoL = {}
local eQoL                 = _G.EnhanceQoL
local playerKey            = UnitGUID("player")

function ImportCondenser.EnhanceQoL:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.EnhanceQoL:Import(importString, profileName)
    local eqolDB = _G.EnhanceQoLDB
    if eqolDB and eQoL and profileName and playerKey and eqolDB.profiles and eqolDB.profileKeys and type(eQoL.importProfile) == "function" then
        ImportCondenser:AddToInspector(eqolDB, "EnhanceQoLDB")
        eqolDB.profiles[profileName] = eqolDB.profiles[profileName] or {}
        eqolDB.profileKeys[playerKey] = profileName
        eqolDB.profileGlobal = profileName
        local worked = eQoL.importProfile(importString)
        if not worked then
            print("|A:gmchat-icon-blizz:16:16|aEnhance|cff00c0ffQoL|r: Error importing profile.")
            return
        end
    end
end

function ImportCondenser.EnhanceQoL:Export(table)
    if ImportCondenser.db.global.EnhanceQoL.selectedExportOptions["Export"] ~= true then
        return
    end
    if eQoL and type(eQoL.exportProfile) == "function" then
        table["EnhanceQoL"] = eQoL:exportProfile()
    end
end
