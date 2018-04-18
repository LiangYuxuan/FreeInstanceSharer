local _, addon = ...
local L = addon.L

local defaultConfig = {
  ["enable"] = false, -- 启动时启用
  ["inviteOnly"] = false, -- 极简模式（只启用防AFK、自动延长锁定、密语进组）
  ["preventAFK"] = true, -- 防AFK
  ["autoExtend"] = true, -- 自动延长锁定
  ["autoInvite"] = true, -- 密语进组
  ["autoInviteMsg"] = "123", -- 密语进组信息
  ["autoInviteBN"] = true, -- 战网密语进组
  ["autoInviteBNMsg"] = "123", -- 战网密语进组信息
  ["checkInterval"] = 0.5, -- 检查间隔
  ["autoQueue"] = true, -- 进组申请排队
  ["maxWaitingTime"] = 30, -- 最长在组等待时间 (0 - 无限制)
  ["autoLeave"] = true, -- 检查成员位置并退组
  ["welcomeMsg"] = true, -- 进组时发送信息
  ["leaveMsg"] = true, -- 退组时发送信息
}

local autoLeaveInstanceMapID = {
  531, -- 安其拉神殿
  564, -- 黑暗神殿
  603, -- 奥杜尔
  631, -- 冰冠堡垒
  669, -- 黑翼血环
  754, -- 风神王座
  720, -- 火焰之地
  967, -- 巨龙之魂
  966, -- 永春台
  1008, -- 魔古山宝库
  1098, -- 雷电王座
  1136, -- 决战奥格瑞玛
  1205, -- 黑石铸造厂
  1448, -- 地狱火堡垒
}

local status = 0 -- 运行状态 0 - 未就绪 1 - 空闲 2 - 正在邀请 3 - 已经进组
local timeElapsed = 0 -- 上次检查时间间隔
local queue = {} -- 排队队列
local invitedTime -- 接受邀请的时间
local groupRosterUpdateTimes -- GROUP_ROSTER_UPDATE 触发次数

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
          local posY, posX, posZ, instanceID = UnitPosition("party1")
          if instanceID then
            local ID
            for _, ID in pairs(autoLeaveInstanceMapID) do
              if instanceID == ID then
                self.leaveGroup(self)
                break
              end
            end
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
        print(L["MSG_PREFIX"] .. L["INVITE_ONLY_MODE"])
      else
        print(L["MSG_PREFIX"] .. L["SHARE_STARTED"])
      end
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
    if not FISConfig.inviteOnly and FISConfig.autoQueue then
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
    if not FISConfig.inviteOnly and FISConfig.autoQueue then
      groupRosterUpdateTimes = 0
      status = 2
    else
      status = 1
    end
  end
end

-- mark invited
-- return nil
function eventFrame:playerInvited ()
  invitedTime = time()
  SendChatMessage(L["WELCOME_MSG"], "PARTY")
  status = 3
end

-- mark rejected
-- return nil
function eventFrame:playerRejected ()
  status = 1
end

-- mark leaved
-- return nil
function eventFrame:playerLeaved ()
  status = 1
end

-- transfer leader and leave party
-- return nil
function eventFrame:leaveGroup ()
  if status == 3 then
    SendChatMessage(L["LEAVE_MSG"], "PARTY")
    -- set status first to prevent GROUP_ROSTER_UPDATE handle
    status = 1
    PromoteToLeader("party1")
    LeaveParty()
  end
end

function eventFrame:slashCmdHandler (message, editbox)
  -- TODO: Opition Page
  FISConfig.enable = not FISConfig.enable
  status = 0
  self.printStatus(self)
  if FISConfig.enable then
    RequestRaidInfo()
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

function eventFrame:PLAYER_CAMPING ()
  if FISConfig.preventAFK then
    local Popup = StaticPopup_Visible("CAMP")
    _G[Popup.."Button1"]:Click()
  end
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
      self.addToQueue(self, characterName .. "-" .. realmName)
    end
  end
end

function eventFrame:GROUP_ROSTER_UPDATE ()
  -- NOTE: before inviting: 2 times, accepted or rejected: 1 times, leaving party: 3 times
  if not FISConfig.inviteOnly and FISConfig.autoQueue then
    groupRosterUpdateTimes = groupRosterUpdateTimes + 1
    if groupRosterUpdateTimes > 2 then
      if status == 2 then
        if GetNumGroupMembers() > 1 then
          -- accepted
          self.playerInvited(self)
        else
          -- rejected
          self.playerRejected(self)
        end
      elseif status == 3 then
        if not IsInGroup() or GetNumGroupMembers() == 1 then
          -- player leaved
          self.playerLeaved(self)
        end
      end
    end
  end
end

function eventFrame:CHAT_MSG_PARTY (...)
  local message = ...

  if not FISConfig.inviteOnly and FISConfig.autoQueue then
    local isTenPlayer = string.find(message, "10")
    local isHeroic = string.find(message, "H") or string.find(message, "h")

    local RaidDifficulty = isHeroic and 15 or 14
    local LegacyRaidDifficulty = isHeroic and (isTenPlayer and 5 or 6) or (isTenPlayer and 3 or 4)

    SetRaidDifficultyID(RaidDifficulty)
    SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
  end
end

SLASH_FIS1 = "/fis"
SlashCmdList["FIS"] = function (...)
  eventFrame.slashCmdHandler(eventFrame, ...)
end
