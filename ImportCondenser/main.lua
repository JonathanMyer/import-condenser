local ADDON_NAME, ns = ...
ns = ns or {}

local AceAddon = LibStub("AceAddon-3.0", true)
local ImportCondenser = AceAddon:NewAddon(
    ADDON_NAME,
    "AceConsole-3.0",
    "AceEvent-3.0"
)

ns.Addon = ImportCondenser
ImportCondenser.DEBUG = false

-- Shared references for other modules
ns.LibDualSpec = LibStub("LibDualSpec-1.0", true)
ns.AceConfig = LibStub("AceConfig-3.0")
ns.AceConfigDialog = LibStub("AceConfigDialog-3.0")
ns.AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.addons = ns.addons or {}
