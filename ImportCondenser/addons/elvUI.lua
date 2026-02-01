local ADDON_NAME, ns  = ...
local ImportCondenser = ns.Addon

local AceAddon        = LibStub("AceAddon-3.0", true)

ImportCondenser.ElvUI = {}
local E               = AceAddon and AceAddon:GetAddon("ElvUI", true)
if not E then
	return
end
local D                = E:GetModule('Distributor')
local L                = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
local profileTypeItems = {
	profile = L["Profile"],
	private = L["Private (Character Settings)"],
	global = L
		["Global (Account Settings)"],
	filters = L["Aura Filters"]
}

function ImportCondenser.ElvUI:GetExportOptions()
	local exportOptions = { "Export" }
	for profileType, profileTypeLabel in pairs(profileTypeItems) do
		table.insert(exportOptions, profileTypeLabel)
	end
	return exportOptions, { "Export", L["Profile"] }, false
end

function ImportCondenser.ElvUI:DetectIssues(importTable)
	local opts = {}
	if type(importTable) ~= "table" then
		return "Unable to import. Invalid data format."
	end
	for profileType, profileTypeLabel in pairs(profileTypeItems) do
		if importTable[profileTypeLabel] then
			table.insert(opts, profileTypeLabel)
		end
	end
	return { options = opts, defaults = { L["Profile"] }, storeAsLower = false }
end

function ImportCondenser.ElvUI:Import(importTable, profileName)
	if not E then
		return
	end
	if type(importTable) == "table" then
		for profileType, profileTypeLabel in pairs(profileTypeItems) do
			if ImportCondenser.db.global.ElvUI.selectedImportOptions[profileTypeLabel] == true then
				local profData = importTable[profileTypeLabel]
				if profData then
					if profileType == "profile" then
						profData = ImportCondenser:ReplaceDelimitedTokenValue(profData, "::" .. profileType .. "::",
							profileName)
					end
					D:ImportProfile(profData)
				end
			end
		end
		importTable = ImportCondenser:ReplaceDelimitedTokenValue(importTable, "::profile::", profileName)
	end
end

function ImportCondenser.ElvUI:ReplaceExportProfileName(exportStr, newProfileName)
	return ImportCondenser:ReplaceDelimitedTokenValue(exportStr, "::profile::", newProfileName)
end

function ImportCondenser.ElvUI:Export(exports)
	if ImportCondenser.db.global.ElvUI.selectedExportOptions["Export"] ~= true then
		return
	end
	if not E then
		return
	end

	local elvExports = {}

	for profileType in next, profileTypeItems do
		local profileTypeLabel = profileTypeItems[profileType]
		if ImportCondenser.db.global.ElvUI.selectedExportOptions[profileTypeLabel] == true then
			local key, profExport = D:ExportProfile(profileType, nil, "luaTable")
			elvExports[profileTypeLabel] = profExport
		end
	end
	if next(elvExports) ~= nil then
		exports["ElvUI"] = elvExports
	end
end
