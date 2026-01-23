local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Details = {}

function ImportCondenser.Details:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.Details:Import(importStr, profileName)
	if _G.Details and type(_G.Details) == "table" and type(_G.Details.ImportProfile) == "function" then
		_G.Details:ImportProfile(importStr, profileName, false, false, true)
    end
end

function ImportCondenser.Details:Export(exports)
    if ImportCondenser.db.global.Details.selectedExportOptions["Export"] ~= true then return end
	if _G.Details and type(_G.Details) == "table" and type(_G.Details.ExportCurrentProfile) == "function" then
		local profile = _G.Details:ExportCurrentProfile()
		exports["Details"] = profile
	end
end