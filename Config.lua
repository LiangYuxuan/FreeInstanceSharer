local addonName, addon = ...
local C = addon.core:NewModule("Config")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local generalOptions = {
    name = L["Free Instance Sharer"],
    type = "group",
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            type = "toggle",
            set = function(info, value)
                addon.db.enable = value
                addon.status = 0
                addon.core:printStatus()
                if value then
                    RequestRaidInfo()
                end
            end,
            get = function(info) return addon.db.enable end
        },
        inviteOnly = {
            order = 11,
            name = L["Invite Only"],
            type = "toggle",
            set = function(info, value)
                addon.db.inviteOnly = value
                addon.core:printStatus()
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
}
local messageOptions = {
    name = L["Notify Message"],
    type = "group",
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
            name = L["TEXT_REPLACE"],
            type = "description",
        },
    },
}

function C:OnEnable()
    AceConfig:RegisterOptionsTable(addonName, generalOptions, "/fis")
    AceConfigDialog:AddToBlizOptions(addonName, L["Free Instance Sharer"])
    AceConfigDialog:AddToBlizOptions(addonName, L["Notify Message"], addonName)
end
