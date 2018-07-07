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
table.insert(frames.inviteOnly, group:AddButton(L["AUTO_INVITE"], "autoInvite"))
table.insert(frames.inviteOnly, group:AddButton(L["AUTO_INVITE_BN"], "autoInviteBN"))

group:AddDummy(L["CHECK_INVAL"], true)
table.insert(frames.others, group:AddButton(L["AUTO_QUEUE"], "autoQueue"))
group:AddDummy(L["MAX_TIME"], true)
table.insert(frames.others, group:AddButton(L["AUTO_LEAVE"], "autoLeave"))
group:AddDummy(L["WELCOME_MSG"], true)
group:AddDummy(L["LEAVE_MSG"], true)

function group:OnCheckInit(value)
	return FISConfig[value]
end

function group:OnCheckChanged(value, checked)
	FISConfig[value] = checked and true or false
	local curr

	-- Toggle Enable and Disable
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

	-- Print Status
	if value == "enable" or value == "inviteOnly" then
		addon.eventFrame.printStatus(addon.eventFrame)
	end
end

local autoInviteMsg = frame:CreateEditBox()
table.insert(frames.inviteOnly, autoInviteMsg)
autoInviteMsg:SetPoint("LEFT", group[5].text, "RIGHT", 10, 0)
function autoInviteMsg:OnTextCommit(text)
	FISConfig.autoInviteMsg = text
end
function autoInviteMsg:OnTextCancel()
	return FISConfig.autoInviteMsg
end

local autoInviteBNMsg = frame:CreateEditBox()
table.insert(frames.inviteOnly, autoInviteBNMsg)
autoInviteBNMsg:SetPoint("LEFT", group[6].text, "RIGHT", 10, 0)
function autoInviteBNMsg:OnTextCommit(text)
	FISConfig.autoInviteBNMsg = text
end
function autoInviteBNMsg:OnTextCancel()
	return FISConfig.autoInviteBNMsg
end

local checkInterval = frame:CreateEditBox()
table.insert(frames.others, checkInterval)
checkInterval:SetNumeric(true)
checkInterval:SetWidth(100)
checkInterval:SetPoint("LEFT", group[7].text, "RIGHT", 10, 0)
function checkInterval:OnTextCommit(text)
	FISConfig.checkInterval = tonumber(text)
end
function checkInterval:OnTextCancel()
	return FISConfig.checkInterval
end

local enterQueueMsg = frame:CreateEditBox()
table.insert(frames.others, enterQueueMsg)
enterQueueMsg:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
enterQueueMsg:SetPoint("LEFT", group[8].text, "RIGHT", 10, 0)
function enterQueueMsg:OnTextCommit(text)
	FISConfig.enterQueueMsg = text
end
function enterQueueMsg:OnTextCancel()
	return FISConfig.enterQueueMsg
end

local maxWaitingTime = frame:CreateEditBox()
table.insert(frames.others, maxWaitingTime)
maxWaitingTime:SetNumeric(true)
maxWaitingTime:SetWidth(100)
maxWaitingTime:SetPoint("LEFT", group[9].text, "RIGHT", 10, 0)
function maxWaitingTime:OnTextCommit(text)
	FISConfig.maxWaitingTime = tonumber(text)
end
function maxWaitingTime:OnTextCancel()
	return FISConfig.maxWaitingTime
end

local welcomeMsg = frame:CreateEditBox()
table.insert(frames.others, welcomeMsg)
welcomeMsg:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
welcomeMsg:SetPoint("LEFT", group[11].text, "RIGHT", 10, 0)
function welcomeMsg:OnTextCommit(text)
	FISConfig.welcomeMsg = text
end
function welcomeMsg:OnTextCancel()
	return FISConfig.welcomeMsg
end

local leaveMsg = frame:CreateEditBox()
table.insert(frames.others, leaveMsg)
leaveMsg:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
leaveMsg:SetPoint("LEFT", group[12].text, "RIGHT", 10, 0)
function leaveMsg:OnTextCommit(text)
	FISConfig.leaveMsg = text
end
function leaveMsg:OnTextCancel()
	return FISConfig.leaveMsg
end

local textReplace = frame:CreateFontString("TextReplaceFrame", "ARTWORK", "GameFontHighlightSmallLeftTop")
textReplace:SetText(L["TEXT_REPLACE"])
textReplace:SetPoint("TOPLEFT", group[12], "BOTTOMLEFT", 0, 0)
textReplace:SetPoint("RIGHT", frame, "RIGHT", -10, 0)

-- Self defined function
addon.eventFrame.ON_PLAYER_ENTERING_WORLD = function ()
	autoInviteMsg:SetText(FISConfig.autoInviteMsg)
	autoInviteBNMsg:SetText(FISConfig.autoInviteBNMsg)
	checkInterval:SetNumber(FISConfig.checkInterval)
	enterQueueMsg:SetText(FISConfig.enterQueueMsg)
	maxWaitingTime:SetNumber(FISConfig.maxWaitingTime)
	welcomeMsg:SetText(FISConfig.welcomeMsg)
	leaveMsg:SetText(FISConfig.leaveMsg)
end
