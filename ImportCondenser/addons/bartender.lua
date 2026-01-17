local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

local AceAddon = LibStub("AceAddon-3.0", true)
local AceDBOptions = LibStub("AceDBOptions-3.0", true)
local LibDualSpec   = LibStub("LibDualSpec-1.0", true)
local AceSerializer = LibStub("AceSerializer-3.0", true)
local LibDeflate = LibStub("LibDeflate", true)

ImportCondenser.Bartender4 = {}

function ImportCondenser.Bartender4:Import(importStr, profileName)
    local Bartender = AceAddon and AceAddon:GetAddon("Bartender4", true)

    local profileOptions
    if AceDBOptions and Bartender.db then
        profileOptions = AceDBOptions:GetOptionsTable(Bartender.db)
        -- Enhance profile options with LibDualSpec if available
        if LibDualSpec then
            LibDualSpec:EnhanceOptions(profileOptions, Bartender.db)
        end
    end

    local handler = profileOptions.handler
    handler.db.SetProfile(handler.db, profileName)

    if Bartender and AceSerializer and LibDeflate then
		-- Decode, decompress, and deserialize
		local decoded = LibDeflate:DecodeForPrint(importStr)
		if not decoded then
			print("Error: Failed to decode Bartender import string")
			return
		end
		
		local decompressed = LibDeflate:DecompressDeflate(decoded)
		if not decompressed then
			print("Error: Failed to decompress Bartender data")
			return
		end
		
		local success, importProfile = AceSerializer:Deserialize(decompressed)
		if not success or not importProfile then
			print("Error: Failed to deserialize Bartender profile")
			return
		end
		
		-- Import main profile
		handler.db.profiles[profileName] = importProfile.profile
		
		
		-- Import child profiles (action bars, etc)
		for childName, childProfile in pairs(importProfile.children or {}) do
			if handler.db.children[childName] then
				ImportCondenser:CopyTable(childProfile, handler.db.children[childName].profile)
			end
		end
    end
end

function ImportCondenser.Bartender4:Export(exports)
    local Bartender = AceAddon and AceAddon:GetAddon("Bartender4", true)
	if not Bartender then
		return
	end
    local profileOptions
    if AceDBOptions and Bartender.db then
        profileOptions = AceDBOptions:GetOptionsTable(Bartender.db)
        -- Enhance profile options with LibDualSpec if available
        if LibDualSpec then
            LibDualSpec:EnhanceOptions(profileOptions, Bartender.db)
        end
    end

    local handler = profileOptions.handler
	local profile = handler.db.profile
	
    if profile and AceSerializer and LibDeflate then
		-- Build export structure with main profile and child profiles
		local exportProfile = {
			profile = profile,
			children = {}
		}
		
		for childName, childDb in pairs(handler.db.children) do
			exportProfile.children[childName] = {}
			ImportCondenser:CopyTable(childDb.profile, exportProfile.children[childName])
		end
		
		-- Serialize, compress, and encode
		local serialized = AceSerializer:Serialize(exportProfile)
		local compressed = LibDeflate:CompressDeflate(serialized)
		local encoded = LibDeflate:EncodeForPrint(compressed)
		
		if encoded then
			exports["Bartender4"] = encoded
		end
	end
end