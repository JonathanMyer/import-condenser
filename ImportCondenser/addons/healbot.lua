local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Healbot = {}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local SkinVars = {
    'Author', 'DuplicateBars',
    'Adaptive', 'AdaptiveOrder', 'Chat', 'Enemy', 'FocusGroups', 'General', 'Healing',
    'AdaptiveCol', 'CustomCols',
    'Anchors', 'BarAggro', 'BarCol', 'BarIACol', 'BarSort', 'BarText', 'BarTextCol', 'BarVisibility', 'Emerg', 'Frame', 'FrameAlias',
    'FrameAliasBar', 'HeadBar', 'HeadText', 'HealBar', 'HealGroups', 'Icons', 'IconText', 'Indicators', 'RaidIcon', 'StickyFrames',
    'IconSets', 'IconSetsText',
    'Overlay',
    'Bar', 'BarText'
}

local function IsInList(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end


function ImportCondenser.Healbot:GetExportOptions()
    local sType=1
    local returnList = {}
    if _G.Healbot_Config_Skins and _G.Healbot_Config_Skins.Skins then
        for k, v in pairs(_G.Healbot_Config_Skins.Skins) do
            table.insert(returnList, v)
        end
    end
    return returnList, {}, false
end

function ImportCondenser.Healbot:DetectIssues(importString)
   if ImportCondenser:IsAddonLoaded("Healbot") and importString and type(importString) == "table" then
        local returnList = {}
        for k, v in pairs(importString) do
            table.insert(returnList, k:sub(1,1):upper() .. k:sub(2))
        end
        return {options = returnList, defaults = {}, storeAsLower = false}
    end 
end

function ImportCondenser.Healbot:Import(importString)
    local profileList = {}
    if type(importString) == "table" then
        profileList = importString
        for profileName, v in pairs(profileList) do
            local profile = ImportCondenser:DeSeriPressCode(v)
            if ImportCondenser.db.global.Healbot.selectedImportOptions[profileName] == true then
                for _, varName in ipairs(SkinVars) do
                    if _G.Healbot_Config_Skins[varName] and type(_G.Healbot_Config_Skins[varName]) == "table" then
                        _G.Healbot_Config_Skins[varName][profileName] = _G.Healbot_Config_Skins[varName][profileName] or {}
                        ImportCondenser:CopyTable(profile[varName], _G.Healbot_Config_Skins[varName][profileName])
                    end
                end
                if _G.Healbot_Config_Skins.Skins then
                    local found = IsInList(_G.Healbot_Config_Skins.Skins, profileName)
                    if not found then
                        table.insert(_G.Healbot_Config_Skins.Skins, profileName)
                    end
                end
            end
        end
    end
end


function ImportCondenser.Healbot:Export(table)
    local sType=1
    if _G.Healbot_Config_Skins
    then
        local profileList = {}
        for k, v in pairs(ImportCondenser.db.global.Healbot.selectedExportOptions) do
            if v == true and IsInList(_G.Healbot_Config_Skins.Skins, k) then
                profileList[k] = {}
                for _, varName in ipairs(SkinVars) do
                    if _G.Healbot_Config_Skins[varName] and type(_G.Healbot_Config_Skins[varName]) == "table" then
                        profileList[k][varName] = {}
                        ImportCondenser:CopyTable(_G.Healbot_Config_Skins[varName][k], profileList[k][varName])
                    end
                end
                profileList[k] = ImportCondenser:SeriPressCode(profileList[k])
            end
        end
        table["Healbot"] = profileList
    end
end
