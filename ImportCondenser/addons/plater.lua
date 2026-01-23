local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local AceAddon = LibStub("AceAddon-3.0", true)

ImportCondenser.Plater = {}

--db upvalues
local DB_CAPTURED_SPELLS = {}
local DB_CAPTURED_CASTS = {}

function ImportCondenser.Plater:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.Plater:Import(importStr, profileName)
    if Plater and type(Plater) == "table" and type(Plater.ImportAndSwitchProfile) == "function" then
        Plater.ImportAndSwitchProfile(profileName, importStr, false, false, true)
    end
end

function ImportCondenser.Plater:Export(exports)
    if ImportCondenser.db.global.Plater.selectedExportOptions["Export"] ~= true then return end
    local Plater = AceAddon and AceAddon:GetAddon("Plater", true)
    local DF = LibStub("DetailsFramework-1.0", true)
    if not Plater or not DF then
        return
    end
    Plater.db.profile.captured_spells = {} -- cleanup, although it should be empty, stored in PlaterDB
    Plater.db.profile.captured_casts = {} -- cleanup, although it should be empty, stored in PlaterDB
    
    --create a modifiable copy, do not modify "in use" profile for safety
    local profile = DF.table.copy(Plater.db.profile, {})
    local npc_cacheOrig = Plater.db.profile.npc_cache
    
    --do not export cache data, these data can be rebuild at run time
    profile.npc_cache = {}
    profile.saved_cvars_last_change = {}
    profile.script_data_trash = {}
    profile.hook_data_trash = {}
    profile.plugins_data = {} -- it might be good to remove those to ensure no addon dependencies break anything
    --profile.spell_animation_list = nil -- nil -> default will be used. but this should be part of the profile?!
    
    --retain npc_cache for set npc_colors
    for npcID, _ in pairs (profile.npc_colors) do
        profile.npc_cache [npcID] = npc_cacheOrig [npcID]
    end
    --retain npc_cache for set npcs_renamed
    for npcID, _ in pairs (profile.npcs_renamed) do
        profile.npc_cache [npcID] = npc_cacheOrig [npcID]
    end
    --retain npc_cache, captured_spells and captured_casts for set cast_colors
    for spellId, _ in pairs (profile.cast_colors) do
        profile.captured_spells[spellId] = DB_CAPTURED_SPELLS[spellId]
        profile.captured_casts[spellId] = DB_CAPTURED_CASTS[spellId]
        local capturedSpell = DB_CAPTURED_SPELLS[spellId] or DB_CAPTURED_CASTS[spellId]
        if capturedSpell and capturedSpell.npcID then
            local npcID = capturedSpell.npcID
            profile.npc_cache [npcID] = npc_cacheOrig [npcID]
        end
    end
    --retain npc_cache, captured_spells and captured_casts for set cast_colors
    for spellId, _ in pairs (profile.cast_audiocues) do
        profile.captured_spells[spellId] = DB_CAPTURED_SPELLS[spellId]
        profile.captured_casts[spellId] = DB_CAPTURED_CASTS[spellId]
        local capturedSpell = DB_CAPTURED_SPELLS[spellId] or DB_CAPTURED_CASTS[spellId]
        if capturedSpell and capturedSpell.npcID then
            local npcID = capturedSpell.npcID
            profile.npc_cache [npcID] = npc_cacheOrig [npcID]
        end
    end
    
    --cleanup mods HooksTemp (for good)
    for i = #profile.hook_data, 1, -1 do
        local scriptObject = profile.hook_data [i]
        scriptObject.HooksTemp = {}
    end
    
    --store current profile name
    profile.profile_name = Plater.db:GetCurrentProfile()
    profile.tocversion = select(4, GetBuildInfo()) -- provide export toc
    
    --convert the profile to string
    local data = Plater.CompressData (profile, "print")
    if (not data) then
        Plater:Msg ("failed to compress the profile")
    end
    exports["Plater"] = data
end
