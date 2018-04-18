local _, addon = ...
local L = addon.L

local frames = {
  ["INVITE_ONLY"] = {},
  ["OTHERS"] = {},
}

local frame = UICreateInterfaceOptionPage(addon.name.."OptionFrame", L["TITLE"], L["DESC"])
addon.optionFrame = frame

local group = frame:CreateMultiSelectionGroup(L["SETTING"])
frame:AnchorToTopLeft(group)
