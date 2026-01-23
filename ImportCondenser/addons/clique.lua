local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Clique = {}

local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local class = UnitClassBase("player")

function ImportCondenser.Clique:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.Clique:Import(importString, profileName)
    local C = _G.Clique
    if C and
        C.db and
        C.db.profile and
        C.db.profiles and
        C.db.SetProfile and
        type(C.db.SetProfile) == "function"
    then
        local profile = ImportCondenser:DeSeriPressCode(importString)
        C.db:SetProfile(profileName)
        C.db.profiles[profileName] = profile or C.db.profile
    end
end

function ImportCondenser.Clique:Export(table)
    if ImportCondenser.db.global.Clique.selectedExportOptions["Export"] ~= true then
        return
    end
     local C = _G.Clique
    if C and
        C.db and
        C.db.profile
    then
        local profile = C.db.profile
        table["Clique"] = ImportCondenser:SeriPressCode(profile)
    end
end
