local F, L = unpack(select(2, ...))

-- Lua functions
local _G = _G
local gsub, ipairs, pairs, select, strfind, time = gsub, ipairs, pairs, select, strfind, time
local tinsert, tonumber, tremove, type = tinsert, tonumber, tremove, type

-- WoW API / Variables
local BNSendWhisper = BNSendWhisper
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_PartyInfo_ConfirmInviteUnit = C_PartyInfo.ConfirmInviteUnit
local C_PartyInfo_ConfirmLeaveParty = C_PartyInfo.ConfirmLeaveParty
local C_PartyInfo_GetInviteReferralInfo = C_PartyInfo.GetInviteReferralInfo
local GetInviteConfirmationInfo = GetInviteConfirmationInfo
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
    ["DBVer"] = 1, -- Database Version
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
    ["MaxWaitingTime"] = 30, -- Max time to wait players to enter instances
    ["AutoLeave"] = true, -- Auto leave party when players are in instances
    ["EnterQueueMsg"] = L["You're queued, and your postion is QCURR."], -- Message when entering queue
    ["FetchErrorMsg"] = L["Fail to fetch your character infomation from Battle.net, please try to whisper NAME in game."], -- Message when fail to fetch character from Battle.net
    ["QueryQueueMsg"] = L["You're queued, and your postion is QCURR."], -- Message when quering the positon in queue
    ["LeaveQueueMsg"] = ERR_LFG_LEFT_QUEUE, -- Message when leaving queue
    ["WelcomeMsg"] = L["You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."], -- Welcome message when player accepted invitation
    ["LeaveMsg"] = L["You're promoted to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."], -- Message before leaving party
}

local oldVerDBMap = {
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
    ["maxWaitingTime"] = "MaxWaitingTime",
    ["enterQueueMsg"] = "EnterQueueMsg",
    ["fetchErrorMsg"] = "FetchErrorMsg",
    ["queryQueueMsg"] = "QueryQueueMsg",
    ["leaveQueueMsg"] = "LeaveQueueMsg",
    ["welcomeMsg"] = "WelcomeMsg",
    ["leaveMsg"] = "LeaveMsg",
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
    text = gsub(text, 'MTIME', self.db.MaxWaitingTime == 0 and UNLIMITED or self.db.MaxWaitingTime)
    text = gsub(text, 'NAME', self.playerFullName)

    if chatType == 'BNWHISPER' then
        return BNSendWhisper(channel, text)
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
            for key, value in pairs(oldVerDBMap) do
                FISConfig[value] = backup[key]
            end
        end
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
    _G[dialogName .. 'Button1']:Click()
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
    self:RegisterEvent('GROUP_INVITE_CONFIRMATION')

    self.status = STATUS_INVITED
    self.invitedTime = time()

    self:SendMessage(self.db.WelcomeMsg, 'PARTY')
end

-- pending to leave, STATUS_INVITED -> STATUS_LEAVING
function F:Leave()
    self:UnregisterEvent('GROUP_ROSTER_UPDATE')
    self:UnregisterEvent('CHAT_MSG_PARTY')
    self:RegisterEvent('CHAT_MSG_PARTY_LEADER', 'Release')
    self.status = STATUS_LEAVING

    self:SendMessage(self.db.LeaveMsg, 'PARTY')
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
        if self.db.MaxWaitingTime ~= 0 and elapsed >= self.db.MaxWaitingTime then
            self:Debug("Leaving party: Max waiting time exceeded")
            self:Leave()
            return
        end

        -- check player place
        if self.db.AutoLeave then
            local instanceID = select(4, UnitPosition('party1'))
            if instanceID and autoLeaveInstanceMapID[instanceID] then
                self:Debug("Leaving party: Player entered instance")
                self:Leave()
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

function F:CHAT_MSG_BN_WHISPER(_, text, playerName, _, _, _, _, _, _, _, _, _, guid, presenceID)
    self:Debug("Received Battle.net whisper '%s' from %s(%s), presenceID = %s", text, playerName, guid, presenceID)

    if text ~= self.db.InviteOnBNWhisperMsg then return end

    local gameAccountInfo = C_BattleNet_GetGameAccountInfoByGUID(guid)
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

function F:CHAT_MSG_PARTY(_, text, playerName)
    self:Debug("Received party message '%s' from %s", text, playerName)

    -- TODO: allow from 10 to 25, Heroic to Normal
    -- TODO: allow manual leave

    local RaidDifficulty = GetRaidDifficultyID()
    local LegacyRaidDifficulty = GetLegacyRaidDifficultyID()
    local isTenPlayer = LegacyRaidDifficulty == DIFFICULTY_RAID10_NORMAL or LegacyRaidDifficulty == DIFFICULTY_RAID10_HEROIC
    local isHeroic = RaidDifficulty == DIFFICULTY_PRIMARYRAID_HEROIC

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
            _G[dialogName .. 'Button2']:Click()
            return
        end
    elseif confirmationType ~= LE_INVITE_CONFIRMATION_SUGGEST then
        -- not request and not suggest
        -- reject
        _G[dialogName .. 'Button2']:Click()
        return
    end

    _G[dialogName .. 'Button1']:Click()
end
