local addonName, addon = ...
local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local L = addon.L
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
local SetDungeonDifficultyID = SetDungeonDifficultyID
local SetLegacyRaidDifficultyID = SetLegacyRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local SetSavedInstanceExtend = SetSavedInstanceExtend
local UnitName = UnitName
local UnitPosition = UnitPosition

local DIFFICULTY_PRIMARYRAID_NORMAL = DIFFICULTY_PRIMARYRAID_NORMAL
local DIFFICULTY_PRIMARYRAID_HEROIC = DIFFICULTY_PRIMARYRAID_HEROIC
local DIFFICULTY_RAID10_NORMAL = DIFFICULTY_RAID10_NORMAL
local DIFFICULTY_RAID25_NORMAL = DIFFICULTY_RAID25_NORMAL
local DIFFICULTY_RAID10_HEROIC = DIFFICULTY_RAID10_HEROIC
local DIFFICULTY_RAID25_HEROIC = DIFFICULTY_RAID25_HEROIC
local SLASH_STOPWATCH_PARAM_STOP1 = SLASH_STOPWATCH_PARAM_STOP1
local SOCIAL_SHARE_TEXT = SOCIAL_SHARE_TEXT
local START = START

-- GLOBALS: FISConfig, StaticPopup_Visible

local DIFFICULTY_DUNGEON_MYTHIC = 23
local FONTEND = FONT_COLOR_CODE_CLOSE
local REDFONT = RED_FONT_COLOR_CODE
local GREENFONT = GREEN_FONT_COLOR_CODE

Core.addonPrefix = "\124cFF70B8FF" .. addonName .. "\124r:"

function Core:debug(...)
    if addon.db and addon.db.debug then
        print(Core.addonPrefix, ...)
    end
end

local defaultConfig = {
    ["debug"] = false, -- Debug mode
    ["enable"] = false, -- Enable
    ["inviteOnly"] = false, -- Invite Only Mode
    ["preventAFK"] = true, -- Prevent AFK
    ["autoExtend"] = true, -- Auto extend saved lockouts
    ["autoInvite"] = true, -- Auto invite when received preset message
    ["autoInviteMsg"] = "123", -- Message to get invited
    ["autoInviteBN"] = true, -- Auto invite when received preset message from Battle.net
    ["autoInviteBNMsg"] = "123", -- Message from Battle.net to get invited
    ["autoLeave"] = true, -- Auto leave queue when received preset message
    ["autoLeaveMsg"] = "233", -- Message to leave queue
    ["checkInterval"] = 500, -- Check interval
    ["autoQueue"] = true, -- Auto queue when more than one player try to get invited
    ["maxWaitingTime"] = 30, -- Max time to wait players to enter instances
    ["autoLeave"] = true, -- Auto leave party when players are in instances
    ["enterQueueMsg"] = L["You're queued, and your postion is QCURR."], -- Message when entering queue
    ["fetchErrorMsg"] = L["Fail to fetch your character infomation from Battle.net, please try to whisper to NAME in game."], -- Message when fail to fetch character from Battle.net
    ["queryQueueMsg"] = L["You're queued, and your postion is QCURR."], -- Message when query the positon in queue
    ["leaveQueueMsg"] = ERR_LFG_LEFT_QUEUE, -- Message when leaving queue
    ["welcomeMsg"] = L["You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."], -- Welcome message after invited
    ["leaveMsg"] = L["Promoted you to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."], -- Message before leaving party
}

local autoLeaveInstanceMapID = {
    -- Raid
    -- Vanilla
    [531] = {14}, -- Temple of Ahn'Qiraj
    -- The Burning Crusade
    [564] = {14}, -- Black Temple
    -- Wrath of the Lich King
    [603] = {14}, -- Ulduar
    [631] = {3, 4, 5, 6}, -- Icecrown Citadel
    -- Cataclysm
    [669] = {3, 4, 5, 6}, -- Blackwing Descent
    [754] = {3, 4, 5, 6}, -- Throne of the Four Winds
    [720] = {3, 4, 5, 6}, -- Firelands
    [967] = {3, 4, 5, 6}, -- Dragon Soul
    -- Mists of Pandaria
    [966] = {3, 4, 5, 6}, -- Terrace of Endless Spring
    [1008] = {3, 4, 5, 6}, -- Mogu'shan Vaults
    [1098] = {3, 4, 5, 6}, -- Throne of Thunder
    [1136] = {15}, -- Siege of Orgrimmar
    -- Warlords of Draenor
    [1205] = {14, 15}, -- Blackrock Foundry
    [1448] = {14, 15}, -- Hellfire Citadel
    -- Legion
    [1520] = {15}, -- The Emerald Nightmare
    [1530] = {14, 15}, -- The Nighthold
    [1676] = {14, 15}, -- Tomb of Sargeras
    [1712] = {14, 15}, -- Antorus, the Burning Throne
    -- Battle for Azeroth
    -- [2070] = {14, 15}, -- Battle of Dazar'alor

    -- Dungeon
    -- Legion
    [1651] = {23}, -- Return to Karazhan
    -- Battle for Azeroth
    -- [1754] = {23}, -- Freehold
    -- [1762] = {23}, -- Kings' Rest
    -- [1841] = {23}, -- The Underrot
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
        if addon.db.inviteOnly then
            print(self.addonPrefix .. GREENFONT .. L["Invite Only Mode"] .. FONTEND)
        else
            print(self.addonPrefix .. GREENFONT .. START .. FONTEND .. SOCIAL_SHARE_TEXT)
        end
    else
        print(self.addonPrefix .. REDFONT .. SLASH_STOPWATCH_PARAM_STOP1 .. FONTEND .. SOCIAL_SHARE_TEXT)
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
        SetDungeonDifficultyID(DIFFICULTY_DUNGEON_MYTHIC) -- Dungeon Mythic
        SetRaidDifficultyID(DIFFICULTY_PRIMARYRAID_NORMAL) -- Raid Normal
        SetLegacyRaidDifficultyID(DIFFICULTY_RAID25_NORMAL) -- Legacy Raid 25 Players Normal
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
                -- player left
                self:debug("Player left group")
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
        RaidDifficulty = isHeroic and DIFFICULTY_PRIMARYRAID_HEROIC or DIFFICULTY_PRIMARYRAID_NORMAL
        LegacyRaidDifficulty = isHeroic and (
            isTenPlayer and DIFFICULTY_RAID10_HEROIC or DIFFICULTY_RAID25_HEROIC
        ) or (
            isTenPlayer and DIFFICULTY_RAID10_NORMAL or DIFFICULTY_RAID25_NORMAL
        )

        SetRaidDifficultyID(RaidDifficulty)
        SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
    end
end
