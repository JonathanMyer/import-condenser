local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Details = {}

function ImportCondenser.Details:Import(importStr, profileName)
	if type(_G.Details) ~= "table" or type(_G.Details.ImportProfile) ~= "function" then
      print("Details ImportProfile not available.")
    end
    _G.Details:ImportProfile(importStr, profileName, false, false, true)
end

function ImportCondenser.Details:Export(exports)
	if type(_G.Details) ~= "table" or type(_G.Details.ExportCurrentProfile) ~= "function" then
	  return
	end
	local profile = _G.Details:ExportCurrentProfile()
	exports["Details"] = profile
end