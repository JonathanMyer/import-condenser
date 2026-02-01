local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.BetterBlizzPlates = {}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey

function ImportCondenser.BetterBlizzPlates:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.BetterBlizzPlates:Import(importString)
    local bbpDB = _G.BetterBlizzPlatesDB
    if bbpDB and type(_G.BBP) == "table" and type(_G.BBP.ImportProfile) == "function" then
        local profileData, errorMessage = _G.BBP.OldImportProfile(importString, "fullProfile")
        if errorMessage then
            print("|A:gmchat-icon-blizz:16:16|aBetter|cff00c0ffBlizz|rPlates: Error importing " .. "Full Profile" .. ":",
                errorMessage)
            return
        end

        -- Replace existing data with imported data
        for k in pairs(bbpDB) do bbpDB[k] = nil end -- Clear current table
        for k, v in pairs(profileData) do
            bbpDB[k] = v                            -- Populate with new data
        end
        bbpDB.reopenOptions = true
    end
end

function ImportCondenser.BetterBlizzPlates:Export(table)
    local bbpDB = _G.BetterBlizzPlatesDB
    if ImportCondenser.db.global.BetterBlizzPlates.selectedExportOptions["Export"] ~= true then
        return
    end
    if bbpDB and type(_G.BBP) == "table" and type(_G.BBP.ExportProfile) == "function" then
        table["BetterBlizzPlates"] = _G.BBP.ExportProfile(bbpDB, "fullProfile")
    end
end
