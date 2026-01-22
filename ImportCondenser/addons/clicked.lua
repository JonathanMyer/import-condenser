local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Clicked = {}

local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local class = UnitClassBase("player")

function ImportCondenser.Clicked:Import(importString, profileName)
    local C = _G.Clicked
    local CDB = _G.ClickedDB
    if C and
        CDB and
        CDB.global and
        CDB.profiles and
        CDB.profileKeys and
        charKey and
        CDB.profileKeys[charKey]
    then
        local table = ImportCondenser:DeSeriPressCode(importString)
        local profile = table.profile
        local global = table.global
        CDB.profiles[class] = profile
        CDB.global = global
        CDB.profileKeys[charKey] = class
    end
end

function ImportCondenser.Clicked:Export(table)
    local C = _G.Clicked
    local CDB = _G.ClickedDB
    if C and
        type(C.SerializeProfile) == "function" and
        CDB and
        CDB.global and
        CDB.profiles and
        CDB.profileKeys and
        charKey and
        CDB.profileKeys[charKey]
    then
        local profileName = CDB.profileKeys[charKey]
        local profile = CDB.profiles[profileName]
        local global = CDB.global
        table["Clicked"] = ImportCondenser:SeriPressCode({
            profile = profile,
            global = global,
        })
    end
end
