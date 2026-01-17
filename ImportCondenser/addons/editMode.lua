local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.EditMode = {}

function ImportCondenser.EditMode:Import(importString, profileName)
    if not C_EditMode or
       type(C_EditMode.ConvertStringToLayoutInfo) ~= "function" or
       type(C_EditMode.GetLayouts) ~= "function" or
       type(C_EditMode.SaveLayouts) ~= "function" or
       type(C_EditMode.SetActiveLayout) ~= "function"
    then
        return
    end
    local layout = C_EditMode.ConvertStringToLayoutInfo(importString)
    layout.layoutName = profileName
    layout.layoutType = 1 -- set to account layout
    local layouts = C_EditMode.GetLayouts()
    local maxLayoutID = 0
    if layouts and layouts.layouts then
        for k, _ in pairs(layouts.layouts) do
            if type(k) == "number" and k > maxLayoutID then
                maxLayoutID = k
            end
        end
        layouts.layouts[maxLayoutID + 1] = layout
        C_EditMode.SaveLayouts(layouts)
        C_EditMode.SetActiveLayout(maxLayoutID + 3) -- need to add 3 because of the two default layouts
    end
end

function ImportCondenser.EditMode:Export(exports)
    if C_EditMode and type(C_EditMode.GetLayouts) == "function" and type(C_EditMode.ConvertLayoutInfoToString) == "function" then
        local layouts = C_EditMode.GetLayouts()
        local layoutNumber = layouts and layouts.activeLayout
        if layouts and layouts.layouts then
            -- need to minus 2 because the first two layouts are default ones and are not returned by GetLayouts
            if layoutNumber and layouts.layouts[layoutNumber - 2] then
                local activeLayoutInfo = layouts.layouts[layoutNumber - 2]
                exports["EditMode"] = C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo)
            end
        end
    end
end
