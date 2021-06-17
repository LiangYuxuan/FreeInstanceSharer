local F, L, P, G = unpack(select(2, ...))
local C = F:NewModule('Config')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

-- Lua functions
local _G = _G

-- WoW API / Variables
local RequestRaidInfo = RequestRaidInfo

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
            get = function(info) return F.db[info[#info]] end,
            set = function(info, value) F.db[info[#info]] = value end,
            args = {
                Enable = {
                    order = 1,
                    name = ENABLE,
                    type = 'toggle',
                    set = function(info, value) F.db[info[#info]] = value; F:OnEnable() end,
                },
                Debug = {
                    order = 2,
                    name = L["Debug Mode"],
                    type = 'toggle',
                },
                Utility = {
                    order = 10,
                    name = L["Utility"],
                    type = 'group',
                    guiInline = true,
                    set = function(info, value) F.db[info[#info]] = value; F:Update() end,
                    disabled = function() return not F.db.Enable end,
                    args = {
                        StopDC = {
                            order = 11,
                            name = L["Stop Disconnecting"],
                            type = 'toggle',
                        },
                        AutoExtend = {
                            order = 12,
                            name = L["Auto Extend Saved Instances"],
                            type = 'toggle',
                            set = function(info, value) F.db[info[#info]] = value; RequestRaidInfo() end,
                        },
                        DNDMessage = {
                            order = 13,
                            name = L["Use DND Message"],
                            type = 'toggle',
                        },
                    },
                },
                Invite = {
                    order = 20,
                    name = L["Invite"],
                    type = 'group',
                    guiInline = true,
                    disabled = function() return not F.db.Enable end,
                    args = {
                        InviteOnWhisper = {
                            order = 21,
                            name = L["Auto Invite on Whisper"],
                            type = 'toggle',
                            set = function(info, value) F.db[info[#info]] = value; F:Update() end,
                        },
                        InviteOnBNWhisper = {
                            order = 22,
                            name = L["Auto Invite on Battle.net Whisper"],
                            type = 'toggle',
                            set = function(info, value) F.db[info[#info]] = value; F:Update() end,
                        },
                        BlacklistMaliciousUser = {
                            order = 23,
                            name = L["Blacklist Malicious User"],
                            type = 'toggle',
                            disabled = function() return not F.db.Enable or not F.db.InviteOnWhisper end,
                        },
                    },
                },
                Queue = {
                    order = 30,
                    name = L["Auto Queuing"],
                    type = 'group',
                    guiInline = true,
                    disabled = function() return not F.db.Enable or not F.db.AutoQueue end,
                    args = {
                        AutoQueue = {
                            order = 31,
                            name = L["Auto Queuing"],
                            type = 'toggle',
                            set = function(info, value) F.db[info[#info]] = value; F:ReleaseAndUpdate() end,
                            disabled = function() return not F.db.Enable end,
                        },
                        LeaveQueueOnWhisper = {
                            order = 32,
                            name = L["Leave Queue on Whisper"],
                            type = 'toggle',
                        },
                        TimeLimit = {
                            order = 33,
                            name = L["Time Limit (s)"],
                            type = 'range',
                            min = 0, max = 120, step = 1,
                        },
                        AutoLeave = {
                            order = 34,
                            name = L["Auto Leave Party"],
                            type = 'toggle',
                        },
                    },
                },
                Message = {
                    order = 40,
                    name = L["Notify Message"],
                    type = 'group',
                    guiInline = true,
                    disabled = function() return not F.db.Enable or not F.db.AutoQueue end,
                    args = {
                        WhisperMessage = {
                            order = 41,
                            name = L["Whisper Message"],
                            type = 'toggle',
                        },
                        BNWhisperMessage = {
                            order = 42,
                            name = L["Battle.net Whisper Message"],
                            type = 'toggle',
                        },
                        GroupMessage = {
                            order = 43,
                            name = L["Group Message"],
                            type = 'toggle',
                        },
                    },
                },
            },
        },
        Message = {
            order = 2,
            type = 'group',
            name = L["Notify Message"],
            confirm = true,
            get = function(info) return F.db[info[#info]] end,
            set = function(info, value) F.db[info[#info]] = value end,
            args = {
                InviteOnWhisperMsg = {
                    order = 1,
                    name = L["Whisper Message of Auto Inviting"],
                    type = 'input',
                },
                InviteOnBNWhisperMsg = {
                    order = 2,
                    name = L["Battle.net Whisper Message of Auto Inviting"],
                    type = 'input',
                },
                LeaveQueueOnWhisperMsg = {
                    order = 3,
                    name = L["Whisper Message of Leaving Queue"],
                    type = 'input',
                },
                DNDMsg = {
                    order = 11,
                    name = L["DND Message"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                EnterQueueMsg = {
                    order = 21,
                    name = L["Message When Entering Queue"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                FetchErrorMsg = {
                    order = 22,
                    name = L["Message When Failing to Fetch"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                QueryQueueMsg = {
                    order = 23,
                    name = L["Message When Quering Queue Position"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                LeaveQueueMsg = {
                    order = 24,
                    name = L["Message When Leaving Queue"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                WelcomeMsg = {
                    order = 31,
                    name = L["Message When Player Entered Party"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                TLELeaveMsg = {
                    order = 32,
                    name = L["Message Before Leaving due to Time Limit Exceeded"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                AutoLeaveMsg = {
                    order = 33,
                    name = L["Message Before Leaving due to player entered instance"],
                    type = 'input',
                    width = "full",
                    multiline = true,
                },
                TextReplace = {
                    order = 91,
                    name = L["You can insert following words into the text field, and it will be replace by corresponding variables."] .. "\n" ..
                    L["QCURR - The position of the player in queue."] .. "\n" ..
                    L["QLEN - The length of the queue."] .. "\n" ..
                    L["MTIME - Time Limit to wait players to enter instance."] .. "\n" ..
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
    self.lastGroup = AceConfigDialog:AddToBlizOptions('FreeInstanceSharer', L["Notify Message"], L["Free Instance Sharer"], 'Message')
end

function C:ShowConfig()
    if _G.InterfaceOptionsFrame:IsShown() then
        _G.InterfaceOptionsFrame:Hide()
    else
        InterfaceOptionsFrame_OpenToCategory(self.lastGroup)
        InterfaceOptionsFrame_OpenToCategory(self.firstGroup)
    end
end
