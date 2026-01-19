local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Template = {}
-- Copy this file and its structure
-- replace Template with your addon name
-- it is important to name everything consistently
-- make sure to rename and add the new file to the ImportCondenser.toc

-- this function is optional
-- return a list of options for export
-- this will create checkboxes in the UI for the user to select what to export
function ImportCondenser.Template:GetExportOptions()
end


-- this function is optional
-- function to detect issues in the import string
-- return a string to display the error.
-- if a list is returned, it will render checkboxes for the user to select what to import
function ImportCondenser.Template:DetectIssues(importString)
end

-- Placeholder function for import
-- add your import logic here.
-- if you are using the import options, pull the selected options from the db and import only those
function ImportCondenser.Template:Import(importString)

end

-- Placeholder function for export
-- add your export logic here.
-- The string that is is used as a key in the table must match exactly the module name
-- if you are using the export options, pull the selected options from the db and export only those
-- they would be stored at ImportCondenser.db.global.Template.selectedExportOptions
function ImportCondenser.Template:Export(table)

    table["Template"] = "ExportedDataPlaceholder"
end
