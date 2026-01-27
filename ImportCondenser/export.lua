local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

local AceConfigDialog = ns.AceConfigDialog

function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = { profileName = profileName }

    local addons = ns.addons or {}
    for _, addonName in ipairs(addons) do
        local addonModule = ImportCondenser[addonName]
        if addonModule and addonModule.Export then
            addonModule:Export(exports)
        end
    end

    local importPrefix = ns.importPrefix or "1:ImportCondenser:"
    return importPrefix .. ImportCondenser:SeriPressCode(exports)
end

function ImportCondenser:DisplayTextFrame(title, text)
    local AceGUI = LibStub("AceGUI-3.0")

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(title)
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetHeight(200)

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel(title)
    editbox:SetText(text)
    editbox:SetFullWidth(true)
    editbox:SetNumLines(8)
    editbox:DisableButton(true)
    editbox:SetFocus()
    editbox:HighlightText()
    frame:AddChild(editbox)

    editbox.editBox:SetScript("OnEnterPressed", function()
        frame:Release()
    end)

    local aceConfigDialog = AceConfigDialog
    local function closeExportOnConfigHide()
        if frame and frame.Release then frame:Release() end
    end

    local blizFrame = aceConfigDialog and aceConfigDialog.OpenFrames and aceConfigDialog.OpenFrames[ADDON_NAME] and aceConfigDialog.OpenFrames[ADDON_NAME].frame
    if blizFrame then
        blizFrame:HookScript("OnHide", closeExportOnConfigHide)
    end
end

function ImportCondenser:ShowExportWindow()
    local exportStr = self:GenerateExportString()
    self:DisplayTextFrame("Export", exportStr)
end
