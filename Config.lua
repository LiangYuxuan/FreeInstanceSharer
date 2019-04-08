local addonName, addon = ...
local Core = addon.Core
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local C = Core:NewModule("Config")

-- Lua functions
local _G = _G
local tonumber, tostring = tonumber, tostring

-- WoW API / Variables
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local RequestRaidInfo = RequestRaidInfo

-- GLOBAL: ENABLE

local options = {
    name = L["Free Instance Sharer"],
    type = "group",
    args = {
        config = {
            name = L["Open config"],
            guiHidden = true,
            type = "execute",
            func = function() C:ShowConfig() end,
        },
        General = {
            order = 1,
            type = "group",
            name = L["General settings"],
            args = {
                enable = {
                    order = 1,
                    name = ENABLE,
                    type = "toggle",
                    set = function(info, value)
                        addon.db.enable = value
                        addon.status = 0
                        Core:printStatus()
                        if value then
                            RequestRaidInfo()
                        end
                    end,
                    get = function(info) return addon.db.enable end
                },
                inviteOnly = {
                    order = 11,
                    name = L["Invite Only Mode"],
                    type = "toggle",
                    set = function(info, value)
                        addon.db.inviteOnly = value
                        Core:printStatus()
                    end,
                    get = function(info) return addon.db.inviteOnly end
                },
                preventAFK = {
                    order = 21,
                    name = L["Prevent AFK"],
                    type = "toggle",
                    set = function(info, value) addon.db.preventAFK = value end,
                    get = function(info) return addon.db.preventAFK end
                },
                debug = {
                    order = 26,
                    name = L["Debug Mode"],
                    type = "toggle",
                    set = function(info, value) addon.db.debug = value end,
                    get = function(info) return addon.db.debug end
                },
                subHeader = {
                    order = 30,
                    name = "",
                    type = "header",
                },
                autoExtend = {
                    order = 31,
                    name = L["Auto Extend Saved Instance"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoExtend = value end,
                    get = function(info) return addon.db.autoExtend end
                },
                autoInvite = {
                    order = 32,
                    name = L["Auto Invite by In-game Whisper"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoInvite = value end,
                    get = function(info) return addon.db.autoInvite end
                },
                autoInviteBN = {
                    order = 33,
                    name = L["Auto Invite by Battle.net Whisper"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoInviteBN = value end,
                    get = function(info) return addon.db.autoInviteBN end
                },
                autoLeave = {
                    order = 34,
                    name = L["Leave Queue by In-game Whisper"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoLeave = value end,
                    get = function(info) return addon.db.autoLeave end
                },
                autoQueue = {
                    order = 41,
                    name = L["Auto Entering Queue"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoQueue = value end,
                    get = function(info) return addon.db.autoQueue end
                },
                checkInterval = {
                    order = 51,
                    name = L["Check Queue Interval (ms)"],
                    type = "input",
                    pattern = "%d+",
                    width = "double",
                    confirm = true,
                    set = function(info, value) addon.db.checkInterval = tonumber(value) end,
                    get = function(info) return tostring(addon.db.checkInterval) end
                },
                maxWaitingTime = {
                    order = 52,
                    name = L["Max Waiting Time (s)"],
                    type = "input",
                    pattern = "%d+",
                    width = "double",
                    confirm = true,
                    set = function(info, value) addon.db.maxWaitingTime = tonumber(value) end,
                    get = function(info) return tostring(addon.db.maxWaitingTime) end
                },
                autoLeave = {
                    order = 53,
                    name = L["Auto Leave Group"],
                    type = "toggle",
                    set = function(info, value) addon.db.autoLeave = value end,
                    get = function(info) return addon.db.autoLeave end
                },
            },
        },
        Message = {
            order = 2,
            type = "group",
            name = L["Notify Message"],
            args = {
                autoInviteMsg = {
                    order = 1,
                    name = L["Auto Invite by In-game Whisper Message"],
                    type = "input",
                    confirm = true,
                    set = function(info, value) addon.db.autoInviteMsg = value end,
                    get = function(info) return addon.db.autoInviteMsg end
                },
                autoInviteBNMsg = {
                    order = 2,
                    name = L["Auto Invite by Battle.net Whisper Message"],
                    type = "input",
                    confirm = true,
                    set = function(info, value) addon.db.autoInviteBNMsg = value end,
                    get = function(info) return addon.db.autoInviteBNMsg end
                },
                autoLeaveMsg = {
                    order = 3,
                    name = L["Leave Queue by In-game Whisper Message"],
                    type = "input",
                    confirm = true,
                    set = function(info, value) addon.db.autoLeaveMsg = value end,
                    get = function(info) return addon.db.autoLeaveMsg end
                },
                enterQueueMsg = {
                    order = 11,
                    name = L["Entering Queue Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.enterQueueMsg = value end,
                    get = function(info) return addon.db.enterQueueMsg end
                },
                fetchErrorMsg = {
                    order = 12,
                    name = L["Fetch Error Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.fetchErrorMsg = value end,
                    get = function(info) return addon.db.fetchErrorMsg end
                },
                queryQueueMsg = {
                    order = 13,
                    name = L["Query Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.queryQueueMsg = value end,
                    get = function(info) return addon.db.queryQueueMsg end
                },
                leaveQueueMsg = {
                    order = 14,
                    name = L["Leave Queue Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.leaveQueueMsg = value end,
                    get = function(info) return addon.db.leaveQueueMsg end
                },
                welcomeMsg = {
                    order = 21,
                    name = L["Welcome Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.welcomeMsg = value end,
                    get = function(info) return addon.db.welcomeMsg end
                },
                leaveMsg = {
                    order = 22,
                    name = L["Leave Message"],
                    type = "input",
                    width = "full",
                    confirm = true,
                    multiline = true,
                    set = function(info, value) addon.db.leaveMsg = value end,
                    get = function(info) return addon.db.leaveMsg end
                },
                textReplace = {
                    order = 91,
                    name = L["You can insert following words into the text field, and it will be replace by corresponding variables."] .. "\n" ..
                    L["QCURR - The position of the player in queue."] .. "\n" ..
                    L["QLEN - The length of the queue."] .. "\n" ..
                    L["MTIME - Max time to wait players to enter instances."] .. "\n" ..
                    L["NAME - The name and realm of current character."],
                    type = "description",
                },
            },
        },
    },
}

function C:OnEnable()
    AceConfig:RegisterOptionsTable(addonName, options, "fis")
    self.firstGroup = AceConfigDialog:AddToBlizOptions(addonName, L["Free Instance Sharer"], nil, "General")
    self.lastGroup = AceConfigDialog:AddToBlizOptions(addonName, L["Notify Message"], addonName, "Message")
end

function C:ShowConfig()
    if _G.InterfaceOptionsFrame:IsShown() then
        _G.InterfaceOptionsFrame:Hide()
    else
        InterfaceOptionsFrame_OpenToCategory(self.lastGroup)
        InterfaceOptionsFrame_OpenToCategory(self.firstGroup)
    end
  end
