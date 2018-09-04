local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("FreeInstanceSharer")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local function debug (...)
	if not FISConfig then
		print("FISConfig not loaded")
		print(...)
	elseif FISConfig.debug then
		print(...)
	end
end

local defaultConfig = {
	["debug"] = false, -- 调试模式
	["enable"] = false, -- 启动时启用
	["inviteOnly"] = false, -- 极简模式（只启用防AFK、自动延长锁定、密语进组）
	["preventAFK"] = true, -- 防AFK
	["autoExtend"] = true, -- 自动延长锁定
	["autoInvite"] = true, -- 密语进组
	["autoInviteMsg"] = "123", -- 密语进组信息
	["autoInviteBN"] = true, -- 战网密语进组
	["autoInviteBNMsg"] = "123", -- 战网密语进组信息
	["autoLeave"] = true, -- 密语离开队列
	["autoLeaveMsg"] = "233", -- 密语离开队列信息
	["checkInterval"] = 500, -- 检查间隔
	["autoQueue"] = true, -- 自动排队
	["maxWaitingTime"] = 30, -- 最长在组等待时间 (0 - 无限制)
	["autoLeave"] = true, -- 检查成员位置并退组
	["enterQueueMsg"] = "你已进入队列，排在第 QCURR 名。", -- 进入队列提示
	["fetchErrorMsg"] = "无法从战网获取你的角色信息，请尝试游戏内密语 NAME 。", -- 战网获取角色失败的信息
	["queryQueueMsg"] = "你已进入队列，排在第 QCURR 名。", -- 查询队列位置提示
	["leaveQueueMsg"] = "你已离开队列。", -- 离开队列提示
	["welcomeMsg"] = "你现在有 MTIME 秒的进本时间。默认难度为25人普通，在队伍发送 10 切换为10人模式，发送 H 切换为英雄模式。", -- 进组时发送的信息
	["leaveMsg"] = "已将队长转交，刷无敌请自行在副本内修改难度为英雄（如果未成功请在副本外设置自己为25普通在来一次）。", -- 退组时发送的信息
}

local autoLeaveInstanceMapID = {
	-- 团队副本
	[531] = {14}, -- 安其拉神殿
	[564] = {14}, -- 黑暗神殿
	[603] = {14}, -- 奥杜尔
	[631] = {3, 4, 5, 6}, -- 冰冠堡垒
	[669] = {3, 4, 5, 6}, -- 黑翼血环
	[754] = {3, 4, 5, 6}, -- 风神王座
	[720] = {3, 4, 5, 6}, -- 火焰之地
	[967] = {3, 4, 5, 6}, -- 巨龙之魂
	[966] = {3, 4, 5, 6}, -- 永春台
	[1008] = {3, 4, 5, 6}, -- 魔古山宝库
	[1098] = {3, 4, 5, 6}, -- 雷电王座
	[1136] = {15}, -- 决战奥格瑞玛
	[1205] = {14, 15}, -- 黑石铸造厂
	[1448] = {14, 15}, -- 地狱火堡垒
	[1520] = {15}, -- 翡翠梦魇
	[1676] = {14, 15}, -- 萨格拉斯之墓
	[1712] = {14, 15}, -- 安托鲁斯，燃烧王座

	-- 地下城
	[1651] = {23}, -- 重返卡拉赞
}

local status = 0 -- 0 - before init 1 - idle 2 - inviting 3 - invited
local timeElapsed = 0 -- time elapsed from previous OnUpdate
local queue = {}
local invitedTime

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
eventFrame:RegisterEvent("PLAYER_CAMPING")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_PARTY")
eventFrame:SetScript("OnUpdate", function (self, ...)
	self.OnUpdate(self, ...)
end)
eventFrame:SetScript("OnEvent", function (self, event, ...)
	self[event](self, ...)
end)

function eventFrame:OnUpdate (elapsed)
	if not FISConfig.inviteOnly then
		timeElapsed = timeElapsed + elapsed
		if FISConfig.enable and (timeElapsed * 1000) >= FISConfig.checkInterval then
			timeElapsed = 0
			if status == 1 then
				-- check queue
				if #queue > 0 then
					local name = queue[1]
					table.remove(queue, 1)
					self.inviteToGroup(self, name)
				end
			elseif status == 3 then
				-- check max waiting time
				if FISConfig.maxWaitingTime and FISConfig.maxWaitingTime ~= 0 and time() - invitedTime >= FISConfig.maxWaitingTime then
					self.leaveGroup(self)
				end

				-- check player place
				if FISConfig.autoLeave then
					local _, _, _, instanceID = UnitPosition("party1")
					if instanceID and autoLeaveInstanceMapID[instanceID] then
						self.leaveGroup(self)
					end
				end
			end
		end
	end
end

-- initialization
-- return nil
function eventFrame:init ()
	if status == 0 then
		self.printStatus(self)
		status = 1
	end
end

-- print current status and config to chatframe
-- return nil
function eventFrame:printStatus ()
	if FISConfig.enable then
		if status then
			if FISConfig.inviteOnly then
				print(L["FIS:"] .. L["INVITE_ONLY_MODE"])
			else
				print(L["FIS:"] .. L["SHARE_STARTED"])
			end
		else
			print(L["FIS:"] .. L["SHARE_STARTING"])
		end
	else
		print(L["FIS:"] .. L["SHARE_STOP"])
	end
end

-- format message string
-- return formated string
function eventFrame:format (message, curr)
	if curr then
		message = string.gsub(message, "QCURR", curr)
	end
	message = string.gsub(message, "QLEN", #queue)
	message = string.gsub(message, "MTIME", FISConfig.maxWaitingTime)
	message = string.gsub(message, "NAME", UnitName("player") .. "-" .. GetRealmName())
	return message
end

-- add a player to queue
-- return nil - not enabled 0 - success 1 - fail(exists)
function eventFrame:addToQueue (name)
	debug("Adding to queue:", name)
	if FISConfig.enable then
		if not FISConfig.inviteOnly and FISConfig.autoQueue then
			local flag, index, curr = false
			for index, curr in pairs(queue) do
				if curr == name then
					flag = true
					break
				end
			end
			if flag == false then
				table.insert(queue, name)
				if FISConfig.enterQueueMsg and FISConfig.enterQueueMsg ~= "" then
					local message = self.format(self, FISConfig.enterQueueMsg, #queue)
					SendChatMessage(message, "WHISPER", nil, name)
				end
			else
				if FISConfig.queryQueueMsg and FISConfig.queryQueueMsg ~= "" then
					local message = self.format(self, FISConfig.queryQueueMsg, index)
					SendChatMessage(message, "WHISPER", nil, name)
				end
			end
			return not flag
		else
			self.inviteToGroup(self, name)
			return 0
		end
	end
end

-- remove a player from queue
-- return nil
function eventFrame:removeFromQueue (name)
	debug("Removing from queue:", name)
	local index, curr
	for index, curr in pairs(queue) do
		if curr == name then
			table.remove(queue, index)
			break
		end
	end
	local message = self.format(self, FISConfig.leaveQueueMsg)
	SendChatMessage(message, "WHISPER", nil, name)
end

-- invite player
-- return nil
function eventFrame:inviteToGroup (name)
	debug("Inviting to group:", name)
	if FISConfig.enable then
		SetRaidDifficultyID(14) -- 普通难度
		SetLegacyRaidDifficultyID(4) -- 旧世副本难度25人普通
		ResetInstances()
		if not FISConfig.inviteOnly and FISConfig.autoQueue then
			groupRosterUpdateTimes = 0
			status = 2
		else
			status = 1
		end
		InviteUnit(name)
	end
end

-- mark invited
-- return nil
function eventFrame:playerInvited ()
	debug("Player accepted invition")
	invitedTime = time()
	if FISConfig.welcomeMsg and FISConfig.welcomeMsg ~= "" then
		local message = self.format(self, FISConfig.welcomeMsg)
		SendChatMessage(message, "PARTY")
	end
	status = 3
end

-- mark rejected
-- return nil
function eventFrame:playerRejected ()
	debug("Player rejected invition")
	status = 1
end

-- mark leaved
-- return nil
function eventFrame:playerLeaved ()
	debug("Player leaved group")
	status = 1
end

-- transfer leader and leave party
-- return nil
function eventFrame:leaveGroup ()
	debug("BOT leaving group")
	if status == 3 then
		if FISConfig.leaveMsg and FISConfig.leaveMsg ~= "" then
			local message = self.format(self, FISConfig.leaveMsg)
			SendChatMessage(message, "PARTY")
		end
		-- set status first to prevent GROUP_ROSTER_UPDATE handle
		status = 1
		PromoteToLeader("party1")
		LeaveParty()
	end
end

function eventFrame:PLAYER_ENTERING_WORLD ()
	RequestRaidInfo()
	if not FISConfig then
		FISConfig = defaultConfig
	else
		local key, value
		for key, value in pairs(defaultConfig) do
			if not FISConfig[key] then
				FISConfig[key] = defaultConfig[key]
			end
		end
	end
	local generalOptions = {
		name = L["Free Instance Sharer"],
		type = "group",
		args = {
			enable = {
				order = 1,
				name = L["Enable"],
				type = "toggle",
				set = function(info, value)
					FISConfig.enable = value
					status = 0
					eventFrame.printStatus(eventFrame)
					if value then
						RequestRaidInfo()
					end
				end,
				get = function(info) return FISConfig.enable end
			},
			inviteOnly = {
				order = 11,
				name = L["Invite Only"],
				type = "toggle",
				set = function(info, value)
					FISConfig.inviteOnly = value
					eventFrame.printStatus(eventFrame)
				end,
				get = function(info) return FISConfig.inviteOnly end
			},
			preventAFK = {
				order = 21,
				name = L["Prevent AFK"],
				type = "toggle",
				set = function(info, value) FISConfig.preventAFK = value end,
				get = function(info) return FISConfig.preventAFK end
			},
			debug = {
				order = 26,
				name = L["Debug Mode"],
				type = "toggle",
				set = function(info, value) FISConfig.debug = value end,
				get = function(info) return FISConfig.debug end
			},
			subHeader = {
				order = 30,
				name = "",
				type = "header",
			},
			autoExtend = {
				order = 31,
				name = L["Auto Extend Saved Instance"],
				type = "toggle",
				set = function(info, value) FISConfig.autoExtend = value end,
				get = function(info) return FISConfig.autoExtend end
			},
			autoInvite = {
				order = 32,
				name = L["Auto Invite by In-game Whisper"],
				type = "toggle",
				set = function(info, value) FISConfig.autoInvite = value end,
				get = function(info) return FISConfig.autoInvite end
			},
			autoInviteBN = {
				order = 33,
				name = L["Auto Invite by Battle.net Whisper"],
				type = "toggle",
				set = function(info, value) FISConfig.autoInviteBN = value end,
				get = function(info) return FISConfig.autoInviteBN end
			},
			autoLeave = {
				order = 34,
				name = L["Leave Queue by In-game Whisper"],
				type = "toggle",
				set = function(info, value) FISConfig.autoLeave = value end,
				get = function(info) return FISConfig.autoLeave end
			},
			checkInterval = {
				order = 41,
				name = L["Check Queue Interval (ms)"],
				type = "input",
				pattern = "%d+",
				confirm = true,
				set = function(info, value) FISConfig.checkInterval = tonumber(value) end,
				get = function(info) return tostring(FISConfig.checkInterval) end
			},
			autoQueue = {
				order = 51,
				name = L["Auto Entering Queue"],
				type = "toggle",
				set = function(info, value) FISConfig.autoQueue = value end,
				get = function(info) return FISConfig.autoQueue end
			},
			maxWaitingTime = {
				order = 52,
				name = L["Max Waiting Time (s)"],
				type = "input",
				pattern = "%d+",
				confirm = true,
				set = function(info, value) FISConfig.maxWaitingTime = tonumber(value) end,
				get = function(info) return tostring(FISConfig.maxWaitingTime) end
			},
			autoLeave = {
				order = 53,
				name = L["Auto Leave Group"],
				type = "toggle",
				set = function(info, value) FISConfig.autoLeave = value end,
				get = function(info) return FISConfig.autoLeave end
			},
		},
	}
	local messageOptions = {
		name = L["MSG_OPTIONS"],
		type = "group",
		args = {
			autoInviteMsg = {
				order = 1,
				name = L["Auto Invite by In-game Whisper Message"],
				type = "input",
				confirm = true,
				set = function(info, value) FISConfig.autoInviteMsg = value end,
				get = function(info) return FISConfig.autoInviteMsg end
			},
			autoInviteBNMsg = {
				order = 2,
				name = L["Auto Invite by Battle.net Whisper Message"],
				type = "input",
				confirm = true,
				set = function(info, value) FISConfig.autoInviteBNMsg = value end,
				get = function(info) return FISConfig.autoInviteBNMsg end
			},
			autoLeaveMsg = {
				order = 3,
				name = L["Leave Queue by In-game Whisper Message"],
				type = "input",
				confirm = true,
				set = function(info, value) FISConfig.autoLeaveMsg = value end,
				get = function(info) return FISConfig.autoLeaveMsg end
			},
			enterQueueMsg = {
				order = 11,
				name = L["Entering Queue Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.enterQueueMsg = value end,
				get = function(info) return FISConfig.enterQueueMsg end
			},
			fetchErrorMsg = {
				order = 12,
				name = L["Fetch Error Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.fetchErrorMsg = value end,
				get = function(info) return FISConfig.fetchErrorMsg end
			},
			queryQueueMsg = {
				order = 13,
				name = L["Query Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.queryQueueMsg = value end,
				get = function(info) return FISConfig.queryQueueMsg end
			},
			leaveQueueMsg = {
				order = 14,
				name = L["Leave Queue Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.leaveQueueMsg = value end,
				get = function(info) return FISConfig.leaveQueueMsg end
			},
			welcomeMsg = {
				order = 21,
				name = L["Welcome Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.welcomeMsg = value end,
				get = function(info) return FISConfig.welcomeMsg end
			},
			leaveMsg = {
				order = 22,
				name = L["Leave Message"],
				type = "input",
				confirm = true,
				multiline = true,
				set = function(info, value) FISConfig.leaveMsg = value end,
				get = function(info) return FISConfig.leaveMsg end
			},
			textReplace = {
				order = 91,
				name = L["TEXT_REPLACE"],
				type = "description",
			},
		},
	}

	AceConfig:RegisterOptionsTable("FIS", generalOptions, "/fis")
	AceConfig:RegisterOptionsTable("FIS_MSG", messageOptions, nil)
	AceConfigDialog:AddToBlizOptions("FIS", L["Free Instance Sharer"])
	AceConfigDialog:AddToBlizOptions("FIS_MSG", L["Notify Message"], "FIS")
end

function eventFrame:UPDATE_INSTANCE_INFO ()
	if FISConfig.enable and FISConfig.autoExtend then
		for i = 1, GetNumSavedInstances() do
			local _, _, _, difficulty, _, extended = GetSavedInstanceInfo(i)
			-- Thanks for SavedInstances
			local link = GetSavedInstanceChatLink(i)
			local instanceID = link:match(":(%d+):%d+:%d+\124h");
			instanceID = instanceID and tonumber(instanceID)
			if not extended and autoLeaveInstanceMapID[instanceID] then
				local difficulties = autoLeaveInstanceMapID[instanceID]
				local curr
				for _, curr in pairs(difficulties) do
					if difficulty == curr then
						SetSavedInstanceExtend(i, true)
						break
					end
				end
			end
		end
	end
	self.init(self)
end

function eventFrame:PLAYER_CAMPING ()
	if FISConfig.preventAFK then
		local Popup = StaticPopup_Visible("CAMP")
		_G[Popup.."Button1"]:Click()
	end
end

function eventFrame:CHAT_MSG_WHISPER (...)
	debug("Received whisper", ...)
	if FISConfig.enable then
		local message, sender = ...

		local isInviteMsg = message == FISConfig.autoInviteMsg
		local isLeaveMsg = message == FISConfig.autoLeaveMsg

		if FISConfig.autoInvite and isInviteMsg then
			self.addToQueue(self, sender)
		elseif FISConfig.autoLeave and isLeaveMsg then
			self.removeFromQueue(self, sender)
		end
	end
end

function eventFrame:CHAT_MSG_BN_WHISPER (...)
	debug("Received Battle.net whisper", ...)
	if FISConfig.enable then
		local message, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

		local _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfoByID(presenceID)
		local _, characterName, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

		debug("BNGetFriendInfoByID", BNGetFriendInfoByID(presenceID))
		debug("BNGetGameAccountInfo", BNGetGameAccountInfo(bnetIDGameAccount))

		local isInviteMsg = message == FISConfig.autoInviteBNMsg

		if FISConfig.autoInviteBN and isInviteMsg then
			if characterName and characterName ~= "" and realmName and realmName ~= "" then
				self.addToQueue(self, characterName .. "-" .. realmName)
			else
				local message = self.format(FISConfig.fetchErrorMsg, nil)
				BNSendWhisper(presenceID, message)
			end
		end
	end
end

function eventFrame:GROUP_ROSTER_UPDATE ()
	-- NOTE: before inviting: 3 times, accepted or rejected: 2 times, leaving party: 2 times
	if not FISConfig.inviteOnly and FISConfig.autoQueue then
		if status == 2 then
			if IsInGroup() then
				if GetNumGroupMembers() > 1 then
					-- accepted
					self.playerInvited(self)
				end
				-- otherwise still waiting
			else
				-- rejected
				self.playerRejected(self)
			end
		elseif status == 3 then
			if not IsInGroup() then
				-- player leaved
				self.playerLeaved(self)
			end
		end
	end
end

function eventFrame:CHAT_MSG_PARTY (...)
	debug("Received party message", ...)
	local message = ...

	if not FISConfig.inviteOnly and FISConfig.autoQueue then
		local RaidDifficulty = GetRaidDifficultyID()
		local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
		local isTenPlayer = LegacyRaidDifficulty == 5 or LegacyRaidDifficulty == 3
		local isHeroic = RaidDifficulty == 15

		isTenPlayer = string.find(message, "10")
		isHeroic = string.find(message, "H") or string.find(message, "h")
		RaidDifficulty = isHeroic and 15 or 14
		LegacyRaidDifficulty = isHeroic and (isTenPlayer and 5 or 6) or (isTenPlayer and 3 or 4)

		SetRaidDifficultyID(RaidDifficulty)
		SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
	end
end
