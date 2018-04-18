local _, addon = ...
local L = addon.L

local frames = {
  ["inviteOnly"] = {},
  ["others"] = {},
}

local frame = UICreateInterfaceOptionPage("FISOptionFrame", L["TITLE"], L["DESC"])
addon.optionFrame = frame

local group = frame:CreateMultiSelectionGroup(L["SETTING"])
frame:AnchorToTopLeft(group)

group:AddButton(L["ENABLE"], "enable")

table.insert(frames.inviteOnly, group:AddButton(L["INVITE_ONLY"], "inviteOnly"))
table.insert(frames.inviteOnly, group:AddButton(L["PREVENT_AFK"], "preventAFK"))
table.insert(frames.inviteOnly, group:AddButton(L["AUTO_EXTEND"], "autoExtend"))

local autoInvite = group:AddButton(L["AUTO_INVITE"], "autoInvite")
local autoInviteBN = group:AddButton(L["AUTO_INVITE_BN"], "autoInviteBN")
table.insert(frames.inviteOnly, autoInvite)
table.insert(frames.inviteOnly, autoInviteBN)

local checkInterval = group:AddDummy(L["CHECK_INVAL"], true)
table.insert(frames.others, group:AddButton(L["AUTO_QUEUE"], "autoQueue"))
local maxWaitingTime = group:AddDummy(L["MAX_TIME"], true)
table.insert(frames.others, group:AddButton(L["AUTO_LEAVE"], "autoLeave"))
table.insert(frames.others, group:AddButton(L["SHOW_WELCOME_MSG"], "welcomeMsg")) -- NOTE: Remove prefix SHOW after put MSG into Config
table.insert(frames.others, group:AddButton(L["SHOW_LEAVE_MSG"], "leaveMsg")) -- NOTE: Remove prefix SHOW after put MSG into Config

function group:OnCheckInit(value)
	return FISConfig[value]
end

function group:OnCheckChanged(value, checked)
	FISConfig[value] = checked and true or false
  local curr
  if value == "enable" then
    for _, curr in pairs(frames.inviteOnly) do
      if checked then
        curr:Enable()
      else
        curr:Disable()
      end
    end
  end
  if value == "inviteOnly" or (value == "enable" and not FISConfig.inviteOnly) then
    for _, curr in pairs(frames.others) do
      if (value == "enable" and checked) or (value == "inviteOnly" and not checked) then
        curr:Enable()
      else
        curr:Disable()
      end
    end
  end
  if value == "enable" or value == "inviteOnly" then
    addon.eventFrame.printStatus(addon.eventFrame)
  end
end
