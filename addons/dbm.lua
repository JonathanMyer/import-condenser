local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local DBM = _G.DBM
local DBM_GUI = _G.GUI
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")
local playerName, realmName, playerLevel = UnitName("player"), GetRealmName(), UnitLevel("player")
local isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
local type, ipairs, tinsert = type, ipairs, table.insert
local L = DBM_GUI_L

local localeTable = {
	RaidWarningSound		= "RaidWarnSound",
	SpecialWarningSound		= "SpecialWarnSoundOption",
	SpecialWarningSound2	= "SpecialWarnSoundOption",
	SpecialWarningSound3	= "SpecialWarnSoundOption",
	SpecialWarningSound4	= "SpecialWarnSoundOption",
	SpecialWarningSound5	= "SpecialWarnSoundOption",
	EventSoundVictory2		= "EventVictorySound",
	EventSoundWipe			= "EventWipeSound",
	EventSoundEngage2		= "EventEngageSound",
	EventSoundMusic			= "EventEngageMusic",
	EventSoundDungeonBGM	= "EventDungeonMusic"
}

local function GetSpecializationGroup()
	if isRetail then
		return GetSpecialization() or 1
	else
		local numTabs = GetNumTalentTabs()
		local highestPointsSpent, currentSpecGroup = 0, 1
		if MAX_TALENT_TABS then
			for i=1, MAX_TALENT_TABS do
				if ( i <= numTabs ) then
					local _, _, _, _, pointsSpent = GetTalentTabInfo(i)
					if pointsSpent > highestPointsSpent then
						highestPointsSpent = pointsSpent
						currentSpecGroup = i
					end
				end
			end
		end
		return currentSpecGroup
	end
end

local function actuallyImport(importTable)
	DBM.Options = importTable.DBM -- Cached options
	DBM_AllSavedOptions[_G["DBM_UsedProfile"]] = importTable.DBM
	DBT_AllPersistentOptions[_G["DBM_UsedProfile"]] = importTable.DBT
	DBM_MinimapIcon = importTable.minimap
	if importTable.minimap.hide then
		LibStub("LibDBIcon-1.0"):Hide("DBM")
	else
		LibStub("LibDBIcon-1.0"):Show("DBM")
	end
	DBT:SetOption("Skin", DBT.Options.Skin) -- Forces a hard update on bars.
	DBM:AddMsg("Profile imported.")
end

local function processImport(importTable)
		print("Profile.lua: Importing profile...")
		local errors = {}
		-- Check if voice pack missing
		local activeVP = importTable.DBM.ChosenVoicePack2
		if activeVP ~= "None" then
			if not DBM.VoiceVersions[activeVP] or (DBM.VoiceVersions[activeVP] and DBM.VoiceVersions[activeVP] == 0) then
				if activeVP ~= "VEM" then
					DBM:AddMsg(L.ImportVoiceMissing:format(activeVP))
					tinsert(errors, "ChosenVoicePack2")
				end
			end
		end
		-- Check if sound packs are missing
		for _, soundSetting in ipairs({
			"RaidWarningSound", "SpecialWarningSound", "SpecialWarningSound2", "SpecialWarningSound3", "SpecialWarningSound4", "SpecialWarningSound5", "EventSoundVictory2",
			"EventSoundWipe", "EventSoundEngage2", "EventSoundMusic", "EventSoundDungeonBGM", "RangeFrameSound1", "RangeFrameSound2"
		}) do
			local activeSound = importTable.DBM[soundSetting]
			if type(activeSound) == "string" and activeSound:lower() ~= "none" and not DBM:ValidateSound(activeSound, true, true) then
				DBM:AddMsg(L.ImportErrorOn:format(L[localeTable[soundSetting]] or soundSetting))
				tinsert(errors, soundSetting)
			end
		end
		-- Create popup confirming if they wish to continue (and therefor resetting to default)
		if #errors > 0 then
			local popup = StaticPopup_Show("IMPORTPROFILE_ERROR")
			if popup then
				popup.importFunc = function()
					for _, soundSetting in ipairs(errors) do
						importTable.DBM[soundSetting] = DBM.DefaultOptions[soundSetting]
					end
					actuallyImport(importTable)
				end
			end
		else
			actuallyImport(importTable)
		end
	end

local function VerifyImport(import)
    local success, deserialized = LibSerialize:Deserialize(LibDeflate:DecompressDeflate(LibDeflate:DecodeForPrint(import)))
    if not success then
        DBM:AddMsg("Failed to deserialize")
        return false
    end
    processImport(deserialized)
    return true
end

function ImportCondenser:ImportDBM(importString, profileName)
    print("Importing DBM profile: " .. profileName)
    VerifyImport(importString)
end


function ImportCondenser:ExportDBM(table)

    local export = {
		DBM		= DBM.Options,
		DBT		= DBT_AllPersistentOptions[_G["DBM_UsedProfile"]],
		minimap	= DBM_MinimapIcon
	}
    print("Exporting DBM profile...")
    table["dbm"] = LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(LibSerialize:Serialize(export)))
end

