--------------------
-- FreeInstanceSharer.lua
--
-- 2017/12/11
--------------------

local _, addon = ...
local L = addon.L

local enable = true -- 启动时启用
local autoDifficulty = true -- 自动修改难度
local autoExtend = true -- 自动延长锁定
local autoInvite = true -- 密语进组
local autoInviteMsg = "123" -- 密语进组信息
local autoInviteBN = true -- 战网密语进组
local autoInviteBNMsg = "123" -- 战网密语进组信息
local autoLeave = true -- 小队发言退组

local function print_status ()
  if enable then
    print(L["MSG_PREFIX"] .. L["SHARE_START"])
    print(L["AUTO_DIFF"] .. (autoDifficulty and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
    print(L["AUTO_EXTEND"] .. (autoExtend and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
    print(L["AUTO_INVITE"] .. (autoInvite and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], autoInviteMsg))
    print(L["AUTO_INVITE_BN"] .. (autoInviteBN and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], autoInviteBNMsg))
    print(L["AUTO_LEAVE"] .. (autoLeave and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
  else
    print(L["MSG_PREFIX"] .. L["SHARE_STOP"])
  end
end

local function start ()
  if autoDifficulty then
    SetRaidDifficultyID(14) -- 普通难度
    SetLegacyRaidDifficultyID(4) -- 旧世副本难度25人普通
  end
  if autoExtend then
    for i = 1, GetNumSavedInstances() do
      local _, _, _, _, _, extended = GetSavedInstanceInfo(i)
      if not extended then
        SetSavedInstanceExtend(i, true) -- 延长副本锁定
      end
    end
  end
  enable = true
  print_status()
end

local function stop ()
  enable = false
  print_status()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_PARTY")
eventFrame:SetScript("OnEvent", function (self, event, ...)
  if not enable then return end
	self[event](self, ...)
end)

SLASH_FIS1 = "/fis"
SlashCmdList["FIS"] = function (msg, editbox)
  if enable then stop() else start() end
end

function eventFrame:PLAYER_LOGIN ()
  start()
end

function eventFrame:CHAT_MSG_WHISPER (...)
  local message, sender = ...

  local isInviteMsg = message == autoInviteMsg

  if autoInvite and isInviteMsg then
    ResetInstances()
    InviteUnit(sender)
  end
end

function eventFrame:CHAT_MSG_BN_WHISPER (...)
  local message, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

  local _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfoByID(presenceID)
  local _, characterName, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

  local isInviteMsg = message == autoInviteBNMsg

  if autoInviteBN and isInviteMsg then
    ResetInstances()
    InviteUnit(characterName .. "-" .. realmName)
  end
end

function eventFrame:CHAT_MSG_PARTY (...)
  if autoLeave then
    PromoteToLeader("party1")
    LeaveParty()
  end
end
