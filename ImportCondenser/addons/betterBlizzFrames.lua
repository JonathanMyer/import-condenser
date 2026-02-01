local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.BetterBlizzFrames = {}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey

function ImportCondenser.BetterBlizzFrames:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.BetterBlizzFrames:Import(importString)
    local bbfDB = _G.BetterBlizzFramesDB
    if bbfDB and type(_G.BBF) == "table" and type(_G.BBF.ImportProfile) == "function" then
        local profileData, errorMessage = _G.BBF.OldImportProfile(importString, "fullProfile")
        if errorMessage then
            _G.BBF.Print(_G.BBF.L["Print_Error_Importing"] .. "Full Profile" .. ": " .. tostring(errorMessage))
            return
        end
        if not profileData then
            _G.BBF.Print(_G.BBF.L["Print_Error_Importing_Generic"])
            return
        end

        -- Replace existing data with imported data
        for k in pairs(bbfDB) do bbfDB[k] = nil end -- Clear current table
        for k, v in pairs(profileData) do
            bbfDB[k] = v                            -- Populate with new data
        end
        bbfDB.reopenOptions = true
    end
end

function ImportCondenser.BetterBlizzFrames:Export(table)
    local bbfDB = _G.BetterBlizzFramesDB
    if ImportCondenser.db.global.BetterBlizzFrames.selectedExportOptions["Export"] ~= true then
        return
    end
    if bbfDB and type(_G.BBF) == "table" and type(_G.BBF.ExportProfile) == "function" then
        table["BetterBlizzFrames"] = _G.BBF.ExportProfile(bbfDB, "fullProfile")
    end
end
