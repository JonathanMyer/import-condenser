local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Healbot = {}

local SkinVars={'Author', 'DuplicateBars'}
local SkinTVars={'Adaptive', 'AdaptiveOrder', 'Chat', 'Enemy', 'FocusGroups', 'General', 'Healing'}
local SkinTNVars={'AdaptiveCol', 'CustomCols'}
local SkinTFVars={'Anchors', 'BarAggro', 'BarCol', 'BarIACol', 'BarSort', 'BarText', 'BarTextCol', 'BarVisibility', 'Emerg', 'Frame', 'FrameAlias',
                        'FrameAliasBar', 'HeadBar', 'HeadText', 'HealBar', 'HealGroups', 'Icons', 'IconText', 'Indicators', 'RaidIcon', 'StickyFrames'}
local SkinTIconFSVars={"IconSets", "IconSetsText"}
local SkinTAuxFVars={'Overlay'}
local SkinTAuxFBVars={"Bar", "BarText"}
-- Extra Tables for Skins (Global tables indexed by skin name)
local SkinExtraVars = {'HealBot_Skins_ActionIcons', 'HealBot_Skins_ActionIconsData'}

local SpecialExports = {
    SPELLS = "[Global] Spells",
    BUFFS = "[Global] Custom Buffs",
    DEBUFFS = "[Global] Custom Debuffs",
    COLORS = "[Global] Preset Colors"
}

-- Tables to export for each special type
local BuffGlobals = { "WatchHoT", "CustomBuffs", "CustomBuffsShowBarCol", "CustomBuffBarColour", "CustomBuffIDMethod", "CustomBuffTag", "CustomBuffsIconSet", "CustomBuffsIconGlow", "CustomBuffsFilter", "IgnoreCustomBuff" }
local DebuffGlobals = { "CustomDebuffs", "Custom_Debuff_Categories", "FilterCustomDebuff", "CustomDebuffsShowBarCol", "CDCBarColour", "CustomDebuffIDMethod", "CDCTag", "CustomDebuffsIconSet", "CustomDebuffsIconGlow", "CustomDebuffsFilter", "IgnoreCustomDebuff" }
local ColorGlobals = { "PresetColoursAlias", "PresetColours" }
local SpellConfig = { "EnabledKeyCombo", "EnemyKeyCombo", "EmergKeyCombo" }


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
    
    -- Skins
    if _G.Healbot_Config_Skins and _G.Healbot_Config_Skins.Skins then
        for k, v in pairs(_G.Healbot_Config_Skins.Skins) do
            table.insert(returnList, v)
        end
    end

    -- Globals
    table.insert(returnList, SpecialExports.SPELLS)
    table.insert(returnList, SpecialExports.BUFFS)
    table.insert(returnList, SpecialExports.DEBUFFS)
    table.insert(returnList, SpecialExports.COLORS)

    return returnList, {}, false
end

function ImportCondenser.Healbot:DetectIssues(importString)
   if ImportCondenser:IsAddonLoaded("Healbot") and importString and type(importString) == "table" then
        local returnList = {}
        for k, v in pairs(importString) do
            table.insert(returnList, k)
        end
        return {options = returnList, defaults = {}, storeAsLower = false}
    end 
end

function ImportCondenser.Healbot:Import(importString)
    local HBSkins = _G.Healbot_Config_Skins
    local HBAux = _G.Healbot_Config_Aux
    local HBGlobals = _G.HealBot_Globals
    local HBSpells = _G.HealBot_Config_Spells

    if not HBSkins or not HBAux then return end

    local profileList = {}
    if type(importString) == "table" then
        profileList = importString
        ImportCondenser:AddToInspector(ImportCondenser.db.global.Healbot.selectedImportOptions, "Healbot Import Options")
        for profileName, v in pairs(profileList) do
            print("importing healbot profile: "..profileName)
            local profile = ImportCondenser:DeSeriPressCode(v)
            if ImportCondenser.db.global.Healbot.selectedImportOptions[profileName] == true then
                
                if profileName == SpecialExports.SPELLS and HBSpells then
                    for _, varName in ipairs(SpellConfig) do
                        if profile[varName] then
                            HBSpells[varName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBSpells[varName])
                        end
                    end
                elseif profileName == SpecialExports.BUFFS and HBGlobals then
                    for _, varName in ipairs(BuffGlobals) do
                        if profile[varName] then
                            HBGlobals[varName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBGlobals[varName])
                        end
                    end
                elseif profileName == SpecialExports.DEBUFFS and HBGlobals then
                    for _, varName in ipairs(DebuffGlobals) do
                        if profile[varName] then
                            HBGlobals[varName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBGlobals[varName])
                        end
                    end
                elseif profileName == SpecialExports.COLORS and HBGlobals then
                    for _, varName in ipairs(ColorGlobals) do
                         if profile[varName] then
                            HBGlobals[varName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBGlobals[varName])
                        end
                    end
                else
                    -- Assume Skin
                    -- Ensure root tables for skin exist
                    if not HBSkins.Skins then HBSkins.Skins = {} end
                    local found = IsInList(HBSkins.Skins, profileName)
                    if not found then
                        table.insert(HBSkins.Skins, profileName)
                    end

                    -- Simple Vars
                    for _, varName in ipairs(SkinVars) do
                    if profile[varName] ~= nil then -- string or bool
                            if not HBSkins[varName] then HBSkins[varName] = {} end
                            HBSkins[varName][profileName] = profile[varName]
                    end
                    end

                    -- Table Vars
                    for _, varName in ipairs(SkinTVars) do
                        if profile[varName] then
                            if not HBSkins[varName] then HBSkins[varName] = {} end
                            HBSkins[varName][profileName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBSkins[varName][profileName])
                        end
                    end

                    -- Named Table Vars
                    for _, varName in ipairs(SkinTNVars) do
                        if profile[varName] then
                            if not HBSkins[varName] then HBSkins[varName] = {} end
                            HBSkins[varName][profileName] = {}
                            ImportCondenser:CopyTable(profile[varName], HBSkins[varName][profileName])
                        end
                    end

                    -- Frame Vars
                    for _, varName in ipairs(SkinTFVars) do
                        if profile[varName] then
                            if not HBSkins[varName] then HBSkins[varName] = {} end
                            if not HBSkins[varName][profileName] then HBSkins[varName][profileName] = {} end
                            
                            -- Frames 1-10
                            if profile[varName].Frames then
                                for frameID, frameData in pairs(profile[varName].Frames) do
                                    frameID = tonumber(frameID)
                                    if frameID and frameData then
                                        HBSkins[varName][profileName][frameID] = {}
                                        ImportCondenser:CopyTable(frameData, HBSkins[varName][profileName][frameID])
                                    end
                                end
                            end

                            -- HealGroups 11-15
                            if varName == 'HealGroups' and profile[varName].Groups then
                                for gID, groupData in pairs(profile[varName].Groups) do
                                    gID = tonumber(gID)
                                    if gID and groupData then
                                    HBSkins[varName][profileName][gID] = {}
                                        ImportCondenser:CopyTable(groupData, HBSkins[varName][profileName][gID])
                                    end
                                end
                            end
                        end
                    end

                    -- Aux Frame Vars (Overlay)
                    for _, varName in ipairs(SkinTAuxFVars) do
                        if profile[varName] then
                            if not HBAux[varName] then HBAux[varName] = {} end
                            if not HBAux[varName][profileName] then HBAux[varName][profileName] = {} end

                            if profile[varName].Frames then
                                for frameID, frameData in pairs(profile[varName].Frames) do
                                    frameID = tonumber(frameID)
                                    if frameID and frameData then
                                        HBAux[varName][profileName][frameID] = {}
                                        ImportCondenser:CopyTable(frameData, HBAux[varName][profileName][frameID])
                                    end
                                end
                            end
                        end
                    end

                    -- Aux Frame Bar Vars (Bar, BarText)
                    for _, varName in ipairs(SkinTAuxFBVars) do
                        if profile[varName] then
                            if not HBAux[varName] then HBAux[varName] = {} end
                            if not HBAux[varName][profileName] then HBAux[varName][profileName] = {} end
                            
                            if profile[varName].Frames then
                                for frameID, frameData in pairs(profile[varName].Frames) do
                                    frameID = tonumber(frameID)
                                    if frameID and frameData then
                                        HBAux[varName][profileName][frameID] = {} -- Should be existing map of ids?
                                        for id, idData in pairs(frameData) do
                                            id = tonumber(id)
                                            if id and idData then
                                                -- Ensure subtable
                                                if not HBAux[varName][profileName][frameID] then HBAux[varName][profileName][frameID] = {} end
                                                HBAux[varName][profileName][frameID][id] = {}
                                                ImportCondenser:CopyTable(idData, HBAux[varName][profileName][frameID][id])
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Icon Frame Vars
                    for _, varName in ipairs(SkinTIconFSVars) do
                        if profile[varName] then
                            if not HBSkins[varName] then HBSkins[varName] = {} end
                            if not HBSkins[varName][profileName] then HBSkins[varName][profileName] = {} end
                            
                            if profile[varName].Frames then
                                for frameID, frameData in pairs(profile[varName].Frames) do
                                    frameID = tonumber(frameID)
                                    if frameID and frameData then
                                        -- HBSkins[varName][profileName][frameID] might not exist yet
                                        if not HBSkins[varName][profileName][frameID] then HBSkins[varName][profileName][frameID] = {} end
                                        
                                        for id, idData in pairs(frameData) do
                                            id = tonumber(id)
                                            if id and idData then
                                                HBSkins[varName][profileName][frameID][id] = {}
                                                ImportCondenser:CopyTable(idData, HBSkins[varName][profileName][frameID][id])
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Extra Global Vars (ActionIcons)
                    for _, varName in ipairs(SkinExtraVars) do
                        if profile[varName] then
                            local globalTable = _G[varName]
                            if globalTable then
                                globalTable[profileName] = {}
                                ImportCondenser:CopyTable(profile[varName], globalTable[profileName])
                            end
                        end
                    end
                end -- End Skin Import
            end
        end
    end
end


function ImportCondenser.Healbot:Export(table)
    local HBSkins = _G.Healbot_Config_Skins
    local HBAux = _G.Healbot_Config_Aux
    local HBGlobals = _G.HealBot_Globals
    local HBSpells = _G.HealBot_Config_Spells

    if HBSkins and HBSkins.Skins then
        local profileList = {}
        for k, v in pairs(ImportCondenser.db.global.Healbot.selectedExportOptions) do
            if v == true then
                local pName = k
                local isSpecial = false

                if pName == SpecialExports.SPELLS and HBSpells then
                    isSpecial = true
                    profileList[pName] = {}
                    for _, varName in ipairs(SpellConfig) do
                        if HBSpells[varName] then
                           profileList[pName][varName] = {}
                           ImportCondenser:CopyTable(HBSpells[varName], profileList[pName][varName])
                        end
                    end
                elseif pName == SpecialExports.BUFFS and HBGlobals then
                    isSpecial = true
                    profileList[pName] = {}
                    for _, varName in ipairs(BuffGlobals) do
                        if HBGlobals[varName] then
                            profileList[pName][varName] = {}
                            ImportCondenser:CopyTable(HBGlobals[varName], profileList[pName][varName])
                        end
                    end
                elseif pName == SpecialExports.DEBUFFS and HBGlobals then
                    isSpecial = true
                    profileList[pName] = {}
                    for _, varName in ipairs(DebuffGlobals) do
                        if HBGlobals[varName] then
                            profileList[pName][varName] = {}
                            ImportCondenser:CopyTable(HBGlobals[varName], profileList[pName][varName])
                        end
                    end
                elseif pName == SpecialExports.COLORS and HBGlobals then
                    isSpecial = true
                    profileList[pName] = {}
                    for _, varName in ipairs(ColorGlobals) do
                        if HBGlobals[varName] then
                            profileList[pName][varName] = {}
                            ImportCondenser:CopyTable(HBGlobals[varName], profileList[pName][varName])
                        end
                    end
                end

                if not isSpecial and IsInList(HBSkins.Skins, k) then
                    profileList[pName] = {}
                    
                    -- Simple Vars
                    for _, varName in ipairs(SkinVars) do
                        if HBSkins[varName] and HBSkins[varName][pName] then
                            profileList[pName][varName] = HBSkins[varName][pName]
                        end
                    end

                    -- Table Vars
                    for _, varName in ipairs(SkinTVars) do
                        if HBSkins[varName] and HBSkins[varName][pName] then
                            profileList[pName][varName] = {}
                            ImportCondenser:CopyTable(HBSkins[varName][pName], profileList[pName][varName])
                        end
                    end
                    
                    -- Named Table Vars
                    for _, varName in ipairs(SkinTNVars) do
                        if HBSkins[varName] and HBSkins[varName][pName] then
                            profileList[pName][varName] = {}
                            ImportCondenser:CopyTable(HBSkins[varName][pName], profileList[pName][varName])
                        end
                    end

                    -- Frame Vars
                    for _, varName in ipairs(SkinTFVars) do
                        if HBSkins[varName] and HBSkins[varName][pName] then
                            profileList[pName][varName] = { Frames = {}, Groups = {} }
                            -- Frames 1-10
                            for f=1, 10 do
                                if HBSkins[varName][pName][f] then
                                    profileList[pName][varName].Frames[f] = {}
                                    ImportCondenser:CopyTable(HBSkins[varName][pName][f], profileList[pName][varName].Frames[f])
                                end
                            end
                            -- HealGroups 11-15
                            if varName == 'HealGroups' then
                                for g=11, 15 do
                                    if HBSkins[varName][pName][g] then
                                        profileList[pName][varName].Groups[g] = {}
                                        ImportCondenser:CopyTable(HBSkins[varName][pName][g], profileList[pName][varName].Groups[g])
                                    end
                                end
                            end
                        end
                    end

                    -- Aux Frame Vars (Overlay)
                    for _, varName in ipairs(SkinTAuxFVars) do
                        if HBAux[varName] and HBAux[varName][pName] then
                            profileList[pName][varName] = { Frames = {} }
                            for f=1, 10 do
                                if HBAux[varName][pName][f] then
                                    profileList[pName][varName].Frames[f] = {}
                                    ImportCondenser:CopyTable(HBAux[varName][pName][f], profileList[pName][varName].Frames[f])
                                end
                            end
                        end
                    end

                    -- Aux Frame Bar Vars (Bar, BarText)
                    for _, varName in ipairs(SkinTAuxFBVars) do
                        if HBAux[varName] and HBAux[varName][pName] then
                            profileList[pName][varName] = { Frames = {} }
                            for f=1, 10 do
                                if HBAux[varName][pName][f] then
                                    profileList[pName][varName].Frames[f] = {}
                                    -- These have ids 1-9
                                    for id=1, 9 do
                                        if HBAux[varName][pName][f][id] then
                                            profileList[pName][varName].Frames[f][id] = {}
                                            ImportCondenser:CopyTable(HBAux[varName][pName][f][id], profileList[pName][varName].Frames[f][id])
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Icon Frame Vars
                    for _, varName in ipairs(SkinTIconFSVars) do
                        if HBSkins[varName] and HBSkins[varName][pName] then
                            profileList[pName][varName] = { Frames = {} }
                            for f=1, 10 do
                                if HBSkins[varName][pName][f] then
                                    profileList[pName][varName].Frames[f] = {}
                                    -- These have ids 1-3
                                    for id=1, 3 do
                                        if HBSkins[varName][pName][f][id] then
                                            profileList[pName][varName].Frames[f][id] = {}
                                            ImportCondenser:CopyTable(HBSkins[varName][pName][f][id], profileList[pName][varName].Frames[f][id])
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Extra Global Vars (ActionIcons)
                    for _, varName in ipairs(SkinExtraVars) do
                         local globalTable = _G[varName]
                         if globalTable and globalTable[pName] then
                             profileList[pName][varName] = {}
                             ImportCondenser:CopyTable(globalTable[pName], profileList[pName][varName])
                         end
                    end
                end

                 if profileList[pName] then
                    profileList[pName] = ImportCondenser:SeriPressCode(profileList[pName])
                 end
            end
        end
        table["Healbot"] = profileList
    end
end
