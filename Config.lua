local FIS, L = unpack(select(2, ...))
local C = FIS:NewModule('Config')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

-- Lua functions
local _G = _G

-- WoW API / Variables
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

local options = {
    name = L["Free Instance Sharer"],
    type = 'group',
    args = {
        config = {
            name = L["Open config"],
            guiHidden = true,
            type = 'execute',
            func = function() C:ShowConfig() end,
        },
        General = {
            order = 1,
            type = 'group',
            name = L["General settings"],
            get = function(info) return FIS.db[info[#info]] end,
            set = function(info, value) FIS.db[info[#info]] = value; FIS:Toggle() end,
            args = {
                enable = {
                    order = 1,
                    name = ENABLE,
                    type = 'toggle',
                    set = function(info, value) FIS.db[info[#info]] = value; FIS:OnEnable() end,
                },
                inviteOnly = {
                    order = 11,
                    name = L["Invite Only Mode"],
                    type = 'toggle',
                    set = function(info, value) FIS.db[info[#info]] = value; FIS:OnEnable() end,
                },
                preventAFK = {
                    order = 21,
                    name = L["Prevent AFK"],
                    type = 'toggle',
                },
                debug = {
                    order = 26,
                    name = L["Debug Mode"],
                    type = 'toggle',
                },
                subHeader = {
                    order = 30,
                    name = "",
                    type = 'header',
                },
                autoExtend = {
                    order = 31,
                    name = L["Auto Extend Saved Instance"],
                    type = 'toggle',
                },
                autoInvite = {
                    order = 32,
                    name = L["Auto Invite by In-game Whisper"],
                    type = 'toggle',
                },
                autoInviteBN = {
                    order = 33,
                    name = L["Auto Invite by Battle.net Whisper"],
                    type = 'toggle',
                },
                autoLeave = {
                    order = 34,
                    name = L["Leave Queue by In-game Whisper"],
                    type = 'toggle',
                },
                autoQueue = {
                    order = 41,
                    name = L["Auto Entering Queue"],
                    type = 'toggle',
                },
                maxWaitingTime = {
                    order = 52,
                    name = L["Max Waiting Time (s)"],
                    type = 'range',
                    min = 0, max = 120, step = 1,
                },
                autoLeave = {
                    order = 53,
                    name = L["Auto Leave Group"],
                    type = 'toggle',
                },
            },
        },
        Message = {
            order = 2,
            type = 'group',
            name = L["Notify Message"],
            confirm = true,
            get = function(info) return FIS.db[info[#info]] end,
            set = function(info, value) FIS.db[info[#info]] = value end,
            args = {
                autoInviteMsg = {
                    order = 1,
                    name = L["Auto Invite by In-game Whisper Message"],
                    type = 'input',
                },
                autoInviteBNMsg = {
                    order = 2,
                    name = L["Auto Invite by Battle.net Whisper Message"],
                    type = 'input',
                },
                autoLeaveMsg = {
                    order = 3,
                    name = L["Leave Queue by In-game Whisper Message"],
                    type = 'input',
                },
                enterQueueMsg = {
                    order = 11,
                    name = L["Entering Queue Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                fetchErrorMsg = {
                    order = 12,
                    name = L["Fetch Error Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                queryQueueMsg = {
                    order = 13,
                    name = L["Query Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                leaveQueueMsg = {
                    order = 14,
                    name = L["Leave Queue Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                welcomeMsg = {
                    order = 21,
                    name = L["Welcome Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                leaveMsg = {
                    order = 22,
                    name = L["Leave Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                textReplace = {
                    order = 91,
                    name = L["You can insert following words into the text field, and it will be replace by corresponding variables."] .. "\n" ..
                    L["QCURR - The position of the player in queue."] .. "\n" ..
                    L["QLEN - The length of the queue."] .. "\n" ..
                    L["MTIME - Max time to wait players to enter instances."] .. "\n" ..
                    L["NAME - The name and realm of current character."],
                    type = 'description',
                },
            },
        },
    },
}

function C:OnEnable()
    AceConfig:RegisterOptionsTable('FreeInstanceSharer', options, 'fis')
    self.firstGroup = AceConfigDialog:AddToBlizOptions('FreeInstanceSharer', L["Free Instance Sharer"], nil, 'General')
    self.lastGroup = AceConfigDialog:AddToBlizOptions('FreeInstanceSharer', L["Notify Message"], 'FreeInstanceSharer', 'Message')
end

function C:ShowConfig()
    if _G.InterfaceOptionsFrame:IsShown() then
        _G.InterfaceOptionsFrame:Hide()
    else
        InterfaceOptionsFrame_OpenToCategory(self.lastGroup)
        InterfaceOptionsFrame_OpenToCategory(self.firstGroup)
    end
end
