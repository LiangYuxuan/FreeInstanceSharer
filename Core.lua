local F, L = unpack(select(2, ...))

-- Lua functions
local _G = _G
local bit_band, bit_bor, format, gsub, ipairs, pairs, select = bit.band, bit.bor, format, gsub, ipairs, pairs, select
local strfind, strlower, time, tinsert, tonumber, tremove, type = strfind, strlower, time, tinsert, tonumber, tremove, type

-- WoW API / Variables
local BNSendWhisper = BNSendWhisper
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local C_PartyInfo_ConfirmConvertToRaid = C_PartyInfo.ConfirmConvertToRaid
local C_PartyInfo_ConfirmInviteUnit = C_PartyInfo.ConfirmInviteUnit
local C_PartyInfo_ConfirmLeaveParty = C_PartyInfo.ConfirmLeaveParty
local C_PartyInfo_ConvertToParty = C_PartyInfo.ConvertToParty
local C_PartyInfo_GetInviteReferralInfo = C_PartyInfo.GetInviteReferralInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetInviteConfirmationInfo = GetInviteConfirmationInfo
local GetLegacyRaidDifficultyID = GetLegacyRaidDifficultyID
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSavedInstances = GetNumSavedInstances
local GetRaidDifficultyID = GetRaidDifficultyID
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local PromoteToLeader = PromoteToLeader
local RequestRaidInfo = RequestRaidInfo
local ResetInstances = ResetInstances
local RespondToInviteConfirmation = RespondToInviteConfirmation
local SendChatMessage = SendChatMessage
local SetDungeonDifficultyID = SetDungeonDifficultyID
local SetLegacyRaidDifficultyID = SetLegacyRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local SetSavedInstanceExtend = SetSavedInstanceExtend
local UnitPosition = UnitPosition

local tContains = tContains
local StaticPopup_Visible = StaticPopup_Visible
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide

local Enum_PartyRequestJoinRelation_Friend = Enum.PartyRequestJoinRelation.Friend
local Enum_PartyRequestJoinRelation_Guild = Enum.PartyRequestJoinRelation.Guild

local DIFFICULTY_PRIMARYRAID_HEROIC = DIFFICULTY_PRIMARYRAID_HEROIC
local DIFFICULTY_PRIMARYRAID_NORMAL = DIFFICULTY_PRIMARYRAID_NORMAL
local DIFFICULTY_RAID10_HEROIC = DIFFICULTY_RAID10_HEROIC
local DIFFICULTY_RAID10_NORMAL = DIFFICULTY_RAID10_NORMAL
local DIFFICULTY_RAID25_HEROIC = DIFFICULTY_RAID25_HEROIC
local DIFFICULTY_RAID25_NORMAL = DIFFICULTY_RAID25_NORMAL
local ERR_RAID_DIFFICULTY_CHANGED_S = ERR_RAID_DIFFICULTY_CHANGED_S
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local LE_INVITE_CONFIRMATION_REQUEST = LE_INVITE_CONFIRMATION_REQUEST
local LE_INVITE_CONFIRMATION_SUGGEST = LE_INVITE_CONFIRMATION_SUGGEST
local LFG_LIST_LOADING = LFG_LIST_LOADING
local LIGHTYELLOW_FONT_COLOR_CODE = LIGHTYELLOW_FONT_COLOR_CODE
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local SLASH_STOPWATCH_PARAM_STOP1 = SLASH_STOPWATCH_PARAM_STOP1
local SOCIAL_SHARE_TEXT = SOCIAL_SHARE_TEXT
local START = START
local UNLIMITED = UNLIMITED

-- GLOBALS: FISConfig

local STATUS_INIT     = 0
local STATUS_IDLE     = 1
local STATUS_INVITING = 2
local STATUS_INVITED  = 3
local STATUS_LEAVING  = 4

local defaultConfig = {
    ["DBVer"] = 2, -- Database Version
    ["Enable"] = false, -- Enable
    ["StopDC"] = false, -- Stop disconnecting
    ["Debug"] = false, -- Debug mode
    ["AutoExtend"] = true, -- Auto extend saved instances
    ["InviteOnWhisper"] = true, -- Invite when received preset whisper message
    ["InviteOnWhisperMsg"] = "123", -- Preset whisper message
    ["InviteOnBNWhisper"] = true, -- Invite when received preset Battlen.net whisper message
    ["InviteOnBNWhisperMsg"] = "123", -- Preset Battlen.net whisper message
    ["AutoQueue"] = true, -- Queue when more than one player try to get invited
    ["LeaveQueueOnWhisper"] = true, -- Leave queue when received preset whisper message
    ["LeaveQueueOnWhisperMsg"] = "233", -- Preset whisper message
    ["TimeLimit"] = 30, -- Max time to wait for players to enter instances
    ["AutoLeave"] = true, -- Auto leave party when players are in instances
    ["EnterQueueMsg"] = L["You're queued. Position in queue: QCURR."], -- Message when entering queue
    ["QueryQueueMsg"] = L["You're queued. Position in queue: QCURR."], -- Message when quering the positon in queue
    ["LeaveQueueMsg"] = ERR_LFG_LEFT_QUEUE, -- Message when leaving queue
    ["FetchErrorMsg"] = L["Failed to fetch your character information from Battle.net, please PM NAME."], -- Message when fail to fetch character name and realm from Battle.net
    ["WelcomeMsg"] = L["MTIME second(s) to enter instance. Difficulty set to 25 players normal. Send '10/25/N/H' in party to change, 'leave' to leave, 'raid'/'party' to convert to raid/party."], -- Welcome message when player accepted invitation
    ["TLELeaveMsg"] = L["Time Limit Exceeded. You're promoted to team leader."], -- Message before leaving party due to time limit exceeded
    ["AutoLeaveMsg"] = L["You're promoted to team leader. Good luck!"], -- Message before leaving party due to player entered instance
    ["AutoLeaveMsg631"] = L["You're promoted to team leader. Please set difficulty to Heroic. Good luck!"], -- Alt message before leaving party due to player entered Icecrown Citadel
}

local oldVerDBMap = {
    { -- from nil to 1
        ["debug"] = "Debug",
        ["enable"] = "Enable",
        ["preventAFK"] = "StopDC",
        ["autoExtend"] = "AutoExtend",
        ["autoInvite"] = "InviteOnWhisper",
        ["autoInviteMsg"] = "InviteOnWhisperMsg",
        ["autoInviteBN"] = "InviteOnBNWhisper",
        ["autoInviteBNMsg"] = "InviteOnBNWhisperMsg",
        ["autoLeave"] = "LeaveQueueOnWhisper",
        ["autoLeaveMsg"] = "LeaveQueueOnWhisperMsg",
        ["autoQueue"] = "AutoQueue",
        ["maxWaitingTime"] = "TimeLimit",
        ["enterQueueMsg"] = "EnterQueueMsg",
        ["fetchErrorMsg"] = "FetchErrorMsg",
        ["queryQueueMsg"] = "QueryQueueMsg",
        ["leaveQueueMsg"] = "LeaveQueueMsg",
        ["welcomeMsg"] = "WelcomeMsg",
        ["leaveMsg"] = "AutoLeaveMsg",
    },
    { -- from 1 to 2
        ["MaxWaitingTime"] = "TimeLimit",
        ["LeaveMsg"] = "AutoLeaveMsg"
    },
}

local supportedInstances = {
    -- Raid
    -- Vanilla
    [531] = { -- Temple of Ahn'Qiraj
        [ACHIEVEMENTFRAME_FILTER_ALL .. ' ' .. BOSS_DEAD] = { low = 479, high = 511, diff = {14} }, -- ALL KILLED
    },
    -- The Burning Crusade
    [564] = { -- Black Temple
        [9] = { low = 255, high = 255, diff = {14} }, -- Illidan Stormrage
    },
    -- Wrath of the Lich King
    [603] = { -- Ulduar
        [16] = { low = 3518, high = 122878, diff = {14} }, -- Yogg-Saron
    },
    [631] = { -- Icecrown Citadel
        [12] = { low = 2039, high = 2047, diff = {3, 4, 5, 6} }, -- The Lich King
    },
    -- Cataclysm
    [669] = { -- Blackwing Descent
        [6] = { low = 47, high = 47, diff = {3, 4, 5, 6} }, -- Nefarian and Onyxia
    },
    [720] = { -- Firelands
        [4] = { low = 54, high = 54, diff = {14, 15} }, -- Alysrazor
        [6] = { low = 118, high = 118, diff = {14, 15} }, -- Majordomo Staghelm
        [7] = { low = 119, high = 119, diff = {14} }, -- Ragnaros
    },
    [754] = { -- Throne of the Four Winds
        [2] = { low = 2, high = 2, diff = {3, 4, 5, 6} }, -- Al'Akir
    },
    [967] = { -- Dragon Soul
        [5] = { low = 30, high = 30, diff = {3, 4, 5, 6} }, -- Ultraxion
        [8] = { low = 127, high = 127, diff = {3, 4} }, -- Madness of Deathwing
    },
    -- Mists of Pandaria
    [996] = { -- Terrace of Endless Spring
        [4] = { low = 13, high = 13, diff = {3, 4, 5, 6} }, -- Sha of Fear
    },
    [1008] = { -- Mogu'shan Vaults
        [5] = { low = 27, high = 27, diff = {3, 4, 5, 6} }, -- Elegon
    },
    [1098] = { -- Throne of Thunder
        [2] = { low = 512, high = 512, diff = {3, 4, 5, 6} }, -- Horridon
        [6] = { low = 1676, high = 1676, diff = {3, 4, 5, 6} }, -- Ji-Kun
    },
    [1136] = { -- Siege of Orgrimmar
        [14] = { low = 23551, high = 23551, diff = {15} }, -- Garrosh Hellscream
    },
    -- Warlords of Draenor
    [1205] = { -- Blackrock Foundry
        [10] = { low = 767, high = 767, diff = {14, 15} }, -- Blackhand
    },
    [1448] = { -- Hellfire Citadel
        [5] = { low = 1042, high = 1106, diff = {14, 15} }, -- Kilrogg Deadeye
    },
    -- Legion
    [1520] = { -- The Emerald Nightmare
        [7] = { low = 119, high = 119, diff = {15} }, -- Xavius
    },
    [1530] = { -- The Nighthold
        [10] = { low = 479, high = 991, diff = {14, 15} }, -- Gul'dan
    },
    [1676] = { -- Tomb of Sargeras
        [5] = { low = 3, high = 51, diff = {14, 15} }, -- Mistress Sassz'ine
    },
    [1712] = { -- Antorus, the Burning Throne
        [2] = { low = 128, high = 202, diff = {14, 15} }, -- Felhounds of Sargeras
    },
    -- Battle for Azeroth
    [2070] = { -- Battle of Dazar'alor
        [7] = { low = 863, high = 863, diff = {14, 15} }, -- High Tinker Mekkatorque
    },

    -- Dungeon
    -- Legion
    [1651] = { -- Return to Karazhan
        [4] = { low = 2, high = 51, diff = {23} }, -- Attumen the Huntsman
    },
    -- Battle for Azeroth
    [1754] = { -- Freehold
        [4] = { low = 7, high = 7, diff = {23} }, -- Harlan Sweete
    },
    [1762] = { -- Kings' Rest
        [4] = { low = 7, high = 7, diff = {23} }, -- King Dazar
    },
    [1841] = { -- The Underrot
        [4] = { low = 7, high = 7, diff = {23} }, -- Unbound Abomination
    },
    [2097] = { -- Operation: Mechagon
        [4] = { low = 208, high = 208, diff = {23} }, -- HK-8 Aerial Oppression Unit
    },
}

-- print current status and config to chatframe
function F:PrintStatus()
    if self.db.Enable then
        if self.status == STATUS_INIT then
            self:Print(LIGHTYELLOW_FONT_COLOR_CODE .. LFG_LIST_LOADING .. FONT_COLOR_CODE_CLOSE)
        else
            self:Print(GREEN_FONT_COLOR_CODE .. START .. FONT_COLOR_CODE_CLOSE .. SOCIAL_SHARE_TEXT)
        end
    else
        self:Print(RED_FONT_COLOR_CODE .. SLASH_STOPWATCH_PARAM_STOP1 .. FONT_COLOR_CODE_CLOSE .. SOCIAL_SHARE_TEXT)
    end
end

-- send formatted message
function F:SendMessage(text, chatType, channel, currIndex)
    if not text or text == '' then return end

    text = gsub(text, 'QCURR', currIndex or 0)
    text = gsub(text, 'QLEN', #self.queue)
    text = gsub(text, 'MTIME', self.db.TimeLimit == 0 and UNLIMITED or self.db.TimeLimit)
    text = gsub(text, 'NAME', self.playerFullName)

    if chatType == 'BNWHISPER' then
        return BNSendWhisper(channel, text)
    elseif chatType == 'SMART' then
        if IsInRaid() then
            chatType = 'RAID'
        elseif IsInGroup() then
            chatType = 'PARTY'
        else
            return
        end
    end

    return SendChatMessage(text, chatType, nil, channel)
end

function F:OnInitialize()
    if not FISConfig then
        FISConfig = defaultConfig
    else
        -- old database version fallback
        if not FISConfig.DBVer then
            -- old database before v8.2.5
            local backup = FISConfig
            for key, value in pairs(oldVerDBMap[1]) do
                FISConfig[value] = backup[key]
            end
        elseif FISConfig.DBVer == 1 then
            -- old database before v8.2.6
            local backup = FISConfig
            for key, value in pairs(oldVerDBMap[2]) do
                FISConfig[value] = backup[key]
            end
        end
        FISConfig.DBVer = 2
        -- handle deprecated
        for key in pairs(FISConfig) do
            if type(defaultConfig[key]) == 'nil' then
                FISConfig[key] = nil
            end
        end
        -- apply default value
        for key, value in pairs(defaultConfig) do
            if not FISConfig[key] then
                FISConfig[key] = value
            end
        end
    end
    self.db = FISConfig
end

function F:OnEnable()
    self:Release()
    self.status = STATUS_INIT
    self.queue = {}

    if self.db.Enable then
        self:RegisterEvent('UPDATE_INSTANCE_INFO')
        self:RegisterBucketEvent('PLAYER_ENTERING_WORLD', 1, RequestRaidInfo)
        RequestRaidInfo()
    else
        self:UnregisterAllEvents()
    end

    self:PrintStatus()
end

function F:Toggle()
    if self.status ~= STATUS_IDLE then
        self:Release()
    end
    self:UnregisterAllEvents()

    if self.db.Enable then
        self:RegisterEvent('UPDATE_INSTANCE_INFO')
        self:RegisterEvent('PARTY_INVITE_REQUEST')

        if self.db.StopDC then
            self:RegisterEvent('PLAYER_CAMPING')
        end
        if self.db.InviteOnWhisper then
            self:RegisterEvent('CHAT_MSG_WHISPER')
        end
        if self.db.InviteOnBNWhisper then
            self:RegisterEvent('CHAT_MSG_BN_WHISPER')
        end
        if self.db.AutoQueue and not self.timer then
            self.timer = self:ScheduleRepeatingTimer('FetchUpdate', .5)
        end
    else
        if self.timer then
            self:CancelTimer(self.timer)
            self.timer = nil
        end
    end
end

function F:UPDATE_INSTANCE_INFO()
    if not self.db.Enable then return end

    if self.db.AutoExtend then
        for i = 1, GetNumSavedInstances() do
            local _, _, _, difficulty, _, extended = GetSavedInstanceInfo(i)
            -- Thanks to SavedInstances
            local link = GetSavedInstanceChatLink(i)
            local instanceID, bossList = link:match(':(%d+):%d+:(%d+)\124h')
            instanceID = tonumber(instanceID)
            bossList = tonumber(bossList)
            if not extended and supportedInstances[instanceID] then
                for _, tbl in pairs(supportedInstances[instanceID]) do
                    if tContains(tbl.diff, difficulty) and bit_band(bossList, tbl.low) == tbl.low and bit_bor(bossList, tbl.high) == tbl.high then
                        SetSavedInstanceExtend(i, true)
                        break
                    end
                end
            end
        end
    end

    if self.status == STATUS_INIT then
        self.status = STATUS_IDLE
        self:PrintStatus()
        self:Toggle()
    end
end

function F:PARTY_INVITE_REQUEST(_, name)
    self:Debug("Rejected invitation from %s", name)

    StaticPopup_Hide('PARTY_INVITE')
    StaticPopupSpecial_Hide(_G.LFGInvitePopup)
end

function F:PLAYER_CAMPING()
    local dialogName = StaticPopup_Visible('CAMP')
    if dialogName then
        StaticPopup_Hide('CAMP')
    end
end

--[[
##########################################################################
###    Invite       ConfirmInvite         Leave            Release     ###
### STATUS_IDLE -> STATUS_INVITING -> STATUS_INVITED -> STATUS_LEAVING ###
###       ^              | rejected         | user left       |        ###
###       |----------------------------------------------------        ###
##########################################################################
]]--

-- invite player, STATUS_IDLE -> STATUS_INVITING when queue
function F:Invite(name)
    self:Debug("Inviting %s to party", name)

    SetDungeonDifficultyID(23) -- Dungeon Mythic
    SetRaidDifficultyID(DIFFICULTY_PRIMARYRAID_NORMAL) -- Raid Normal
    SetLegacyRaidDifficultyID(DIFFICULTY_RAID25_NORMAL) -- Legacy Raid 25 Players Normal
    ResetInstances()

    if self.db.AutoQueue then
        self.status = STATUS_INVITING
        self:RegisterEvent('GROUP_ROSTER_UPDATE')
    end

    C_PartyInfo_ConfirmInviteUnit(name)
end

-- player in party, STATUS_INVITING -> STATUS_INVITED
function F:ConfirmInvite()
    self:RegisterEvent('CHAT_MSG_PARTY')
    self:RegisterEvent('CHAT_MSG_RAID')
    self:RegisterEvent('GROUP_INVITE_CONFIRMATION')

    self.status = STATUS_INVITED
    self.invitedTime = time()

    self:SendMessage(self.db.WelcomeMsg, 'SMART')
end

-- pending to leave, STATUS_INVITED -> STATUS_LEAVING
function F:Leave(leaveMsg)
    self:UnregisterEvent('GROUP_ROSTER_UPDATE')
    self:UnregisterEvent('CHAT_MSG_PARTY')
    self:UnregisterEvent('CHAT_MSG_RAID')
    self:RegisterEvent('CHAT_MSG_PARTY_LEADER', 'Release')
    self.status = STATUS_LEAVING

    if not IsInGroup() then
        -- player left
        self:Debug("Player left")
        F:Release()
    end

    self:SendMessage(leaveMsg, 'SMART')
end

-- release current user, STATUS_LEAVING -> STATUS_IDLE
function F:Release()
    self:UnregisterEvent('GROUP_ROSTER_UPDATE')
    self:UnregisterEvent('CHAT_MSG_PARTY')
    self:UnregisterEvent('GROUP_INVITE_CONFIRMATION')
    self:UnregisterEvent('CHAT_MSG_PARTY_LEADER')

    if IsInGroup() then
        if GetNumGroupMembers() > 1 then
            PromoteToLeader('party1')
        end
        C_PartyInfo_ConfirmLeaveParty()
    end

    self.status = STATUS_IDLE
end

function F:FetchUpdate()
    if self.status == STATUS_IDLE then
        -- check queue
        if #self.queue > 0 then
            local name = self.queue[1]
            tremove(self.queue, 1)
            self:Invite(name)
        end
    elseif self.status == STATUS_INVITED then
        -- check max waiting time
        local elapsed = time() - self.invitedTime
        if self.db.TimeLimit ~= 0 and elapsed >= self.db.TimeLimit then
            self:Debug("Leaving party: Time Limit Exceeded")
            self:Leave(self.db.TLELeaveMsg)
            return
        end

        -- check player place
        if self.db.AutoLeave then
            local instanceID = select(4, UnitPosition('party1'))
            if instanceID and supportedInstances[instanceID] then
                self:Debug("Leaving party: Player entered instance %d", instanceID)
                self:Leave(self.db['AutoLeaveMsg' .. instanceID] or self.db.AutoLeaveMsg)
                return
            end
        end
    end
end

function F:GROUP_ROSTER_UPDATE()
    if self.status == STATUS_INVITING then
        if IsInGroup() then
            if GetNumGroupMembers() > 1 then
                -- accepted
                self:Debug("Player accepted")
                self:ConfirmInvite()
            end
            -- still waiting
        else
            -- rejected
            self:Debug("Player rejected")
            self:Release()
        end
    elseif self.status == STATUS_INVITED then
        if not IsInGroup() then
            -- player left
            self:Debug("Player left")
            self:Release()
        end
    elseif self.status == STATUS_LEAVING then
        if not IsInGroup() then
            -- player left
            self:Debug("Player left")
            self:Release()
        end
    end
end

-- add a player to queue
function F:QueuePush(name)
    self:Debug("Adding %s to queue", name)

    local playerIndex
    for index, playerName in ipairs(self.queue) do
        if playerName == name then
            playerIndex = index
            break
        end
    end
    if not playerIndex then
        tinsert(self.queue, name)
        self:SendMessage(self.db.EnterQueueMsg, 'WHISPER', name, #self.queue)
    else
        self:SendMessage(self.db.QueryQueueMsg, 'WHISPER', name, playerIndex)
    end
end

-- remove a player from queue
function F:QueuePop(name)
    self:Debug("Removing %s from queue", name)

    for index, playerName in pairs(self.queue) do
        if playerName == name then
            tremove(self.queue, index)
            break
        end
    end
    self:SendMessage(self.db.LeaveQueueMsg, 'WHISPER', name)
end

function F:RecvChatMessage(text)
    text = strlower(text)
    if strfind(text, 'leave') then
        return F:Leave(self.db.AutoLeaveMsg)
    elseif strfind(text, 'raid') then
        return C_PartyInfo_ConfirmConvertToRaid()
    elseif strfind(text, 'party') then
        return C_PartyInfo_ConvertToParty()
    end

    local RaidDifficulty = GetRaidDifficultyID()
    local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
    local isTenPlayer = LegacyRaidDifficulty == DIFFICULTY_RAID10_NORMAL or LegacyRaidDifficulty == DIFFICULTY_RAID10_HEROIC
    local isHeroic = RaidDifficulty == DIFFICULTY_PRIMARYRAID_HEROIC

    isTenPlayer = (isTenPlayer or strfind(text, '10')) and not strfind(text, '25')
    isHeroic = (isHeroic or strfind(text, 'h')) and not strfind(text, 'n')
    RaidDifficulty = isHeroic and DIFFICULTY_PRIMARYRAID_HEROIC or DIFFICULTY_PRIMARYRAID_NORMAL
    LegacyRaidDifficulty = isHeroic and (
        isTenPlayer and DIFFICULTY_RAID10_HEROIC or DIFFICULTY_RAID25_HEROIC
    ) or (
        isTenPlayer and DIFFICULTY_RAID10_NORMAL or DIFFICULTY_RAID25_NORMAL
    )

    SetRaidDifficultyID(RaidDifficulty)
    SetLegacyRaidDifficultyID(LegacyRaidDifficulty)

    local difficultyDisplayText =
        GetDifficultyInfo(isTenPlayer and DIFFICULTY_RAID10_NORMAL or DIFFICULTY_RAID25_NORMAL) ..
        GetDifficultyInfo(RaidDifficulty)

    self:SendMessage(format(ERR_RAID_DIFFICULTY_CHANGED_S, difficultyDisplayText), 'SMART')
end

function F:CHAT_MSG_PARTY(_, text, playerName)
    self:Debug("Received party message '%s' from %s", text, playerName)

    self:RecvChatMessage(text)
end

function F:CHAT_MSG_RAID(_, text, playerName)
    self:Debug("Received raid message '%s' from %s", text, playerName)

    self:RecvChatMessage(text)
end

function F:CHAT_MSG_WHISPER(_, text, sender)
    self:Debug("Received whisper '%s' from %s", text, sender)

    if self.db.InviteOnWhisper and text == self.db.InviteOnWhisperMsg then
        if not self.db.AutoQueue then
            self:Invite(sender)
        else
            self:QueuePush(sender)
        end
    elseif self.db.LeaveQueueOnWhisper and text == self.db.LeaveQueueOnWhisperMsg then
        self:QueuePop(sender)
    end
end

function F:CHAT_MSG_BN_WHISPER(_, text, playerName, _, _, _, _, _, _, _, _, _, _, presenceID)
    self:Debug("Received Battle.net whisper '%s' from %s(%s)", text, playerName, presenceID)

    if text ~= self.db.InviteOnBNWhisperMsg then return end

    local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
    local gameAccountInfo = accountInfo.gameAccountInfo
    local characterName, realmName = gameAccountInfo.characterName, gameAccountInfo.realmName
    self:Debug("Received character %s-%s", characterName, realmName)

    if characterName and characterName ~= '' and realmName and realmName ~= '' then
        local sender = characterName .. '-' .. realmName
        if not self.db.AutoQueue then
            self:Invite(sender)
        else
            self:QueuePush(sender)
        end
    else
        self:SendMessage(self.db.FetchErrorMsg, 'BNWHISPER', presenceID)
    end
end

function F:GROUP_INVITE_CONFIRMATION()
    local dialogName, dialog = StaticPopup_Visible('GROUP_INVITE_CONFIRMATION')
    if not dialogName then return end

    local invite = dialog.data
    local confirmationType, name = GetInviteConfirmationInfo(invite)
    local suggesterGuid, suggesterName, relationship = C_PartyInfo_GetInviteReferralInfo(invite)

    self:Debug("Received invite %s to %s from %s with relation %d",
        confirmationType == LE_INVITE_CONFIRMATION_REQUEST and "REQUEST" or
        (confirmationType == LE_INVITE_CONFIRMATION_SUGGEST and "SUGGEST" or "UNKNOWN")
        , name, suggesterName, relationship)

    if confirmationType == LE_INVITE_CONFIRMATION_REQUEST then
        if not suggesterGuid or suggesterGuid == F.playerGUID or (
            relationship ~= Enum_PartyRequestJoinRelation_Friend and
            relationship ~= Enum_PartyRequestJoinRelation_Guild
        ) then
            -- we only allow invite request from friend and guild
            -- reject
            StaticPopup_Hide('GROUP_INVITE_CONFIRMATION')
            return
        end
    elseif confirmationType ~= LE_INVITE_CONFIRMATION_SUGGEST then
        -- not request and not suggest
        -- reject
        StaticPopup_Hide('GROUP_INVITE_CONFIRMATION')
        return
    end

    RespondToInviteConfirmation(invite, true)
    StaticPopup_Hide('GROUP_INVITE_CONFIRMATION')
end
