local _, addon = ...
local L = addon.L

local defaultConfig = {
  ["enable"] = true, -- 启动时启用
  ["autoExtend"] = true, -- 自动延长锁定
  ["checkInterval"] = 0.5, -- 检查间隔
  ["autoInvite"] = true, -- 密语进组
  ["autoInviteMsg"] = "123", -- 密语进组信息
  ["autoInviteBN"] = true, -- 战网密语进组
  ["autoInviteBNMsg"] = "123", -- 战网密语进组信息
  ["autoQueue"] = true, -- 进组申请排队
  ["welcomeMsg"] = true, -- 显示欢迎信息
  ["maxWaitingTime"] = 30, -- 最长在组等待时间 (0 - 无限制)
  ["autoLeave"] = true, -- 检查成员位置并退组
}

local autoLeavePlacesID = {
  766, -- 安其拉
  796, -- 黑暗神殿
  529, -- 奥杜尔
  604, -- 冰冠堡垒
  754, -- 黑翼血环
  773, -- 风神王座
  800, -- 火焰之地
  824, -- 巨龙之魂
  886, -- 永春台
  896, -- 魔古山宝库
  930, -- 雷电王座
  953, -- 决战奥格瑞玛
  988, -- 黑石铸造厂
  1026, -- 地狱火堡垒
}

local status = 0 -- 运行状态 0 - 未就绪 1 - 空闲 2 - 正在邀请 3 - 已经进组
local queue = {} -- 排队队列
local invitedTime -- 接受邀请的时间
local timeElapsed = 0 -- 上次检查时间间隔
local autoLeavePlaces = {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
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
  timeElapsed = timeElapsed + elapsed
  if FISConfig.enable and timeElapsed >= FISConfig.checkInterval then
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
      if FISConfig.maxWaitingTime and time() - invitedTime >= FISConfig.maxWaitingTime then
        self.leaveGroup(self)
      end

      -- check player place
      if FISConfig.autoLeave then
        local _, _, _, _, _, _, zone = GetRaidRosterInfo(2);
        print("Get Player Zone: " .. zone)
        local flag, place = false
        for _, place in pairs(autoLeavePlaces) do
          if zone == place then
            flag = true
            break
          end
        end
        if flag then
          self.leaveGroup(self)
        end
      end
    end
  end
end

-- initialization
-- return nil
function eventFrame:init ()
  if status == 0 then
    local ID;
    for _, ID in pairs(autoLeavePlacesID) do
      table.insert(autoLeavePlaces, GetMapNameByID(ID))
    end
    self.printStatus(self)
    status = 1
  end
end

-- print current status and config to chatframe
-- return nil
function eventFrame:printStatus ()
  if FISConfig.enable then
    if status then
      print(L["MSG_PREFIX"] .. L["SHARE_STARTED"])
      print(L["AUTO_EXTEND"] .. (FISConfig.autoExtend and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["CHECK_INVAL"] .. FISConfig.checkInterval .. "s")
      print(L["AUTO_INVITE"] .. (FISConfig.autoInvite and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], FISConfig.autoInviteMsg))
      print(L["AUTO_INVITE_BN"] .. (FISConfig.autoInviteBN and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], FISConfig.autoInviteBNMsg))
      print(L["AUTO_QUEUE"] .. (FISConfig.autoQueue and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["SHOW_WELCOME_MSG"] .. (FISConfig.welcomeMsg and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["MAX_TIME"] .. FISConfig.maxWaitingTime .. "s")
      print(L["AUTO_LEAVE"] .. (FISConfig.autoLeave and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
    else
      print(L["MSG_PREFIX"] .. L["SHARE_STARTING"])
    end
  else
    print(L["MSG_PREFIX"] .. L["SHARE_STOP"])
  end
end

-- add a player to queue
-- return nil - not enabled 0 - success 1 - fail(exists)
function eventFrame:addToQueue (name)
  if FISConfig.enable then
    if FISConfig.autoQueue then
      local flag, curr = false
      for _, curr in pairs(queue) do
        if curr == name then
          flag = true
          break
        end
      end
      if flag == false then
        SendChatMessage(string.format(L["QUEUE_MSG"], #queue + 1), "WHISPER", nil, name)
        table.insert(queue, name)
      end
      return not flag
    else
      self.inviteToGroup(self, name)
      return 0
    end
  end
end

-- invite player
-- return nil
function eventFrame:inviteToGroup (name)
  if FISConfig.enable then
    SetRaidDifficultyID(14) -- 普通难度
    SetLegacyRaidDifficultyID(4) -- 旧世副本难度25人普通
    ResetInstances()
    InviteUnit(name)
    status = 2
  end
end

-- mark invited
-- return nil
function eventFrame:playerInvited ()
  invitedTime = time()
  SendChatMessage(L["WELCOME_MSG"], "PARTY")
  status = 3
end

function eventFrame:leaveGroup ()
  if status == 3 then
    PromoteToLeader("party1")
    LeaveParty()
    status = 1
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
end

function eventFrame:UPDATE_INSTANCE_INFO ()
  if FISConfig.enable and FISConfig.autoExtend then
    for i = 1, GetNumSavedInstances() do
      local _, _, _, _, _, extended = GetSavedInstanceInfo(i)
      if not extended then
        SetSavedInstanceExtend(i, true) -- 延长副本锁定
      end
    end
  end
  self.init(self)
end

function eventFrame:CHAT_MSG_WHISPER (...)
  if FISConfig.enable then
    local message, sender = ...

    local isInviteMsg = message == FISConfig.autoInviteMsg

    if FISConfig.autoInvite and isInviteMsg then
      self.addToQueue(self, sender)
    end
  end
end

function eventFrame:CHAT_MSG_BN_WHISPER (...)
  if FISConfig.enable then
    local message, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

    local _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfoByID(presenceID)
    local _, characterName, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

    local isInviteMsg = message == FISConfig.autoInviteBNMsg

    if FISConfig.autoInviteBN and isInviteMsg then
      self.addToQueue(characterName .. "-" .. realmName)
    end
  end
end

function eventFrame:GROUP_ROSTER_UPDATE (...)
  -- TODO: handle this event
  self.playerInvited(self)
  -- DEBUG: shows when this event fired
  print("GROUP_ROSTER_UPDATE fired with args: ", ...)
end

function eventFrame:CHAT_MSG_PARTY (...)
  local message = ...
  -- TODO: H / 10 CHANGE
end

-- TODO: rewrite function to eventFrame
SLASH_FIS1 = "/fis"
SlashCmdList["FIS"] = function (msg, editbox)
  FISConfig.enable = not FISConfig.enable
  eventFrame.printStatus(eventFrame)
  -- TODO: not only change enable
end
