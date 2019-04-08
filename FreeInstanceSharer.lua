local addonName, addon = ...
local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
addon.Core = Core
_G[addonName] = addon

-- Lua functions
local _G = _G
local print, tinsert, tremove, time, gsub, pairs = print, tinsert, tremove, time, gsub, pairs
local tonumber, tostring, strfind = tonumber, tostring, strfind

-- WoW API / Variables
local BNGetFriendInfoByID = BNGetFriendInfoByID
local BNGetGameAccountInfo = BNGetGameAccountInfo
local BNSendWhisper = BNSendWhisper
local GetLegacyRaidDifficultyID = GetLegacyRaidDifficultyID
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSavedInstances = GetNumSavedInstances
local GetRaidDifficultyID = GetRaidDifficultyID
local GetRealmName = GetRealmName
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local InviteUnit = InviteUnit
local IsInGroup = IsInGroup
local LeaveParty = LeaveParty
local PromoteToLeader = PromoteToLeader
local RequestRaidInfo = RequestRaidInfo
local ResetInstances = ResetInstances
local SendChatMessage = SendChatMessage
local SetLegacyRaidDifficultyID = SetLegacyRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local SetSavedInstanceExtend = SetSavedInstanceExtend
local UnitName = UnitName
local UnitPosition = UnitPosition

-- GLOBALS: FISConfig, StaticPopup_Visible

function Core:debug(...)
    if addon.db and addon.db.debug then
        print("\124cFFFF0000" .. addonName .. "\124r:", ...)
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
    [1530] = {14, 15}, -- 暗夜要塞
    [1676] = {14, 15}, -- 萨格拉斯之墓
    [1712] = {14, 15}, -- 安托鲁斯，燃烧王座

    -- 地下城
    [1651] = {23}, -- 重返卡拉赞
}

function Core:OnEnable()
    if not FISConfig then
        FISConfig = defaultConfig
    else
        for key, value in pairs(defaultConfig) do
            if not FISConfig[key] then
                FISConfig[key] = defaultConfig[key]
            end
        end
    end
    addon.db = FISConfig

    self:RegisterBucketEvent("PLAYER_ENTERING_WORLD", 1, RequestRaidInfo)
    self:RegisterEvent("UPDATE_INSTANCE_INFO")
    self:RegisterEvent("PLAYER_CAMPING")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_BN_WHISPER")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_PARTY")

    self:ScheduleRepeatingTimer("OnUpdate", addon.db.checkInterval / 1000.0)

    self.status = 0
    self.queue = {}
end

function Core:OnUpdate()
    if not addon.db then return end
    if addon.db.enable and not addon.db.inviteOnly then
        if self.status == 1 then
            -- check queue
            if #self.queue > 0 then
                local name = self.queue[1]
                tremove(self.queue, 1)
                self:inviteToGroup(name)
            end
        elseif self.status == 3 then
            -- check max waiting time
            if (
                addon.db.maxWaitingTime and addon.db.maxWaitingTime ~= 0 and
                time() - self.invitedTime >= addon.db.maxWaitingTime
            ) then
                self:leaveGroup()
            end

            -- check player place
            if addon.db.autoLeave then
                local _, _, _, instanceID = UnitPosition("party1")
                if instanceID and autoLeaveInstanceMapID[instanceID] then
                    self:leaveGroup()
                end
            end
        end
    end
end

-- print current status and config to chatframe
-- return nil
function Core:printStatus()
    if addon.db.enable then
        if self.status > 0 then
            if addon.db.inviteOnly then
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
function Core:format(message, curr)
    if curr then
        message = gsub(message, "QCURR", curr)
    end
    message = gsub(message, "QLEN", #self.queue)
    message = gsub(message, "MTIME", addon.db.maxWaitingTime)
    message = gsub(message, "NAME", UnitName("player") .. "-" .. GetRealmName())
    return message
end

-- add a player to queue
-- return nil - not enabled 0 - success 1 - fail(exists)
function Core:addToQueue(name)
    self:debug("Adding to queue:", name)
    if addon.db.enable then
        if not addon.db.inviteOnly and addon.db.autoQueue then
            local result
            for index, curr in pairs(self.queue) do
                if curr == name then
                    result = index
                    break
                end
            end
            if not result then
                tinsert(self.queue, name)
                if addon.db.enterQueueMsg and addon.db.enterQueueMsg ~= "" then
                    local message = self:format(addon.db.enterQueueMsg, #self.queue)
                    SendChatMessage(message, "WHISPER", nil, name)
                end
            else
                if addon.db.queryQueueMsg and addon.db.queryQueueMsg ~= "" then
                    local message = self:format(addon.db.queryQueueMsg, result)
                    SendChatMessage(message, "WHISPER", nil, name)
                end
            end
            return not result
        else
            self:inviteToGroup(name)
            return 0
        end
    end
end

-- remove a player from queue
-- return nil
function Core:removeFromQueue(name)
    self:debug("Removing from queue:", name)
    for index, curr in pairs(self.queue) do
        if curr == name then
            tremove(self.queue, index)
            break
        end
    end
    local message = self:format(addon.db.leaveQueueMsg)
    SendChatMessage(message, "WHISPER", nil, name)
end

-- invite player
-- return nil
function Core:inviteToGroup(name)
    self:debug("Inviting to group:", name)
    if addon.db.enable then
        SetRaidDifficultyID(14) -- 普通难度
        SetLegacyRaidDifficultyID(4) -- 旧世副本难度25人普通
        ResetInstances()
        if not addon.db.inviteOnly and addon.db.autoQueue then
            self.status = 2
        else
            self.status = 1
        end
        InviteUnit(name)
    end
end

-- transfer leader and leave party
-- return nil
function Core:leaveGroup()
    self:debug("BOT leaving group")
    if self.status == 3 then
        if addon.db.leaveMsg and addon.db.leaveMsg ~= "" then
            local message = self:format(addon.db.leaveMsg)
            SendChatMessage(message, "PARTY")
        end
        -- set status first to prevent GROUP_ROSTER_UPDATE handle
        self.status = 1
        PromoteToLeader("party1")
        LeaveParty()
    end
end

function Core:UPDATE_INSTANCE_INFO(event)
    if addon.db.enable and addon.db.autoExtend then
        for i = 1, GetNumSavedInstances() do
            local _, _, _, difficulty, _, extended = GetSavedInstanceInfo(i)
            -- Thanks to SavedInstances
            local link = GetSavedInstanceChatLink(i)
            local instanceID = link:match(":(%d+):%d+:%d+\124h");
            instanceID = instanceID and tonumber(instanceID)
            if not extended and autoLeaveInstanceMapID[instanceID] then
                local difficulties = autoLeaveInstanceMapID[instanceID]
                for _, curr in pairs(difficulties) do
                    if difficulty == curr then
                        SetSavedInstanceExtend(i, true)
                        break
                    end
                end
            end
        end
    end
    if self.status == 0 then
        self.status = 1
        self:printStatus()
    end
end

function Core:PLAYER_CAMPING(event)
    if addon.db.preventAFK then
        local Popup = StaticPopup_Visible("CAMP")
        _G[Popup.."Button1"]:Click()
    end
end

function Core:CHAT_MSG_WHISPER(event, ...)
    self:debug("Received whisper", ...)
    if addon.db.enable then
        local message, sender = ...

        if addon.db.autoInvite and message == addon.db.autoInviteMsg then
            self:addToQueue(sender)
        elseif addon.db.autoLeave and message == addon.db.autoLeaveMsg then
            self:removeFromQueue(sender)
        end
    end
end

function Core:CHAT_MSG_BN_WHISPER(event, ...)
    self:debug("Received Battle.net whisper", ...)
    if addon.db.enable then
        local message, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

        local _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfoByID(presenceID)
        local _, characterName, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

        self:debug("BNGetFriendInfoByID", BNGetFriendInfoByID(presenceID))
        self:debug("BNGetGameAccountInfo", BNGetGameAccountInfo(bnetIDGameAccount))

        if addon.db.autoInviteBN and message == addon.db.autoInviteBNMsg then
            if characterName and characterName ~= "" and realmName and realmName ~= "" then
                self:addToQueue(characterName .. "-" .. realmName)
            else
                local message = self:format(addon.db.fetchErrorMsg, nil)
                BNSendWhisper(presenceID, message)
            end
        end
    end
end

function Core:GROUP_ROSTER_UPDATE(event)
    if addon.db.enable and not addon.db.inviteOnly and addon.db.autoQueue then
        if self.status == 2 then
            if IsInGroup() then
                if GetNumGroupMembers() > 1 then
                    -- accepted
                    self:debug("Player accepted invition")
                    self.invitedTime = time()
                    if addon.db.welcomeMsg and addon.db.welcomeMsg ~= "" then
                        local message = self:format(addon.db.welcomeMsg)
                        SendChatMessage(message, "PARTY")
                    end
                    self.status = 3
                end
                -- still waiting
            else
                -- rejected
                self:debug("Player rejected invition")
                self.status = 1
            end
        elseif self.status == 3 then
            if not IsInGroup() then
                -- player leaved
                self:debug("Player leaved group")
                self.status = 1
            end
        end
    end
end

function Core:CHAT_MSG_PARTY(event, ...)
    self:debug("Received party message", ...)
    local message = ...

    if addon.db.enable and not addon.db.inviteOnly and addon.db.autoQueue then
        local RaidDifficulty = GetRaidDifficultyID()
        local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
        local isTenPlayer = LegacyRaidDifficulty == 5 or LegacyRaidDifficulty == 3
        local isHeroic = RaidDifficulty == 15

        isTenPlayer = strfind(message, "10")
        isHeroic = strfind(message, "H") or strfind(message, "h")
        RaidDifficulty = isHeroic and 15 or 14
        LegacyRaidDifficulty = isHeroic and (isTenPlayer and 5 or 6) or (isTenPlayer and 3 or 4)

        SetRaidDifficultyID(RaidDifficulty)
        SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
    end
end
