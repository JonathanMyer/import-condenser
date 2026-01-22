local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Details = {}

function ImportCondenser.Details:Import(importStr, profileName)
	if _G.Details and type(_G.Details) == "table" and type(_G.Details.ImportProfile) == "function" then
		_G.Details:ImportProfile(importStr, profileName, false, false, true)
    end
end

function ImportCondenser.Details:Export(exports)
	if _G.Details and type(_G.Details) == "table" and type(_G.Details.ExportCurrentProfile) == "function" then
		local profile = _G.Details:ExportCurrentProfile()
		exports["Details"] = profile
	end
end