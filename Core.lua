local F, L, P, G = unpack((select(2, ...)))

-- Lua functions
local _G = _G
local bit_band, bit_bor, format, gsub, ipairs, pairs, select = bit.band, bit.bor, format, gsub, ipairs, pairs, select
local strfind, strlower, strmatch, tinsert, tonumber, tremove = strfind, strlower, strmatch, tinsert, tonumber, tremove

-- WoW API / Variables
local BNSendWhisper = BNSendWhisper
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
-- luacheck: globals C_ChatInfo.SendChatMessage
local C_ChatInfo_SendChatMessage = C_ChatInfo.SendChatMessage
local C_PartyInfo_ConfirmConvertToRaid = C_PartyInfo.ConfirmConvertToRaid
local C_PartyInfo_ConfirmInviteUnit = C_PartyInfo.ConfirmInviteUnit
local C_PartyInfo_ConfirmLeaveParty = C_PartyInfo.ConfirmLeaveParty
local C_PartyInfo_ConvertToParty = C_PartyInfo.ConvertToParty
local C_PartyInfo_GetInviteReferralInfo = C_PartyInfo.GetInviteReferralInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetDungeonDifficultyID = GetDungeonDifficultyID
local GetInviteConfirmationInfo = GetInviteConfirmationInfo
local GetLegacyRaidDifficultyID = GetLegacyRaidDifficultyID
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSavedInstances = GetNumSavedInstances
local GetRaidDifficultyID = GetRaidDifficultyID
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local PromoteToLeader = PromoteToLeader
local RequestRaidInfo = RequestRaidInfo
local ResetInstances = ResetInstances
local RespondToInviteConfirmation = RespondToInviteConfirmation
local SetDungeonDifficultyID = SetDungeonDifficultyID
local SetLegacyRaidDifficultyID = SetLegacyRaidDifficultyID
local SetRaidDifficultyID = SetRaidDifficultyID
local SetSavedInstanceExtend = SetSavedInstanceExtend
local UnitIsDND = UnitIsDND
local UnitPosition = UnitPosition

local tContains = tContains
local StaticPopup_Visible = StaticPopup_Visible
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide

local DifficultyUtil_ID_DungeonHeroic = DifficultyUtil.ID.DungeonHeroic
local DifficultyUtil_ID_DungeonMythic = DifficultyUtil.ID.DungeonMythic
local DifficultyUtil_ID_PrimaryRaidHeroic = DifficultyUtil.ID.PrimaryRaidHeroic
local DifficultyUtil_ID_PrimaryRaidNormal = DifficultyUtil.ID.PrimaryRaidNormal
local DifficultyUtil_ID_Raid10Heroic = DifficultyUtil.ID.Raid10Heroic
local DifficultyUtil_ID_Raid10Normal = DifficultyUtil.ID.Raid10Normal
local DifficultyUtil_ID_Raid25Heroic = DifficultyUtil.ID.Raid25Heroic
local DifficultyUtil_ID_Raid25Normal = DifficultyUtil.ID.Raid25Normal
local Enum_PartyRequestJoinRelation_Friend = Enum.PartyRequestJoinRelation.Friend
local Enum_PartyRequestJoinRelation_Guild = Enum.PartyRequestJoinRelation.Guild
local ERR_RAID_DIFFICULTY_CHANGED_S = ERR_RAID_DIFFICULTY_CHANGED_S
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local GREEN_FONT_COLOR_CODE = GREEN_FONT_COLOR_CODE
local LE_INVITE_CONFIRMATION_REQUEST = LE_INVITE_CONFIRMATION_REQUEST
local LE_INVITE_CONFIRMATION_SUGGEST = LE_INVITE_CONFIRMATION_SUGGEST
local LFG_LIST_LOADING = LFG_LIST_LOADING
local LIGHTYELLOW_FONT_COLOR_CODE = LIGHTYELLOW_FONT_COLOR_CODE
local MARKED_AFK = MARKED_AFK
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local SLASH_STOPWATCH_PARAM_PAUSE1 = SLASH_STOPWATCH_PARAM_PAUSE1
local SLASH_STOPWATCH_PARAM_STOP1 = SLASH_STOPWATCH_PARAM_STOP1
local SOCIAL_SHARE_TEXT = SOCIAL_SHARE_TEXT
local START = START
local UNLIMITED = UNLIMITED

local invitedToGroupTemplate = gsub(ERR_INVITED_TO_GROUP_SS, '|Hplayer:%%s|h%[%%s%]|h', '|Hplayer:(.+)|h(.+)|h')
local invitedAlreadyInGroupTemplate = gsub(ERR_INVITED_ALREADY_IN_GROUP_SS, '|Hplayer:%%s|h%[%%s%]|h', '|Hplayer:(.+)|h(.+)|h')

local STATUS_INIT     = 0
local STATUS_IDLE     = 1
local STATUS_INVITING = 2
local STATUS_INVITED  = 3
local STATUS_LEAVING  = 4

F.supportedInstances = {
    -- Raid
    -- Vanilla
    [531] = { -- Temple of Ahn'Qiraj
        [ACHIEVEMENTFRAME_FILTER_ALL .. ' ' .. BOSS_DEAD] = { low = 365, high = 511, diff = {14} }, -- ALL KILLED
    },
    -- The Burning Crusade
    [564] = { -- Black Temple
        [9] = { low = 255, high = 255, diff = {14} }, -- Illidan Stormrage
    },
    -- Wrath of the Lich King
    [603] = { -- Ulduar
        [16] = { low = 2494, high = 122879, diff = {14} }, -- Yogg-Saron
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
        [5]  = { low = 17032, high = 17032, diff = {14, 15} }, -- Galakras
        [12] = { low = 23468, high = 23486, diff = {14, 15} }, -- Siegecrafter Blackfuse
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
        [7] = { low = 119, high = 119, diff = {14, 15} }, -- Xavius
    },
    [1530] = { -- The Nighthold
        [10] = { low = 258, high = 991, diff = {14, 15} }, -- Gul'dan
    },
    [1676] = { -- Tomb of Sargeras
        [5] = { low = 3, high = 51, diff = {14, 15} }, -- Mistress Sassz'ine
    },
    [1712] = { -- Antorus, the Burning Throne
        [2] = { low = 128, high = 2015, diff = {14, 15} }, -- Felhounds of Sargeras
    },
    -- Battle for Azeroth
    [1861] = { -- Uldir
        [7] = { low = 246, high = 246, diff = {14, 15} }, -- Mythrax
    },
    [2070] = { -- Battle of Dazar'alor
        [7] = { low = 863, high = 863, diff = {14, 15} }, -- High Tinker Mekkatorque
    },
    -- Shadowlands
    [2450] = { -- Sanctum of Domination
        [3] = { low = 66, high = 66, diff = {14, 15} }, -- The Nine
    },
    -- Dragonflight
    [2522] = { -- Vault of the Incarnates
        [8] = { low = 239, high = 239, diff = {14, 15} }, -- Raszageth the Storm-Eater
    },
    [2569] = { -- Aberrus, the Shadowed Crucible
        [9] = { low = 495, high = 495, diff = {14, 15} }, -- Scalecommander Sarkareth
    },
    [2549] = { -- Amirdrassil, the Dream's Hope
        [9] = { low = 510, high = 510, diff = {14, 15} }, -- Fyrakk the Blazing
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
    -- Shadowlands
    [2286] = { -- The Necrotic Wake
        [4] = { low = 7, high = 7, diff = {23} }, -- Nalthor the Rimebinder
    },
    [2441] = { -- Tazavesh, the Veiled Market
        [4] = { low = 127, high = 127, diff = {23} }, -- So'leah
    },
    -- Dragonflight
    [2579] = { -- Dawn of the Infinite
        [8] = { low = 127, high = 127, diff = {23} }, -- Chrono-Lord Deios
    },
}

-- print current status and config to chatframe
function F:PrintStatus()
    if not self.db.Enable then
        self:Print(RED_FONT_COLOR_CODE .. SLASH_STOPWATCH_PARAM_STOP1 .. FONT_COLOR_CODE_CLOSE .. SOCIAL_SHARE_TEXT)
    elseif self.status == STATUS_INIT then
        self:Print(LIGHTYELLOW_FONT_COLOR_CODE .. LFG_LIST_LOADING .. FONT_COLOR_CODE_CLOSE)
    elseif self.db.AutoQueue and self.pausedQueue then
        self:Print(LIGHTYELLOW_FONT_COLOR_CODE .. SLASH_STOPWATCH_PARAM_PAUSE1 .. FONT_COLOR_CODE_CLOSE)
    else
        self:Print(GREEN_FONT_COLOR_CODE .. START .. FONT_COLOR_CODE_CLOSE .. SOCIAL_SHARE_TEXT)
    end
end

-- send formatted message
function F:SendMessage(text, chatType, channel, currIndex)
    if not text or text == '' then return end

    if chatType == 'WHISPER' and not self.db.WhisperMessage then
        return
    elseif chatType == 'BNWHISPER' and not self.db.BNWhisperMessage then
        return
    elseif (chatType == 'SMART' or chatType == 'RAID' or chatType == 'PARTY') and not self.db.GroupMessage then
        return
    end

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

    return C_ChatInfo_SendChatMessage(text, chatType, nil, channel)
end

function F:UpdateDNDMessage()
    if self.db.DNDMessage then
        self:SendMessage(self.db.DNDMsg, 'DND')
    end
end

function F:RemoveDNDStatus()
    if UnitIsDND('player') then
        C_ChatInfo_SendChatMessage('', 'DND')
    end
end

function F:TogglePause(pausedQueue)
    self.pausedQueue = pausedQueue
    self:PrintStatus()
end

function F:Initialize()
    self:Release()
    self.status = STATUS_INIT
    self.queue = {}

    if self.db.Enable then
        self:RegisterEvent('UPDATE_INSTANCE_INFO')
        self:RegisterBucketEvent('PLAYER_ENTERING_WORLD', 1, RequestRaidInfo)
        RequestRaidInfo()
    else
        self:UnregisterAllEvents()
        if self.timer then
            self:CancelTimer(self.timer)
            self.timer = nil
        end
    end

    self:RemoveDNDStatus()

    self:PrintStatus()
end

function F:Update()
    self:UnregisterAllEvents()
    if not self.db.Enable then return end

    self:RegisterEvent('UPDATE_INSTANCE_INFO')
    self:RegisterEvent('PARTY_INVITE_REQUEST')
    self:RegisterEvent('CHAT_MSG_SYSTEM')

    if self.db.DNDMessage then
        self:UpdateDNDMessage()
    else
        self:RemoveDNDStatus()
    end
    if self.db.InviteOnWhisper then
        self:RegisterEvent('CHAT_MSG_WHISPER')
    end
    if self.db.InviteOnBNWhisper then
        self:RegisterEvent('CHAT_MSG_BN_WHISPER')
    end
    if self.db.InviteOnInvited then
        self:RegisterEvent('UI_ERROR_MESSAGE')
    end
    if self.db.AutoQueue and not self.timer then
        self.timer = self:ScheduleRepeatingTimer('FetchUpdate', .5)
    end
end

function F:ReleaseAndUpdate()
    if self.status ~= STATUS_IDLE then
        self:Release()
    end
    self:Update()
end

function F:UPDATE_INSTANCE_INFO()
    if not self.db.Enable then return end

    if self.db.AutoExtend then
        for i = 1, GetNumSavedInstances() do
            local _, _, _, difficulty, _, extended = GetSavedInstanceInfo(i)
            -- Thanks to SavedInstances
            local link = GetSavedInstanceChatLink(i)
            ---@cast link string
            local instanceID, bossList = strmatch(link, ':(%d+):%d+:(%d+)\124h')
            instanceID = tonumber(instanceID)
            bossList = tonumber(bossList)
            ---@cast bossList number
            if not extended and self.supportedInstances[instanceID] then
                local corrupted
                for _, data in pairs(self.supportedInstances[instanceID]) do
                    if tContains(data.diff, difficulty) then
                        if bit_band(bossList, data.low) == data.low and bit_bor(bossList, data.high) == data.high then
                            SetSavedInstanceExtend(i, true)
                            corrupted = nil
                            break
                        else
                            -- difficulty match & progress not match
                            corrupted = true
                        end
                    end
                end

                if corrupted then
                    -- corrupted lockout
                    F:Print(L["Detected corrupted lockout %s, skip auto extend."], link)
                end
            end
        end
    end

    if self.status == STATUS_INIT then
        self.status = STATUS_IDLE
        self:PrintStatus()
        self:Update()
    end
end

function F:PARTY_INVITE_REQUEST(_, name)
    self:Debug("Rejected invitation from %s", name)

    StaticPopup_Hide('PARTY_INVITE')
    StaticPopupSpecial_Hide(_G.LFGInvitePopup)
end

function F:CHAT_MSG_SYSTEM(_, text)
    if self.db.DNDMessage and strfind(text, MARKED_AFK) then
        self:UpdateDNDMessage()
    elseif self.db.InviteOnInvited then
        local playerName = strmatch(text, invitedToGroupTemplate)
            or strmatch(text, invitedAlreadyInGroupTemplate)

        if playerName then
            if self:DetectMaliciousUser(playerName) then return end

            if not self.db.AutoQueue then
                self:Invite(playerName)
            else
                self:QueuePush(playerName)
            end
        end
    end
end

function F:UI_ERROR_MESSAGE(_, errorType)
    if errorType == 720 then
        self:Debug("Inviting during invited")

        if self.pendingInvite then
            self:Debug("Readding %s to queue", self.pendingInvite)

            tinsert(self.queue, 1, self.pendingInvite)
        end
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

    C_PartyInfo_ConfirmLeaveParty()
    SetDungeonDifficultyID(DifficultyUtil_ID_DungeonMythic) -- Dungeon Mythic
    SetRaidDifficultyID(DifficultyUtil_ID_PrimaryRaidNormal) -- Raid Normal
    SetLegacyRaidDifficultyID(DifficultyUtil_ID_Raid25Normal) -- Legacy Raid 25 Players Normal
    ResetInstances()

    if self.db.AutoQueue then
        self.status = STATUS_INVITING
        self.inviteTime = GetTime()
        self:RegisterEvent('GROUP_ROSTER_UPDATE')
    end

    C_PartyInfo_ConfirmInviteUnit(name)

    self.pendingInvite = name
end

-- player in party, STATUS_INVITING -> STATUS_INVITED
function F:ConfirmInvite()
    self:RegisterEvent('CHAT_MSG_PARTY')
    self:RegisterEvent('CHAT_MSG_RAID')
    self:RegisterEvent('GROUP_INVITE_CONFIRMATION')

    self.status = STATUS_INVITED
    self.invitedTime = GetTime()
    self.pendingInvite = nil

    self:SendMessage(self.db.WelcomeMsg, 'SMART')
end

-- pending to leave, STATUS_INVITED -> STATUS_LEAVING
function F:Leave(leaveMsg)
    self:UnregisterEvent('CHAT_MSG_PARTY')
    self:UnregisterEvent('CHAT_MSG_RAID')
    self:RegisterEvent('CHAT_MSG_PARTY_LEADER', 'Release')
    self:RegisterEvent('CHAT_MSG_RAID_LEADER', 'Release')

    self.status = STATUS_LEAVING
    self.leavingTime = GetTime()

    if not IsInGroup() then
        -- player left
        self:Debug("Player left before leaving message sent")
        self:Release()
        return
    end

    if not self.db.GroupMessage or not leaveMsg or leaveMsg == '' then
        self:Release()
    end

    self:SendMessage(leaveMsg, 'SMART')
end

-- release current user, STATUS_LEAVING -> STATUS_IDLE
function F:Release()
    self:UnregisterEvent('GROUP_ROSTER_UPDATE')
    self:UnregisterEvent('CHAT_MSG_PARTY')
    self:UnregisterEvent('CHAT_MSG_RAID')
    self:UnregisterEvent('GROUP_INVITE_CONFIRMATION')
    self:UnregisterEvent('CHAT_MSG_PARTY_LEADER')
    self:UnregisterEvent('CHAT_MSG_RAID_LEADER')

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
        if self.pausedQueue then return end

        -- check queue
        if #self.queue > 0 then
            local name = tremove(self.queue, 1)

            self:Invite(name)
            self:UpdateDNDMessage()
        end
    elseif self.status == STATUS_INVITING then
        local elapsed = GetTime() - self.inviteTime
        if self.db.InviteTimeLimit ~= 0 and elapsed >= self.db.InviteTimeLimit then
            self:Debug("Leaving party: Invite Time Limit Exceeded")
            self:Release()
            return
        end
    elseif self.status == STATUS_INVITED then
        -- check max waiting time
        local elapsed = GetTime() - self.invitedTime
        if self.db.TimeLimit ~= 0 and elapsed >= self.db.TimeLimit then
            self:Debug("Leaving party: Enter Time Limit Exceeded")
            self:Leave(self.db.TLELeaveMsg)
            return
        end

        -- check player place
        if self.db.AutoLeave then
            local instanceID = select(4, UnitPosition('party1'))
            if instanceID and self.supportedInstances[instanceID] then
                self:Debug("Leaving party: Player entered instance %d", instanceID)
                self:Leave(self.db['AutoLeaveMsg' .. instanceID] or self.db.AutoLeaveMsg)
                return
            end
        end
    elseif self.status == STATUS_LEAVING then
        if self.leavingTime < GetTime() - 5 then
            -- 5 seconds after trying to send leaving message
            -- but no message sent
            self:Debug("Failed to send leaving message")
            self:Release()
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
            if GetTime() - self.invitedTime < .5 then
                -- protection: delay check here
                -- IsInGroup() return false just after invite in some case
                self:ScheduleTimer('GROUP_ROSTER_UPDATE', .5)
                return
            end
            -- player left
            self:Debug("Player left while in group")
            self:Release()
        end
    elseif self.status == STATUS_LEAVING then
        if not IsInGroup() then
            -- player left
            self:Debug("Player left while sending leaving message")
            self:Release()
        end
    end
end

-- add a player to queue
function F:QueuePush(name)
    self:Debug("Adding %s to queue", name)

    local playerIndex = self:QueueQuery(name)
    if not playerIndex then
        tinsert(self.queue, name)
        self:SendMessage(self.db.EnterQueueMsg, 'WHISPER', name, #self.queue)
    else
        self:SendMessage(self.db.QueryQueueMsg, 'WHISPER', name, playerIndex)
    end
    self:UpdateDNDMessage()
end

-- remove a player from queue
function F:QueuePop(name, leaveQueueMsg)
    self:Debug("Removing %s from queue", name)

    local playerIndex = self:QueueQuery(name)
    if playerIndex then
        tremove(self.queue, playerIndex)
    end
    self:SendMessage(leaveQueueMsg, 'WHISPER', name)
    self:UpdateDNDMessage()
end

-- query a player in queue
function F:QueueQuery(name)
    local playerIndex
    for index, playerName in ipairs(self.queue) do
        if playerName == name then
            playerIndex = index
            break
        end
    end
    return playerIndex
end

function F:RecvChatMessage(text)
    text = strlower(text)
    if strfind(text, 'leave') then
        return self:Leave(self.db.AutoLeaveMsg)
    elseif strfind(text, 'raid') then
        return C_PartyInfo_ConfirmConvertToRaid()
    elseif strfind(text, 'party') then
        return C_PartyInfo_ConvertToParty()
    end

    local DungeonDifficulty = GetDungeonDifficultyID()
    local isHeroicDungeon = DungeonDifficulty == DifficultyUtil_ID_DungeonHeroic
    isHeroicDungeon = (isHeroicDungeon or (not not strfind(text, 'h'))) and not strfind(text, 'n')
    SetDungeonDifficultyID(isHeroicDungeon and DifficultyUtil_ID_DungeonHeroic or DifficultyUtil_ID_DungeonMythic)

    local RaidDifficulty = GetRaidDifficultyID()
    local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
    local isTenPlayer = LegacyRaidDifficulty == DifficultyUtil_ID_Raid10Normal or LegacyRaidDifficulty == DifficultyUtil_ID_Raid10Heroic
    local isHeroic = RaidDifficulty == DifficultyUtil_ID_PrimaryRaidHeroic

    isTenPlayer = (isTenPlayer or (not not strfind(text, '10'))) and not strfind(text, '25')
    isHeroic = (isHeroic or (not not strfind(text, 'h'))) and not strfind(text, 'n')
    RaidDifficulty = isHeroic and DifficultyUtil_ID_PrimaryRaidHeroic or DifficultyUtil_ID_PrimaryRaidNormal
    LegacyRaidDifficulty = isHeroic and (
        isTenPlayer and DifficultyUtil_ID_Raid10Heroic or DifficultyUtil_ID_Raid25Heroic
    ) or (
        isTenPlayer and DifficultyUtil_ID_Raid10Normal or DifficultyUtil_ID_Raid25Normal
    )

    SetRaidDifficultyID(RaidDifficulty)
    SetLegacyRaidDifficultyID(LegacyRaidDifficulty)

    local difficultyDisplayText =
        GetDifficultyInfo(isTenPlayer and DifficultyUtil_ID_Raid10Normal or DifficultyUtil_ID_Raid25Normal) ..
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

do
    local lastMessageTime = {}
    local lastMessageCount = {}

    function F:DetectMaliciousUser(sender)
        if self.db.BlacklistMaliciousUser then
            if tContains(self.db.Blacklist, sender) then
                self:Debug("Ignored whisper from malicious user %s", sender)
                return true
            end

            -- rule: 5 messages within 2 seconds

            local now = GetTime()
            if lastMessageTime[sender] and lastMessageTime[sender] >= now - 2 then
                if lastMessageCount[sender] >= 4 then -- before increases
                    -- malicious user detected!
                    self:Debug("Malicious user %s detected", sender)

                    self:QueuePop(sender)
                    tinsert(self.db.Blacklist, sender)
                    return true
                end
            else
                -- reset count after 2 seconds
                lastMessageCount[sender] = nil
            end

            lastMessageTime[sender] = now
            lastMessageCount[sender] = (lastMessageCount[sender] or 0) + 1
        end
    end

    -- override point for FreeInstanceSharer_DynamicWhisper
    function F:IsInviteOnWhisperMsg(_, text)
        return text == self.db.InviteOnWhisperMsg
    end

    function F:CHAT_MSG_WHISPER(_, text, sender)
        self:Debug("Received whisper '%s' from %s", text, sender)

        if self:DetectMaliciousUser(sender) then return end

        if self.db.InviteOnWhisper and self:IsInviteOnWhisperMsg(sender, text) then
            if not self.db.AutoQueue then
                self:Invite(sender)
            else
                self:QueuePush(sender)
            end
        elseif self.db.LeaveQueueOnWhisper and text == self.db.LeaveQueueOnWhisperMsg then
            self:QueuePop(sender, self.db.LeaveQueueMsg)
        end
    end
end

function F:CHAT_MSG_BN_WHISPER(_, text, playerName, _, _, _, _, _, _, _, _, _, _, presenceID)
    self:Debug("Received Battle.net whisper '%s' from %s(%s)", text, playerName, presenceID)

    if text ~= self.db.InviteOnBNWhisperMsg then return end

    local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
    local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo
    local characterName = gameAccountInfo and gameAccountInfo.characterName
    local realmName = gameAccountInfo and gameAccountInfo.realmName
    self:Debug("Received character %s-%s", characterName or "UNKNOWN", realmName or "UNKNOWN")

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

    self:QueuePop(name)
end
