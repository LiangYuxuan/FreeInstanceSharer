local addonName, addon = ...
local Core = LibStub('AceAddon-3.0'):NewAddon(addonName, 'AceEvent-3.0', 'AceTimer-3.0', 'AceBucket-3.0')
local L = addon.L
addon.Core = Core
_G[addonName] = addon

-- Lua functions
local _G = _G
local print, tinsert, tremove, time, gsub, pairs = print, tinsert, tremove, time, gsub, pairs
local tonumber, strfind = tonumber, strfind

-- WoW API / Variables
local BNSendWhisper = BNSendWhisper
local GetLegacyRaidDifficultyID = GetLegacyRaidDifficultyID
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSavedInstances = GetNumSavedInstances
local GetRaidDifficultyID = GetRaidDifficultyID
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local IsInGroup = IsInGroup
local PromoteToLeader = PromoteToLeader
local RequestRaidInfo = RequestRaidInfo
local ResetInstances = ResetInstances
local SendChatMessage = SendChatMessage
local SetDungeonDifficultyID = SetDungeonDifficultyID
local SetLegacyRaidDifficultyID = SetLegacyRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local SetSavedInstanceExtend = SetSavedInstanceExtend
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
Core.playerFullName = UnitName('player') .. '-' .. GetRealmName()

function Core:debug(...)
    if addon.db and addon.db.debug then
        print(Core.addonPrefix, format(...))
    end
end

local defaultConfig = {
    ["debug"] = false, -- Debug mode
    ["enable"] = false, -- Enable
    ["inviteOnly"] = false, -- Invite Only Mode
    ["preventAFK"] = false, -- Prevent AFK
    ["autoExtend"] = true, -- Auto extend saved lockouts
    ["autoInvite"] = true, -- Auto invite when received preset message
    ["autoInviteMsg"] = "123", -- Message to get invited
    ["autoInviteBN"] = true, -- Auto invite when received preset message from Battle.net
    ["autoInviteBNMsg"] = "123", -- Message from Battle.net to get invited
    ["autoLeave"] = true, -- Auto leave queue when received preset message
    ["autoLeaveMsg"] = "233", -- Message to leave queue
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
    [720] = {14, 15}, -- Firelands
    [967] = {3, 4, 5, 6}, -- Dragon Soul
    -- Mists of Pandaria
    [996] = {3, 4, 5, 6}, -- Terrace of Endless Spring
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
    -- [2097] = {23}, -- Operation: Mechagon
}

function Core:OnEnable()
    if not FISConfig then
        FISConfig = defaultConfig
    else
        for key, value in pairs(defaultConfig) do
            if not FISConfig[key] then
                FISConfig[key] = value
            end
        end
    end
    addon.db = FISConfig

    self:RegisterBucketEvent('PLAYER_ENTERING_WORLD', 1, RequestRaidInfo)
    self:RegisterEvent('UPDATE_INSTANCE_INFO')
    self:RegisterEvent('PLAYER_CAMPING')
    self:RegisterEvent('CHAT_MSG_WHISPER')
    self:RegisterEvent('CHAT_MSG_BN_WHISPER')
    self:RegisterEvent('GROUP_ROSTER_UPDATE')
    self:RegisterEvent('CHAT_MSG_PARTY')

    self:ScheduleRepeatingTimer('OnUpdate', .5)

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
                self:debug("Bot leaving group: max waiting time exceeded")
                self:leaveGroup()
            end

            -- check player place
            if addon.db.autoLeave then
                local _, _, _, instanceID = UnitPosition('party1')
                if instanceID and autoLeaveInstanceMapID[instanceID] then
                    self:debug("Bot leaving group: player entered instance")
                    self:leaveGroup()
                end
            end
        end
    end
end

-- print current status and config to chatframe
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

-- send formatted message
function Core:sendMessage(message, chatType, channel, currIndex)
    if not message or message == '' then return end
    
    if curr then
        message = gsub(message, 'QCURR', currIndex)
    end
    message = gsub(message, 'QLEN', #self.queue)
    message = gsub(message, 'MTIME', addon.db.maxWaitingTime)
    message = gsub(message, 'NAME', self.playerFullName)

    if chatType == 'BNWHISPER' then
        BNSendWhisper(channel, message)
    end

    return SendChatMessage(message, chatType, nil, channel)
end

-- add a player to queue
function Core:addToQueue(name)
    self:debug("Adding %s to queue", name)
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
            self:sendMessage(addon.db.enterQueueMsg, 'WHISPER', name, #self.queue)
        else
            self:sendMessage(addon.db.queryQueueMsg, 'WHISPER', name, result)
        end
    else
        self:inviteToGroup(name)
    end
end

-- remove a player from queue
function Core:removeFromQueue(name)
    self:debug("Removing %s from queue", name)
    for index, curr in pairs(self.queue) do
        if curr == name then
            tremove(self.queue, index)
            break
        end
    end
    self:sendMessage(addon.db.leaveQueueMsg, 'WHISPER', name)
end

-- invite player
function Core:inviteToGroup(name)
    self:debug("Inviting %s to party", name)

    SetDungeonDifficultyID(DIFFICULTY_DUNGEON_MYTHIC) -- Dungeon Mythic
    SetRaidDifficultyID(DIFFICULTY_PRIMARYRAID_NORMAL) -- Raid Normal
    SetLegacyRaidDifficultyID(DIFFICULTY_RAID25_NORMAL) -- Legacy Raid 25 Players Normal
    ResetInstances()
    if not addon.db.inviteOnly and addon.db.autoQueue then
        self.status = 2
    else
        self.status = 1
    end
    C_PartyInfo.ConfirmInviteUnit(name)
end

-- transfer leader and leave party
function Core:leaveGroup()
    if self.status == 3 then
        self:sendMessage(message, 'PARTY')
        -- set status first to prevent GROUP_ROSTER_UPDATE handle
        self.status = 1
        PromoteToLeader('party1')
        C_PartyInfo.ConfirmLeaveParty()
    end
end

function Core:UPDATE_INSTANCE_INFO()
    if not addon.db.enable then return end

    if addon.db.autoExtend then
        for i = 1, GetNumSavedInstances() do
            local _, _, _, difficulty, _, extended = GetSavedInstanceInfo(i)
            -- Thanks to SavedInstances
            local link = GetSavedInstanceChatLink(i)
            local instanceID = link:match(':(%d+):%d+:%d+\124h');
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

function Core:PLAYER_CAMPING()
    if not addon.db.preventAFK then return end

    local Popup = StaticPopup_Visible('CAMP')
    _G[Popup .. 'Button1']:Click()
end

function Core:CHAT_MSG_WHISPER(_, text, sender)
    self:debug("Received whisper '%s' from %s", text, sender)
    if not addon.db.endable then return end

    if addon.db.autoInvite and text == addon.db.autoInviteMsg then
        self:addToQueue(sender)
    elseif addon.db.autoLeave and text == addon.db.autoLeaveMsg then
        self:removeFromQueue(sender)
    end
end

function Core:CHAT_MSG_BN_WHISPER(_, text, playerName, _, _, _, _, _, _, _, _, _, guid, presenceID)
    self:debug("Received Battle.net whisper '%s' from %s(%s), presenceID = %s", text, playerName, guid, presenceID)
    if not addon.db.enable or not addon.db.autoInviteBN or text ~= addon.db.autoInviteBNMsg then return end

    local gameAccountInfo = C_BattleNet.GetGameAccountInfoByGUID(guid)
    local characterName, realmName = gameAccountInfo.characterName, gameAccountInfo.realmName

    self:debug("Received character %s on %s", characterName, realmName)

    if characterName and characterName ~= '' and realmName and realmName ~= '' then
        self:addToQueue(characterName .. '-' .. realmName)
    else
        self:sendMessage(addon.db.fetchErrorMsg, 'BNWHISPER', presenceID)
    end
end

function Core:GROUP_ROSTER_UPDATE()
    if not addon.db.enable or addon.db.inviteOnly or not addon.db.autoQueue then return end
    
    if self.status == 2 then
        if IsInGroup() then
            if GetNumGroupMembers() > 1 then
                -- accepted
                self:debug("Player accepted invition")
                self.invitedTime = time()
                self:sendMessage(addon.db.welcomeMsg, 'PARTY')
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

function Core:CHAT_MSG_PARTY(_, text, playerName)
    self:debug("Received party message '%s' from %s", text, playerName)
    if not addon.db.enable or addon.db.inviteOnly or not addon.db.autoQueue then return end

    local RaidDifficulty = GetRaidDifficultyID()
    local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
    local isTenPlayer = LegacyRaidDifficulty == 5 or LegacyRaidDifficulty == 3
    local isHeroic = RaidDifficulty == 15

    isTenPlayer = strfind(text, '10')
    isHeroic = strfind(text, 'H') or strfind(text, 'h')
    RaidDifficulty = isHeroic and DIFFICULTY_PRIMARYRAID_HEROIC or DIFFICULTY_PRIMARYRAID_NORMAL
    LegacyRaidDifficulty = isHeroic and (
        isTenPlayer and DIFFICULTY_RAID10_HEROIC or DIFFICULTY_RAID25_HEROIC
    ) or (
        isTenPlayer and DIFFICULTY_RAID10_NORMAL or DIFFICULTY_RAID25_NORMAL
    )

    SetRaidDifficultyID(RaidDifficulty)
    SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
end
